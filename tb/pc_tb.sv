/*******************************************************************************
**
** Testbench for the RV32I Program Counter (PC)
**
** This testbench provides a sequence of valid inputs to the PC module and
** monitors its output values to verify correctness.
**
*******************************************************************************/

`timescale 1ns / 1ps
`include "pc.v"

module pc_tb;
    reg         clk;
    reg         reset;
    reg  [31:0] pc_in;
    wire [31:0] pc_out;

    pc uut (
        .clk(clk),
        .rst(reset),
        .pc_next(pc_in),
        .pc_current(pc_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    initial begin
        $dumpfile("pc_tb.vcd");
        $dumpvars(0, pc_tb);
        $monitor("Time=%0t | PC In=0x%h | PC Out=0x%h", $time, pc_in, pc_out);

        reset = 1; // Assert reset
        #10;
        reset = 0; // Deassert reset

        // Test various PC inputs
        pc_in = 32'h00000000; // Initial PC value
        #10;
        pc_in = 32'h00000004; // Next instruction address
        #10;
        pc_in = 32'h00000008; // Another instruction address
        #10;

        $finish;
    end
endmodule