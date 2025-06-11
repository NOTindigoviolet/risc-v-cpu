/*******************************************************************************
**
** Behavioral Verilog for a 32-bit RISC-V ALU
**
** This module implements the core arithmetic and logical operations
** for a 32-bit RISC-V processor. It supports the standard RV32I base
** integer instruction set.
**
*******************************************************************************/

module alu (
    input  wire [31:0] operand_a,    // First operand
    input  wire [31:0] operand_b,    // Second operand
    input  wire [2:0]  funct3,       // 3-bit function code from instruction
    input  wire        funct7_bit5,  // Bit 5 of the 7-bit function code
    input  wire [3:0]  alu_op,       // ALU operation control signal
    output reg  [31:0] alu_result,   // Result of the ALU operation
    output wire        is_zero,      // Zero flag
    output wire        is_less_than  // Less than flag (for SLT/SLTU)
);

    // Internal wire for the result before assignment
    wire [31:0] result;

    // Zero flag is high if the result is zero
    assign is_zero = (result == 32'b0);

    // Less than flag logic for SLT and SLTU
    assign is_less_than = (alu_op == 4'b0110) ? ($signed(operand_a) < $signed(operand_b)) :
                          (alu_op == 4'b0111) ? (operand_a < operand_b) :
                          1'b0;

    // The main combinational block for ALU operations
    always @(*) begin
        case (alu_op)
            // ADD / SUB
            4'b0000: begin
                if (funct7_bit5)
                    alu_result = operand_a - operand_b; // SUB
                else
                    alu_result = operand_a + operand_b; // ADD
            end

            // SLL (Shift Left Logical)
            4'b0001: alu_result = operand_a << operand_b[4:0];

            // SLT (Set on Less Than, signed)
            4'b0010: alu_result = ($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0;

            // SLTU (Set on Less Than, unsigned)
            4'b0011: alu_result = (operand_a < operand_b) ? 32'd1 : 32'd0;

            // XOR
            4'b0100: alu_result = operand_a ^ operand_b;

            // SRL / SRA (Shift Right Logical / Arithmetic)
            4'b0101: begin
                if (funct7_bit5)
                    alu_result = $signed(operand_a) >>> operand_b[4:0]; // SRA
                else
                    alu_result = operand_a >> operand_b[4:0]; // SRL
            end

            // OR
            4'b0110: alu_result = operand_a | operand_b;

            // AND
            4'b0111: alu_result = operand_a & operand_b;

            default: alu_result = 32'hdeadbeef; // Default case
        endcase
    end

    // Assign internal result to the output
    assign result = alu_result;

endmodule