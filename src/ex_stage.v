`ifndef EX_STAGE_V
`define EX_STAGE_V

`include "alu.v"

/*******************************************************************************
**
** Execute Stage
**
** This module performs the execution of instructions, including ALU operations,
** memory access, and branch/jump calculations. It now includes forwarding logic.
**
*******************************************************************************/

module ex_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] id_ex_pc_plus4,
    input  wire [31:0] id_ex_rs1_data,
    input  wire [31:0] id_ex_rs2_data,
    input  wire [31:0] id_ex_immediate,
    input  wire [4:0]  id_ex_rd_addr,
    input  wire [3:0]  id_ex_alu_op,
    input  wire        id_ex_alu_src_b,
    input  wire        id_ex_reg_write_en,
    input  wire        id_ex_mem_read_en,
    input  wire        id_ex_mem_write_en,
    input  wire [1:0]  id_ex_mem_to_reg,

    input  wire [1:0]  forward_a_select_i,
    input  wire [1:0]  forward_b_select_i,
    input  wire [31:0] ex_mem_forward_data_i, 
    input  wire [31:0] mem_wb_forward_data_i, 
    output wire [31:0] ex_mem_alu_result,
    output wire [31:0] ex_mem_rs2_data,
    output wire [4:0]  ex_mem_rd_addr,
    output wire        ex_mem_reg_write_en,
    output wire        ex_mem_mem_read_en,
    output wire        ex_mem_mem_write_en,
    output wire [1:0]  ex_mem_mem_to_reg
);
    wire [31:0] alu_src_a;
    wire [31:0] alu_src_b_reg; 

    assign alu_src_a = (forward_a_select_i == 2'b00) ? id_ex_rs1_data :
                       (forward_a_select_i == 2'b01) ? ex_mem_forward_data_i :
                       (forward_a_select_i == 2'b10) ? mem_wb_forward_data_i :
                       32'hdeadbeef; 
    assign alu_src_b_reg = (forward_b_select_i == 2'b00) ? id_ex_rs2_data :
                           (forward_b_select_i == 2'b01) ? ex_mem_forward_data_i :
                           (forward_b_select_i == 2'b10) ? mem_wb_forward_data_i :
                           32'hdeadbeef; 

    wire [31:0] alu_result;
    alu alu_unit (
        .clk(clk),
        .rst_n(rst_n),
        .op(id_ex_alu_op),
        .src_a(alu_src_a), 
        .src_b(id_ex_alu_src_b ? id_ex_immediate : alu_src_b_reg), 
        .result(alu_result)
    );

    assign ex_mem_alu_result = alu_result;
    assign ex_mem_rs2_data = alu_src_b_reg; 
    assign ex_mem_rd_addr = id_ex_rd_addr;
    assign ex_mem_reg_write_en = id_ex_reg_write_en;
    assign ex_mem_mem_read_en = id_ex_mem_read_en;
    assign ex_mem_mem_write_en = id_ex_mem_write_en;
    assign ex_mem_mem_to_reg = id_ex_mem_to_reg;

endmodule

`endif