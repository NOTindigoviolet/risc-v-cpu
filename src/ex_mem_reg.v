`ifndef EX_MEM_REG_V
`define EX_MEM_REG_V

/*******************************************************************************
** EX/MEM Pipeline Register
**
** Latches the ALU result, store data, and control signals from the EX stage
** for use in the MEM stage.
*******************************************************************************/
module ex_mem_reg (
    input  wire        clk,
    input  wire        rst,

    input  wire [1:0]  ex_mem_to_reg,
    input  wire        ex_mem_read_en,
    input  wire        ex_mem_write_en,
    input  wire        ex_reg_write_en,
    input  wire [31:0] ex_alu_result,
    input  wire [31:0] ex_rs2_data,     
    input  wire [4:0]  ex_rd_addr,

    output reg  [1:0]  mem_mem_to_reg,
    output reg         mem_mem_read_en,
    output reg         mem_mem_write_en,
    output reg         mem_reg_write_en,
    output reg  [31:0] mem_alu_result,
    output reg  [31:0] mem_rs2_data,
    output reg  [4:0]  mem_rd_addr
);

    always @(posedge clk or posedge rst) 
    begin
        if (rst)
        begin
            mem_mem_to_reg   <= 2'b0;
            mem_mem_read_en  <= 1'b0;
            mem_mem_write_en <= 1'b0;
            mem_reg_write_en <= 1'b0;
            mem_alu_result   <= 32'b0;
            mem_rs2_data     <= 32'b0;
            mem_rd_addr      <= 5'b0;
        end 
        else
        begin
            mem_mem_to_reg   <= ex_mem_to_reg;
            mem_mem_read_en  <= ex_mem_read_en;
            mem_mem_write_en <= ex_mem_write_en;
            mem_reg_write_en <= ex_reg_write_en;
            mem_alu_result   <= ex_alu_result;
            mem_rs2_data     <= ex_rs2_data;
            mem_rd_addr      <= ex_rd_addr;
        end
    end

endmodule

`endif