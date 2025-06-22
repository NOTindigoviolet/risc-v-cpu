`ifndef PIPELINED_CPU_TOP_V
`define PIPELINED_CPU_TOP_V

/*******************************************************************************
**
** Pipelined RISC-V CPU Top Module
**
** This module connects the pipeline stages (IF, ID, EX, MEM, WB)
** and their corresponding pipeline registers, including hazard and forwarding logic.
**
*******************************************************************************/

`include "if_id_reg.v"
`include "id_ex_reg.v"
`include "ex_mem_reg.v"
`include "mem_wb_reg.v"
`include "if_stage.v"
`include "id_stage.v"
`include "ex_stage.v"
`include "mem_stage.v"
`include "wb_stage.v"
`include "hazard_unit.v"
`include "forwarding_unit.v"

module cpu_top (
    input  wire        clk,
    input  wire        rst, 
    output wire [31:0] imem_addr,
    input  wire [31:0] imem_data_in,
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_data_out,
    input  wire [31:0] dmem_data_in,
    output wire        dmem_read_en,
    output wire        dmem_write_en
);
    wire rst_n;
    assign rst_n = ~rst; 
    wire        pc_write_enable;
    wire        if_id_write_enable;
    wire        id_ex_bubble_en;
    wire        if_id_bubble_en;
    wire [1:0]  forward_a_select;
    wire [1:0]  forward_b_select;
    wire [31:0] if_s_pc_out;
    wire [31:0] if_s_pc_plus4_out;
    wire [31:0] if_s_instruction_out;
    wire [31:0] if_id_r_pc_plus4;
    wire [31:0] if_id_r_instruction;
    wire [31:0] id_s_pc_plus4;
    wire [31:0] id_s_rs1_data;
    wire [31:0] id_s_rs2_data;
    wire [31:0] id_s_immediate;
    wire [4:0]  id_s_rd_addr;
    wire [4:0]  id_s_rs1_addr;
    wire [4:0]  id_s_rs2_addr;
    wire [3:0]  id_s_alu_op;
    wire        id_s_alu_src_b;
    wire        id_s_reg_write_en;
    wire        id_s_mem_read_en;
    wire        id_s_mem_write_en;
    wire [1:0]  id_s_mem_to_reg;
    wire [31:0] id_ex_r_pc_plus4;
    wire [31:0] id_ex_r_rs1_data;
    wire [31:0] id_ex_r_rs2_data;
    wire [31:0] id_ex_r_immediate;
    wire [4:0]  id_ex_r_rd_addr;
    wire [4:0]  id_ex_r_rs1_addr; 
    wire [4:0]  id_ex_r_rs2_addr; 
    wire [3:0]  id_ex_r_alu_op;
    wire        id_ex_r_alu_src_b;
    wire        id_ex_r_reg_write_en;
    wire        id_ex_r_mem_read_en;
    wire        id_ex_r_mem_write_en;
    wire [1:0]  id_ex_r_mem_to_reg;
    wire [31:0] ex_s_alu_result;
    wire [31:0] ex_s_rs2_data;
    wire [4:0]  ex_s_rd_addr;
    wire        ex_s_reg_write_en;
    wire        ex_s_mem_read_en;
    wire        ex_s_mem_write_en;
    wire [1:0]  ex_s_mem_to_reg;
    wire        ex_s_branch_taken;
    wire [31:0] ex_s_branch_target_addr;
    wire        ex_s_jump_taken;
    wire [31:0] ex_s_jump_target_addr;
    wire [31:0] ex_mem_r_alu_result;
    wire [31:0] ex_mem_r_rs2_data;
    wire [4:0]  ex_mem_r_rd_addr;
    wire        ex_mem_r_reg_write_en;
    wire        ex_mem_r_mem_read_en;
    wire        ex_mem_r_mem_write_en;
    wire [1:0]  ex_mem_r_mem_to_reg;
    wire [31:0] mem_s_dmem_data_out;
    wire [31:0] mem_s_alu_result;
    wire [4:0]  mem_s_rd_addr;
    wire        mem_s_reg_write_en;
    wire [1:0]  mem_s_mem_to_reg;
    wire [31:0] mem_wb_r_dmem_data_out;
    wire [31:0] mem_wb_r_alu_result;
    wire [4:0]  mem_wb_r_rd_addr;
    wire        mem_wb_r_reg_write_en;
    wire [1:0]  mem_wb_r_mem_to_reg;
    wire [4:0]  wb_s_rd_addr_to_rf;
    wire [31:0] wb_s_data_to_rf;
    wire        wb_s_reg_write_en_to_rf;
    wire [1:0]  pc_src_sel_for_if_stage;
    assign pc_src_sel_for_if_stage = (ex_s_branch_taken) ? 2'b01 :
                                     (ex_s_jump_taken)   ? 2'b10 :
                                                           2'b00;

    hazard_unit hu (
        .id_ex_r_mem_read_en(id_ex_r_mem_read_en),
        .id_ex_r_rd_addr    (id_ex_r_rd_addr),
        .id_s_rs1_addr      (id_s_rs1_addr),
        .id_s_rs2_addr      (id_s_rs2_addr),
        .ex_s_branch_taken  (ex_s_branch_taken),
        .ex_s_jump_taken    (ex_s_jump_taken),
        .pc_write_enable    (pc_write_enable),
        .if_id_write_enable (if_id_write_enable),
        .id_ex_bubble_en    (id_ex_bubble_en),
        .if_id_bubble_en    (if_id_bubble_en)
    );

    forwarding_unit fu (
        .id_ex_r_rs1_addr       (id_ex_r_rd_addr), 
        .id_ex_r_rs2_addr       (id_ex_r_rs2_addr),
        .ex_mem_r_rd_addr       (ex_mem_r_rd_addr),
        .ex_mem_r_reg_write_en  (ex_mem_r_reg_write_en),
        .mem_wb_r_rd_addr       (mem_wb_r_rd_addr),
        .mem_wb_r_reg_write_en  (mem_wb_r_reg_write_en),
        .forward_a_select       (forward_a_select),
        .forward_b_select       (forward_b_select)
    );

    if_stage if_unit (
        .clk                (clk),
        .rst_n              (rst_n),
        .branch_target_i    (ex_s_branch_target_addr),
        .jump_target_i      (ex_s_jump_target_addr),
        .pc_src_sel_i       (pc_src_sel_for_if_stage),
        .pc_write_enable_i  (pc_write_enable), 
        .pc_out             (if_s_pc_out),
        .pc_plus4_out       (if_s_pc_plus4_out),
        .instruction_out    (if_s_instruction_out),
        .imem_addr          (imem_addr),
        .imem_data_in       (imem_data_in)
    );

    if_id_reg if_id_pipeline_reg (
        .clk            (clk),
        .rst            (rst),
        .enable         (if_id_write_enable), 
        .flush          (if_id_bubble_en),    
        .if_pc_plus_4   (if_s_pc_plus4_out),
        .if_instruction (if_s_instruction_out),
        .id_pc_plus_4   (if_id_r_pc_plus4),
        .id_instruction (if_id_r_instruction)
    );

    id_stage id_unit (
        .clk                (clk),
        .rst_n              (rst_n),
        .if_id_pc_plus4     (if_id_r_pc_plus4),
        .if_id_instruction  (if_id_r_instruction),
        .id_ex_pc_plus4     (id_s_pc_plus4),
        .id_ex_rs1_data     (id_s_rs1_data),
        .id_ex_rs2_data     (id_s_rs2_data),
        .id_ex_immediate    (id_s_immediate),
        .id_ex_rd_addr      (id_s_rd_addr),
        .id_ex_rs1_addr     (id_s_rs1_addr),
        .id_ex_rs2_addr     (id_s_rs2_addr),
        .id_ex_alu_op       (id_s_alu_op),
        .id_ex_alu_src_b    (id_s_alu_src_b),
        .id_ex_reg_write_en (id_s_reg_write_en),
        .id_ex_mem_read_en  (id_s_mem_read_en),
        .id_ex_mem_write_en (id_s_mem_write_en),
        .id_ex_mem_to_reg   (id_s_mem_to_reg)
    );

    id_ex_reg id_ex_pipeline_reg (
        .clk                (clk),
        .rst                (rst),
        .flush              (id_ex_bubble_en), 
        .id_mem_to_reg      (id_s_mem_to_reg),
        .id_mem_read_en     (id_s_mem_read_en),
        .id_mem_write_en    (id_s_mem_write_en),
        .id_alu_src_b       (id_s_alu_src_b),
        .id_alu_op          (id_s_alu_op),
        .id_reg_write_en    (id_s_reg_write_en),
        .id_pc_plus_4       (id_s_pc_plus4),
        .id_rs1_data        (id_s_rs1_data),
        .id_rs2_data        (id_s_rs2_data),
        .id_immediate       (id_s_immediate),
        .id_rd_addr         (id_s_rd_addr),
        .id_rs1_addr        (id_s_rs1_addr), 
        .id_rs2_addr        (id_s_rs2_addr),
        .ex_mem_to_reg      (id_ex_r_mem_to_reg),
        .ex_mem_read_en     (id_ex_r_mem_read_en),
        .ex_mem_write_en    (id_ex_r_mem_write_en),
        .ex_alu_src_b       (id_ex_r_alu_src_b),
        .ex_alu_op          (id_ex_r_alu_op),
        .ex_reg_write_en    (id_ex_r_reg_write_en),
        .ex_pc_plus_4       (id_ex_r_pc_plus4),
        .ex_rs1_data        (id_ex_r_rs1_data),
        .ex_rs2_data        (id_ex_r_rs2_data),
        .ex_immediate       (id_ex_r_immediate),
        .ex_rd_addr         (id_ex_r_rd_addr),
        .ex_rs1_addr        (id_ex_r_rs1_addr),
        .ex_rs2_addr        (id_ex_r_rs2_addr)
    );

    ex_stage ex_unit (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .id_ex_pc_plus4         (id_ex_r_pc_plus4),
        .id_ex_rs1_data         (id_ex_r_rs1_data),
        .id_ex_rs2_data         (id_ex_r_rs2_data),
        .id_ex_immediate        (id_ex_r_immediate),
        .id_ex_rd_addr          (id_ex_r_rd_addr),
        .id_ex_alu_op           (id_ex_r_alu_op),
        .id_ex_alu_src_b        (id_ex_r_alu_src_b),
        .id_ex_reg_write_en     (id_ex_r_reg_write_en),
        .id_ex_mem_read_en      (id_ex_r_mem_read_en),
        .id_ex_mem_write_en     (id_ex_r_mem_write_en),
        .id_ex_mem_to_reg       (id_ex_r_mem_to_reg),
        .forward_a_select_i     (forward_a_select),
        .forward_b_select_i     (forward_b_select),
        .ex_mem_forward_data_i  (ex_mem_r_alu_result),
        .mem_wb_forward_data_i  (wb_s_data_to_rf),
        .ex_mem_alu_result      (ex_s_alu_result),
        .ex_mem_rs2_data        (ex_s_rs2_data),
        .ex_mem_rd_addr         (ex_s_rd_addr),
        .ex_mem_reg_write_en    (ex_s_reg_write_en),
        .ex_mem_mem_read_en     (ex_s_mem_read_en),
        .ex_mem_mem_write_en    (ex_s_mem_write_en),
        .ex_mem_mem_to_reg      (ex_s_mem_to_reg),
        .ex_branch_taken_o      (ex_s_branch_taken),
        .ex_branch_target_addr_o(ex_s_branch_target_addr),
        .ex_jump_taken_o        (ex_s_jump_taken),
        .ex_jump_target_addr_o  (ex_s_jump_target_addr)
    );

    ex_mem_reg ex_mem_pipeline_reg (
        .clk                (clk),
        .rst                (rst),
        .ex_mem_to_reg      (ex_s_mem_to_reg),
        .ex_mem_read_en     (ex_s_mem_read_en),
        .ex_mem_write_en    (ex_s_mem_write_en),
        .ex_reg_write_en    (ex_s_reg_write_en),
        .ex_alu_result      (ex_s_alu_result),
        .ex_rs2_data        (ex_s_rs2_data),
        .ex_rd_addr         (ex_s_rd_addr),
        .mem_mem_to_reg     (ex_mem_r_mem_to_reg),
        .mem_mem_read_en    (ex_mem_r_mem_read_en),
        .mem_mem_write_en   (ex_mem_r_mem_write_en),
        .mem_reg_write_en   (ex_mem_r_reg_write_en),
        .mem_alu_result     (ex_mem_r_alu_result),
        .mem_rs2_data       (ex_mem_r_rs2_data),
        .mem_rd_addr        (ex_mem_r_rd_addr)
    );

    mem_stage mem_unit (
        .clk                (clk),
        .rst_n              (rst_n),
        .ex_mem_alu_result  (ex_mem_r_alu_result),
        .ex_mem_rs2_data    (ex_mem_r_rs2_data),
        .ex_mem_rd_addr     (ex_mem_r_rd_addr),
        .ex_mem_reg_write_en(ex_mem_r_reg_write_en),
        .ex_mem_mem_read_en (ex_mem_r_mem_read_en),
        .ex_mem_mem_write_en(ex_mem_r_mem_write_en),
        .ex_mem_mem_to_reg  (ex_mem_r_mem_to_reg),
        .dmem_addr          (dmem_addr),
        .dmem_data_out      (dmem_data_out),
        .dmem_data_in       (dmem_data_in),
        .dmem_read_en       (dmem_read_en),
        .dmem_write_en      (dmem_write_en),
        .mem_wb_dmem_data_out(mem_s_dmem_data_out),
        .mem_wb_alu_result  (mem_s_alu_result),
        .mem_wb_rd_addr     (mem_s_rd_addr),
        .mem_wb_reg_write_en(mem_s_reg_write_en),
        .mem_wb_mem_to_reg  (mem_s_mem_to_reg)
    );

    mem_wb_reg mem_wb_pipeline_reg (
        .clk                (clk),
        .rst                (rst),
        .mem_mem_to_reg     (mem_s_mem_to_reg),
        .mem_reg_write_en   (mem_s_reg_write_en),
        .mem_dmem_data_out  (mem_s_dmem_data_out),
        .mem_alu_result     (mem_s_alu_result),
        .mem_rd_addr        (mem_s_rd_addr),
        .wb_mem_to_reg      (mem_wb_r_mem_to_reg),
        .wb_reg_write_en    (mem_wb_r_reg_write_en),
        .wb_dmem_data_out   (mem_wb_r_dmem_data_out),
        .wb_alu_result      (mem_wb_r_alu_result),
        .wb_rd_addr         (mem_wb_r_rd_addr)
    );

    wb_stage wb_unit (
        .clk                (clk),
        .rst_n              (rst_n),
        .mem_wb_dmem_data_out(mem_wb_r_dmem_data_out),
        .mem_wb_alu_result  (mem_wb_r_alu_result),
        .mem_wb_rd_addr     (mem_wb_r_rd_addr),
        .mem_wb_reg_write_en(mem_wb_r_reg_write_en),
        .mem_wb_mem_to_reg  (mem_wb_r_mem_to_reg),
        .wb_rd_addr         (wb_s_rd_addr_to_rf),
        .wb_data            (wb_s_data_to_rf),
        .wb_reg_write_en    (wb_s_reg_write_en_to_rf)
    );
endmodule
`endif