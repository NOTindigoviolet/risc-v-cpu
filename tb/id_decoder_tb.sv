/*******************************************************************************
**
** Testbench for the RV32I Instruction Decoder
**
** This testbench provides a sequence of valid RV32I instruction bit patterns
** to the decoder and monitors its output control signals to verify correctness.
**
*******************************************************************************/

`timescale 1ns / 1ps
`include "id_decoder.v" 

module decoder_tb;

    // --- Inputs to the Decoder ---
    reg  [31:0] instruction;

    // --- Wires for all Decoder Outputs ---
    // Register File
    wire [4:0]  rd_addr;
    wire [4:0]  rs1_addr;
    wire [4:0]  rs2_addr;
    wire        reg_write_en;
    // Immediate
    wire [31:0] immediate;
    // ALU Control
    wire [3:0]  alu_op;
    wire        alu_src_b;
    // Memory Control
    wire        mem_read_en;
    wire        mem_write_en;
    wire [1:0]  mem_to_reg;
    // PC/Branching Control
    wire        branch_en;
    wire        jump_en;


    // --- Instantiate the Decoder (DUT) ---
    id_decoder uut (
        .instruction(instruction),
        .rd_addr(rd_addr),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .reg_write_en(reg_write_en),
        .immediate(immediate),
        .alu_op(alu_op),
        .alu_src_b(alu_src_b),
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .mem_to_reg(mem_to_reg),
        .branch_en(branch_en),
        .jump_en(jump_en)
    );

    // --- Main Test Sequence ---
    initial begin
        $dumpfile("decoder_tb.vcd");
        $dumpvars(0, decoder_tb);
        $monitor("Time=%0t | Instr=0x%h | rd=%d, rs1=%d, rs2=%d | imm=0x%h | alu_op=%b, alu_src_b=%b | reg_wr=%b, mem_rd=%b, mem_wr=%b, mem2reg=%b | branch=%b, jump=%b",
            $time, instruction, rd_addr, rs1_addr, rs2_addr, immediate, alu_op, alu_src_b, reg_write_en, mem_read_en, mem_write_en, mem_to_reg, branch_en, jump_en);
        #10;

        $display("\n--- Testing R-type: add x3, x1, x2 ---");
        instruction = 32'h002081b3; #10;
        $display("\n--- Testing I-type: addi x5, x6, -50 ---");
        instruction = 32'hfce30293; #10;
        $display("\n--- Testing I-type (Load): lw x7, 16(x8) ---");
        instruction = 32'h01042383; #10;
        $display("\n--- Testing S-type: sw x9, -36(x10) ---");
        instruction = 32'hfc952e23; #10;
        $display("\n--- Testing B-type: beq x11, x12, label (offset=4) ---");
        instruction = 32'h00c58263; #10; 
        $display("\n--- Testing U-type: lui x13, 0xBEEF0 ---");
        instruction = 32'hbeef06b7; #10;
        $display("\n--- Testing J-type: jal x14, label (offset=-2148) ---");
        instruction = 32'hF9CFF76F; #10; 
        $display("\n--- Testing Complete ---");
        $finish;
    end

endmodule