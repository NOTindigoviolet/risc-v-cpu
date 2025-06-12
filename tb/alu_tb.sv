/*******************************************************************************
**
** Testbench for the RV32I ALU
**
** This testbench instantiates the ALU and drives its inputs with various
** test vectors to verify the functionality of each operation.
**
*******************************************************************************/
`timescale 1ns / 1ps
`include "alu.v" 

module alu_tb;

    // Inputs to the ALU
    reg  [31:0] operand_a;
    reg  [31:0] operand_b;
    reg  [2:0]  funct3;
    reg         funct7_bit5;
    reg  [3:0]  alu_op;

    // Outputs from the ALU
    wire [31:0] alu_result;
    wire        is_zero;
    wire        is_less_than;

    // Instantiate the ALU module
    alu uut (
        .operand_a    (operand_a),
        .operand_b    (operand_b),
        .funct3       (funct3), 
        .funct7_bit5  (funct7_bit5),
        .alu_op       (alu_op),
        .alu_result   (alu_result),
        .is_zero      (is_zero),
        .is_less_than (is_less_than)
    );

    // Initial block to drive the test vectors
    initial begin
        // 1. Setup for VCD dump (for GTKWave)
        $dumpfile("alu_test.vcd");
        $dumpvars(0, alu_tb);

        // 2. Setup monitor to display signals on change
        $monitor("Time=%0t | op_a=0x%h, op_b=0x%h | alu_op=%b | funct3=%b, funct7_b5=%b | result=0x%h | zero=%b, lt=%b",
                 $time, operand_a, operand_b, alu_op, funct3, funct7_bit5, alu_result, is_zero, is_less_than);

        // 3. Initialize inputs
        operand_a = 0;
        operand_b = 0;
        funct3 = 0;
        funct7_bit5 = 0;
        alu_op = 0;
        #10;

        // 4. Test Cases
        $display("\n--- Testing ADD ---");
        alu_op = 4'b0000; funct3 = 3'b000; funct7_bit5 = 0;
        operand_a = 32'd10; operand_b = 32'd5; #10;        // 10 + 5 = 15
        operand_a = 32'hFFFFFFFF; operand_b = 32'd1; #10; // -1 + 1 = 0 (is_zero should be 1)

        $display("\n--- Testing SUB ---");
        alu_op = 4'b0000; funct3 = 3'b000; funct7_bit5 = 1;
        operand_a = 32'd10; operand_b = 32'd5; #10;        // 10 - 5 = 5
        operand_a = 32'd5; operand_b = 32'd10; #10;       // 5 - 10 = -5

        $display("\n--- Testing SLL (Shift Left Logical) ---");
        alu_op = 4'b0001; funct3 = 3'b001;
        operand_a = 32'h0000000F; operand_b = 32'd2; #10;  // 0xF << 2 = 0x3C

        $display("\n--- Testing SLT (Set on Less Than, Signed) ---");
        alu_op = 4'b0010; funct3 = 3'b010;
        operand_a = 32'd10; operand_b = 32'd20; #10;       // 10 < 20 -> result = 1
        operand_a = 32'd20; operand_b = 32'd10; #10;       // 20 < 10 -> result = 0
        operand_a = 32'hFFFFFFFF; operand_b = 32'd1; #10; // -1 < 1 -> result = 1

        $display("\n--- Testing SLTU (Set on Less Than, Unsigned) ---");
        alu_op = 4'b0011; funct3 = 3'b011;
        operand_a = 32'd10; operand_b = 32'd20; #10;       // 10 < 20 -> result = 1
        operand_a = 32'hFFFFFFFF; operand_b = 32'd1; #10; // 2^32-1 < 1 -> result = 0

        $display("\n--- Testing XOR ---");
        alu_op = 4'b0100; funct3 = 3'b100;
        operand_a = 32'hF0F0F0F0; operand_b = 32'h0F0F0F0F; #10; // Result: FFFFFFFF

        $display("\n--- Testing SRL (Shift Right Logical) ---");
        alu_op = 4'b0101; funct3 = 3'b101; funct7_bit5 = 0;
        operand_a = 32'h8000000F; operand_b = 32'd4; #10;  // Logical shift right -> 08000000

        $display("\n--- Testing SRA (Shift Right Arithmetic) ---");
        alu_op = 4'b0101; funct3 = 3'b101; funct7_bit5 = 1;
        operand_a = 32'h8000000F; operand_b = 32'd4; #10;  // Arithmetic shift right -> F8000000

        $display("\n--- Testing OR ---");
        alu_op = 4'b0110; funct3 = 3'b110;
        operand_a = 32'hF0F0F0F0; operand_b = 32'h00FF00FF; #10; // Result: FFFFF0FF

        $display("\n--- Testing AND ---");
        alu_op = 4'b0111; funct3 = 3'b111;
        operand_a = 32'hF0F0F0F0; operand_b = 32'h00FF00FF; #10; // Result: 00F000F0

        $display("\n--- All tests complete ---");
        #10;
        $finish; // End the simulation
    end

endmodule