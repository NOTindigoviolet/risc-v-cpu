`ifndef PC_V
`define PC_V

/*******************************************************************************
**
** Behavioral Verilog for the RV32I Program Counter (PC)
**
** This module implements a simple program counter (PC) 
**
*******************************************************************************/
module pc (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc_current
);
    always @(posedge clk or negedge rst) 
    begin
        if (rst) 
        begin
            pc_current <= 32'b0;
        end 
        else
        begin
            pc_current <= pc_next;
        end
    end
endmodule

`endif 