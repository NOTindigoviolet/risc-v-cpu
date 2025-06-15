`ifndef IMMEDIATE_GENERATOR_V
`define IMMEDIATE_GENERATOR_V

/*******************************************************************************
**
** Behavioral Verilog for the immediate generator
**
** This module decodes 32-bit RISC-V instructions and generates immediate values
** for a single-cycle CPU datapath.
**
*******************************************************************************/

module imm_gen (
    input  wire [31:0] instruction,
    output reg  [31:0] immediate
);
    wire [6:0] opcode = instruction[6:0];

    // Instruction Opcodes
    localparam OPCODE_I_ARITH = 7'b0010011;
    localparam OPCODE_I_LOAD  = 7'b0000011;
    localparam OPCODE_I_JALR  = 7'b1100111;
    localparam OPCODE_S       = 7'b0100011;
    localparam OPCODE_B       = 7'b1100011;
    localparam OPCODE_U_LUI   = 7'b0110111;
    localparam OPCODE_U_AUIPC = 7'b0010111;
    localparam OPCODE_J       = 7'b1101111;

    always @(*) begin
        case (opcode)
            // I-type (Arithmetic, Loads, JALR) -> CORRECT
            OPCODE_I_ARITH, OPCODE_I_LOAD, OPCODE_I_JALR:
            begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-type (Stores)
            OPCODE_S:
            begin
                // CORRECTED: Sign extension is 20 bits for a 12-bit immediate
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // B-type (Branches)
            OPCODE_B:
            begin
                // CORRECTED: Added inst[31] for imm[12] and changed sign extension to 19
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end

            // U-type (LUI, AUIPC) -> CORRECT
            OPCODE_U_LUI, OPCODE_U_AUIPC:
            begin
                immediate = {instruction[31:12], 12'b0};
            end

            // J-type (JAL)
            OPCODE_J:
            begin
                // CORRECTED: Added inst[31] for imm[20] and changed sign extension to 11
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end

            // R-type
            default:
            begin
                immediate = 32'hdeadbeef; // Or 32'b0, depending on design preference
            end
        endcase
    end

endmodule

`endif 