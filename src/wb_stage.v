`ifndef WB_STAGE_V
`define WB_STAGE_V

/*******************************************************************************
**
** Writeback Stage
**
** This module fetches instructions from instruction memory based on the current
** program counter (PC) and handles branching and jumping.
**
*******************************************************************************/

module wb_stage (
    input  wire        clk,
    input  wire        rst_n,

    input  wire [31:0] mem_wb_dmem_data_out,
    input  wire [31:0] mem_wb_alu_result,
    input  wire [4:0]  mem_wb_rd_addr,
    input  wire        mem_wb_reg_write_en,
    input  wire [1:0]  mem_wb_mem_to_reg,

    output wire [4:0]  wb_rd_addr,
    output wire [31:0] wb_data,
    output wire        wb_reg_write_en
);

    assign wb_rd_addr      = mem_wb_rd_addr;
    assign wb_reg_write_en = mem_wb_reg_write_en;
    assign wb_data = (mem_wb_mem_to_reg == 2'b01) ? mem_wb_dmem_data_out :
                     (mem_wb_mem_to_reg == 2'b00) ? mem_wb_alu_result :
                     32'b0; 

endmodule

`endif