/*******************************************************************************
**
** Behavioral Verilog for the register file
**
** This module decodes 32-bit RISC-V instructions and generates immediate values
** for a single-cycle CPU datapath.
**
*******************************************************************************/

module regfile (
    input  wire        clk,
    input  wire        rst,
    input  wire        reg_wr_en,    // Renamed for clarity
    input  wire [4:0]  rs1_addr,     // Source register 1 address
    input  wire [4:0]  rs2_addr,     // Source register 2 address
    input  wire [4:0]  rd_addr,      // Destination register address
    input  wire [31:0] w_data,      // Data to write to the destination register
    output reg  [31:0] rs1_data,    // Data read from source register 1
    output reg  [31:0] rs2_data     // Data read from source register 2
);
    reg [31:0] registers [0:31];

    always @(posedge clk) 
    begin
        if (rst) 
        begin
            for (integer i = 0; i < 32; i = i + 1) 
            begin
                registers[i] <= 32'b0;
            end
        end
    end

    always @ (negedge clk)
    begin
        if (reg_wr_en && (rd_addr != 5'b0)) 
        begin
            registers[rd_addr] <= w_data;
        end
    end

    // Read
    always @(*) 
    begin
        rs1_data = registers[rs1_addr];
        rs2_data = registers[rs2_addr];
    end

endmodule