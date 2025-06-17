`ifndef MEM_STAGE_V
`define MEM_STAGE_V

/*******************************************************************************
**
** Memory Stage
**
** This module handles memory access for load and store instructions.
**
*******************************************************************************/

module mem_stage (
    input  wire        clk,
    input  wire        rst_n,

    input  wire [31:0] ex_mem_alu_result,
    input  wire [31:0] ex_mem_rs2_data,
    input  wire [4:0]  ex_mem_rd_addr,
    input  wire        ex_mem_reg_write_en,
    input  wire        ex_mem_mem_read_en,
    input  wire        ex_mem_mem_write_en,
    input  wire [1:0]  ex_mem_mem_to_reg,

    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_data_out,
    input  wire [31:0] dmem_data_in,
    output wire        dmem_read_en,
    output wire        dmem_write_en,

    output wire [31:0] mem_wb_dmem_data_out,
    output wire [31:0] mem_wb_alu_result,
    output wire [4:0]  mem_wb_rd_addr,
    output wire        mem_wb_reg_write_en,
    output wire [1:0]  mem_wb_mem_to_reg
);

    assign dmem_addr     = ex_mem_alu_result;
    assign dmem_data_out = ex_mem_rs2_data;
    assign dmem_read_en  = ex_mem_mem_read_en;
    assign dmem_write_en = ex_mem_mem_write_en;

    assign mem_wb_dmem_data_out = dmem_data_in;
    assign mem_wb_alu_result    = ex_mem_alu_result;
    assign mem_wb_rd_addr       = ex_mem_rd_addr;
    assign mem_wb_reg_write_en  = ex_mem_reg_write_en;
    assign mem_wb_mem_to_reg    = ex_mem_mem_to_reg;
endmodule

`endif