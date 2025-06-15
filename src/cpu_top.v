`ifndef CPU_TOP_V
`define CPU_TOP_V

/*******************************************************************************
**
** Single-Cycle RISC-V CPU Top Module
**
** This module connects the PC, Instruction Decoder, Register File, and ALU
** to form a basic, non-pipelined RISC-V CPU.
**
*******************************************************************************/
`include "pc.v"
`include "id_decoder.v"
`include "regfile.v"
`include "alu.v"

module cpu_top (
    input  wire        clk,
    input  wire        rst,

    output wire [31:0] imem_addr,       
    input  wire [31:0] imem_data_in,    

    output wire [31:0] dmem_addr,      
    output wire [31:0] dmem_data_out,   
    input  wire [31:0] dmem_data_in,    
    output wire        dmem_read_en,    
    output wire        dmem_write_en   
);
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    wire [31:0] instruction;

    wire [4:0]  id_rd_addr;
    wire [4:0]  id_rs1_addr;
    wire [4:0]  id_rs2_addr;
    wire        id_reg_write_en;
    wire [31:0] id_immediate;
    wire [3:0]  id_alu_op;
    wire        id_alu_src_b;
    wire        id_mem_read_en;
    wire        id_mem_write_en;
    wire [1:0]  id_mem_to_reg;
    wire        id_branch_en;
    wire        id_jump_en;

    wire [31:0] rf_rs1_data;
    wire [31:0] rf_rs2_data;

    wire [31:0] alu_operand_a;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result_out;
    wire        alu_is_zero_out;
    wire        alu_is_less_than_out;
    wire [31:0] reg_write_back_data;

    wire [6:0]  opcode_from_instr;
    wire [2:0]  funct3_from_instr;
    wire        funct7_bit5_from_instr;
    wire        is_jalr;
    wire        is_lui;
    wire        is_auipc;

    wire [31:0] branch_target_addr;
    wire [31:0] jal_target_addr;
    wire [31:0] jalr_target_addr;
    wire [31:0] pc_target_jump;
    reg         cond_branch_taken;

    assign instruction = imem_data_in; 

    assign opcode_from_instr = instruction[6:0];
    assign funct3_from_instr = instruction[14:12];
    assign funct7_bit5_from_instr = instruction[30];

    localparam OPCODE_LUI   = 7'b0110111;
    localparam OPCODE_AUIPC = 7'b0010111;
    localparam OPCODE_JALR  = 7'b1100111;

    assign is_lui   = (opcode_from_instr == OPCODE_LUI);
    assign is_auipc = (opcode_from_instr == OPCODE_AUIPC);
    assign is_jalr  = (opcode_from_instr == OPCODE_JALR);

    assign pc_plus_4 = pc_current + 32'd4;

    // --- Module Instantiations ---
    pc pc_unit (
        .clk        (clk),
        .rst        (rst),
        .pc_next    (pc_next),   
        .pc_current (pc_current)
    );
    assign imem_addr = pc_current; 

    id_decoder decoder_unit (
        .instruction    (instruction),
        .rd_addr        (id_rd_addr),
        .rs1_addr       (id_rs1_addr),
        .rs2_addr       (id_rs2_addr),
        .reg_write_en   (id_reg_write_en),
        .immediate      (id_immediate),
        .alu_op         (id_alu_op),
        .alu_src_b      (id_alu_src_b),
        .mem_read_en    (id_mem_read_en),
        .mem_write_en   (id_mem_write_en),
        .mem_to_reg     (id_mem_to_reg),
        .branch_en      (id_branch_en),
        .jump_en        (id_jump_en)
    );

    regfile regfile_unit (
        .clk          (clk),
        .rst          (rst),
        .reg_wr_en    (id_reg_write_en),
        .rs1_addr     (id_rs1_addr),
        .rs2_addr     (id_rs2_addr),
        .rd_addr      (id_rd_addr),
        .w_data       (reg_write_back_data), 
        .rs1_data     (rf_rs1_data),
        .rs2_data     (rf_rs2_data)
    );

    assign alu_operand_a = is_lui   ? id_immediate :
                           is_auipc ? pc_current :
                                      rf_rs1_data;
    assign alu_operand_b = id_alu_src_b ? id_immediate : rf_rs2_data;

    alu alu_unit (
        .operand_a    (alu_operand_a),
        .operand_b    (alu_operand_b),
        .funct3       (funct3_from_instr),     
        .funct7_bit5  (funct7_bit5_from_instr), 
        .alu_op       (id_alu_op),           
        .alu_result   (alu_result_out),
        .is_zero      (alu_is_zero_out),
        .is_less_than (alu_is_less_than_out)
    );

    assign branch_target_addr = pc_current + id_immediate; 

    always @ (*) 
    begin
        cond_branch_taken = 1'b0;
        if (id_branch_en) 
        begin
            case (funct3_from_instr)
                3'b000: cond_branch_taken = alu_is_zero_out;       // BEQ (rs1 == rs2)
                3'b001: cond_branch_taken = ~alu_is_zero_out;      // BNE (rs1 != rs2)
                3'b100: cond_branch_taken = alu_is_less_than_out;  // BLT (rs1 <s rs2)
                3'b101: cond_branch_taken = ~alu_is_less_than_out; // BGE (rs1 >=s rs2)
                3'b110: cond_branch_taken = alu_is_less_than_out;  // BLTU (rs1 <u rs2)
                3'b111: cond_branch_taken = ~alu_is_less_than_out; // BGEU (rs1 >=u rs2)
                default: cond_branch_taken = 1'b0;
            endcase
        end
    end

    // Jump Target Address Calculation
    assign jal_target_addr  = pc_current + id_immediate; 
    assign jalr_target_addr = (rf_rs1_data + id_immediate) & ~32'h1;
    assign pc_target_jump = is_jalr ? jalr_target_addr : jal_target_addr;

    // PC Next Value Selection
    assign pc_next = id_jump_en        ? pc_target_jump :
                     cond_branch_taken ? branch_target_addr :
                                         pc_plus_4;
    assign reg_write_back_data = (id_mem_to_reg == 2'b01) ? dmem_data_in :
                                 (id_mem_to_reg == 2'b10) ? pc_plus_4 :
                                                            alu_result_out;
    assign dmem_addr       = alu_result_out;  
    assign dmem_data_out   = rf_rs2_data;     
    assign dmem_read_en    = id_mem_read_en;  
    assign dmem_write_en   = id_mem_write_en; 

endmodule

`endif 