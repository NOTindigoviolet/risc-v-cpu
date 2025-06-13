/*******************************************************************************
**
** Testbench for the RV32I Register File
**
** This testbench provides a sequence of valid RV32I instruction bit patterns
** to the register file and monitors its output register values to verify correctness.
**
*******************************************************************************/

`timescale 1ns / 1ps
`include "regfile.v"

module regfile_tb;
    reg        clk;
    reg        rst;
    reg        reg_wr_en;
    reg [4:0]  rs1_addr;
    reg [4:0]  rs2_addr;
    reg [4:0]  rd_addr;
    reg [31:0] w_data;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    regfile uut (
        .clk(clk),
        .rst(rst),
        .reg_wr_en(reg_wr_en),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .w_data(w_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    always #5 clk = ~clk;

   initial begin
        $display("--- Regfile Testbench Starting ---");

        $dumpfile("regfile_tb.vcd");
        $dumpvars(0, regfile_tb);

        $monitor("Time=%0t | rst=%b, wr_en=%b | rd_addr=%d, w_data=0x%h | rs1_addr=%d -> rs1_data=0x%h | rs2_addr=%d -> rs2_data=0x%h",
                 $time, rst, reg_wr_en, rd_addr, w_data, rs1_addr, rs1_data, rs2_addr, rs2_data);

        // 1. Initialize and apply reset
        clk = 0;
        rst = 1;
        reg_wr_en = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr = 0;
        w_data = 0;
        #20; // Hold reset for 2 clock cycles
        rst = 0;
        #5;
        $display("\n--- Reset released ---");

        // 2. Test Case: Write to x1, then read from it
        $display("\n--- Test 1: Write to x1 ---");
        rd_addr = 5'd1;
        w_data  = 32'hAAAAAAAA;
        reg_wr_en = 1'b1;
        @(posedge clk); // Wait for the positive edge for the write to occur
        reg_wr_en = 1'b0; // Disable write for the read phase
        #1; // Allow combinational read to settle
        $display("Reading from x1 after write...");
        rs1_addr = 5'd1;
        #10;

        // 3. Test Case: Write to x5 and x10, then read both simultaneously
        $display("\n--- Test 2: Write to x5 and x10 ---");
        // Write to x5
        rd_addr = 5'd5;
        w_data  = 32'hDEADBEEF;
        reg_wr_en = 1'b1;
        @(posedge clk);
        // Write to x10
        rd_addr = 5'd10;
        w_data  = 32'hC0FFEE00;
        @(posedge clk);
        reg_wr_en = 1'b0; // Disable write
        #1;
        $display("Reading from x5 and x10 simultaneously...");
        rs1_addr = 5'd5;
        rs2_addr = 5'd10;
        #10;

        // 4. Test Case: Attempt to write to x0 (the zero register)
        $display("\n--- Test 3: Attempt to write to x0 ---");
        rd_addr = 5'd0;
        w_data  = 32'hFFFFFFFF; // Attempt to write all 1s
        reg_wr_en = 1'b1;
        @(posedge clk);
        reg_wr_en = 1'b0;
        #1;
        $display("Reading from x0 after write attempt...");
        rs1_addr = 5'd0; // Read from x0
        rs2_addr = 5'd1; // Read from x1 to show it's unchanged
        #10;
        $display("Verification: x0 should still be 0. x1 should still be 0xAAAAAAAA.");
        #10;

        $display("\n--- All tests complete ---");
        $finish;
    end

endmodule