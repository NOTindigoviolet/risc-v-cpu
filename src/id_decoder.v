`ifndef   ID_DECODER_V
`define   ID_DECODER_V

/*******************************************************************************
**
** Behavioral Verilog for an instruction decoder
**
** This module decodes 32-bit RISC-V instructions and generates control signals 
** for a single-cycle CPU datapath.
**
*******************************************************************************/

module id_decoder (
    input  wire [31:0] instruction,

    // Outputs for Register File
    output reg  [4:0]  rd_addr,
    output reg  [4:0]  rs1_addr,
    output reg  [4:0]  rs2_addr,
    output reg         reg_write_en, // Enable writing to the register file

    // Outputs for Immediate Generation
    output reg  [31:0] immediate,

    // Outputs for ALU Control
    output reg  [3:0]  alu_op,       // Defines the operation for the ALU
    output reg         alu_src_b,    // 0: ALU B operand is rs2, 1: is immediate

    // Outputs for Memory Control
    output reg         mem_read_en,  // Enable reading from data memory
    output reg         mem_write_en, // Enable writing to data memory
    output reg  [1:0]  mem_to_reg,   // 00: ALU result, 01: Mem data, 10: PC+4

    // Outputs for PC/Branching Control
    output reg         branch_en,    // Enable conditional branching
    output reg         jump_en       // Enable unconditional jump (JAL/JALR)
);
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];

    // --- Control Signal Definitions (for alu_op) ---
    localparam ALU_ADD_SUB = 4'b0000;
    localparam ALU_SLL     = 4'b0001;
    localparam ALU_SLT     = 4'b0010;
    localparam ALU_SLTU    = 4'b0011;
    localparam ALU_XOR     = 4'b0100;
    localparam ALU_SRL_SRA = 4'b0101;
    localparam ALU_OR      = 4'b0110;
    localparam ALU_AND     = 4'b0111;
    localparam ALU_COPY_A  = 4'b1000; 

    always @ (*) begin
        // --- Default Control Signal Values (safer state) ---
        rd_addr      = instruction[11:7];
        rs1_addr     = instruction[19:15];
        rs2_addr     = instruction[24:20];
        immediate    = 32'hdeadbeef; // Default to a recognizable invalid value
        reg_write_en = 1'b0;
        mem_read_en  = 1'b0;
        mem_write_en = 1'b0;
        branch_en    = 1'b0;
        jump_en      = 1'b0;
        alu_src_b    = 1'b0;
        mem_to_reg   = 2'b00;
        alu_op       = 4'b0000;

        case (opcode)
            7'b0110011: begin // R-type instructions
                reg_write_en = 1'b1;
                alu_src_b    = 1'b0; // Use rs2
                mem_to_reg   = 2'b00; // ALU result to rd

                case (funct3)
                    3'b000: alu_op = ALU_ADD_SUB; // ADD or SUB
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = ALU_SRL_SRA; // SRL or SRA
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                    default: alu_op = 4'bxxxx; // Invalid
                endcase
            end

            7'b0010011: begin // I-type ALU instructions
                reg_write_en = 1'b1;
                alu_src_b    = 1'b1; // Use immediate
                mem_to_reg   = 2'b00; // ALU result to rd
                immediate    = {{20{instruction[31]}}, instruction[31:20]}; // Sign-extended immediate

                case (funct3)
                    3'b000: alu_op = ALU_ADD_SUB; // ADD or SUB
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = ALU_SRL_SRA; // SRL or SRA
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                    default: alu_op = 4'bxxxx; // Invalid
                endcase
            end

            7'b0000011: begin // I-type load instructions
                reg_write_en = 1'b1;
                mem_read_en  = 1'b1;
                alu_src_b    = 1'b1; // Use immediate for address calculation
                mem_to_reg   = 2'b01; // Data from memory to rd
                alu_op       = ALU_ADD_SUB; // For address calculation (base + offset)
                immediate    = {{20{instruction[31]}}, instruction[31:20]}; // Sign-extended immediate
            end

            7'b0100011: begin // S-type store instructions
                mem_write_en = 1'b1;
                alu_src_b    = 1'b1; // Use immediate for address calculation
                alu_op       = ALU_ADD_SUB; // For address calculation (base + offset)
                immediate    = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // Sign-extended immediate
            end

            7'b1100011: begin // B-type branch instructions
                branch_en = 1'b1;
                alu_src_b = 1'b0; // Compare rs1 and rs2
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                case (funct3)
                    3'b000: alu_op = ALU_ADD_SUB; // For BEQ/BNE (subtract to check for zero)
                    3'b001: alu_op = ALU_ADD_SUB; // For BEQ/BNE
                    3'b100: alu_op = ALU_SLT;     // For BLT
                    3'b101: alu_op = ALU_SLT;     // For BGE (inverted BLT)
                    3'b110: alu_op = ALU_SLTU;    // For BLTU
                    3'b111: alu_op = ALU_SLTU;    // For BGEU (inverted BLTU)
                    default: alu_op = 4'bxxxx;
                endcase
            end

            7'b1101111: begin // JAL
                reg_write_en = 1'b1;
                jump_en      = 1'b1;
                alu_src_b    = 1'b1;
                mem_to_reg   = 2'b10; // PC+4 to rd
                alu_op       = ALU_ADD_SUB; // Add PC and immediate
                immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end

            7'b1100111: begin // JALR
                reg_write_en = 1'b1;
                jump_en      = 1'b1;
                alu_src_b    = 1'b1;
                mem_to_reg   = 2'b10; // PC+4 to rd
                alu_op       = ALU_ADD_SUB; // For target address calculation
                immediate    = {{20{instruction[31]}}, instruction[31:20]};
            end

            7'b0110111: begin // LUI
                reg_write_en = 1'b1;
                alu_src_b    = 1'b1;
                alu_op       = ALU_COPY_A; // Pass immediate through ALU
                immediate    = {instruction[31:12], 12'b0};
            end

            7'b0010111: begin // AUIPC
                reg_write_en = 1'b1;
                alu_src_b    = 1'b1;
                alu_op       = ALU_ADD_SUB; // Add PC and immediate
                immediate    = {instruction[31:12], 12'b0};
            end

            default: begin
                // already set default values
            end
        endcase
    end
endmodule

`endif 