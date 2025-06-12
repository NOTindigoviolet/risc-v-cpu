/*******************************************************************************
**
** Testbench for the RV32I Immediate Generator
**
** This testbench provides a sequence of valid RV32I instruction bit patterns
** to the generator and monitors its output immediate values to verify correctness.
**
*******************************************************************************/

`timescale 1ns / 1ps
`include "imm_gen.v"

module imm_gen_tb;

    // --- Inputs to the Immediate Generator ---
    reg  [31:0] instruction;

    // --- Wires for Immediate Generator Outputs ---
    wire [31:0] immediate;

    // --- Instantiate the Immediate Generator (DUT) ---
    imm_gen uut (
        .instruction(instruction),
        .immediate(immediate)
    );

    // --- Main Test Sequence ---
    initial begin
        $dumpfile("imm_gen_tb.vcd");
        $dumpvars(0, imm_gen_tb);
        $monitor("Time=%0t | Instr=0x%h | Immediate=0x%h", $time, instruction, immediate);

        instruction = 32'h00000013; // I-type (addi x0, x0, 0)
        #10;
        instruction = 32'h00000093; // I-type (addi x1, x0, 0)
        #10;
        instruction = 32'h00008093; // I-type (addi x1, x1, -32768)
        #10;
        instruction = 32'h00000003; // I-type (lw x1, 0(x0))
        #10;
        
        // J-type instruction
        instruction = 32'h0000006F; // jal x0, 0
        #10;

        // S-type instruction
        instruction = 32'h00F00023; // sw x1, 15(x0)
        #10;

        // B-type instruction
        instruction = 32'hE02080E3; // beq x1, x2, -512
        #10;

        $finish;
    end
endmodule
