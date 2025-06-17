`ifndef ID_STAGE_V
`define ID_STAGE_V

`include "id_decoder.v"
`include "regfile.v"
`include "imm_gen.v"

module id_stage (
    input  wire        clk,
    input  wire        rst_n,
    
    input  wire [31:0] if_id_pc_plus4,
    input  wire [31:0] if_id_instruction,

    output wire [31:0] id_ex_pc_plus4,
    output wire [31:0] id_ex_rs1_data,
    output wire [31:0] id_ex_rs2_data,
    output wire [31:0] id_ex_immediate,
    output wire [4:0]  id_ex_rd_addr,
    output wire [4:0]  id_ex_rs1_addr,
    output wire [4:0]  id_ex_rs2_addr,
    output wire [3:0]  id_ex_alu_op,
    output wire        id_ex_alu_src_b,
    output wire        id_ex_reg_write_en,
    output wire        id_ex_mem_read_en,
    output wire        id_ex_mem_write_en,
    output wire [1:0]  id_ex_mem_to_reg
);
    assign id_ex_pc_plus4 = if_id_pc_plus4;

     id_decoder id_decoder_inst (
        .instruction(if_id_instruction),
        .rd_addr(id_ex_rd_addr),
        .rs1_addr(id_ex_rs1_addr),
        .rs2_addr(id_ex_rs2_addr),
        .reg_write_en(id_ex_reg_write_en),
        .alu_op(id_ex_alu_op),
        .alu_src_b(id_ex_alu_src_b),
        .mem_read_en(id_ex_mem_read_en),
        .mem_write_en(id_ex_mem_write_en),
        .mem_to_reg(id_ex_mem_to_reg)
    );

    regfile regfile_inst (
        .clk(clk),
        .rst(~rst_n),
        .reg_wr_en(wb_reg_write_en),
        .rs1_addr(id_ex_rs1_addr),
        .rs2_addr(id_ex_rs2_addr),
        .rd_addr(wb_rd_addr),
        .w_data(wb_data),
        .rs1_data(id_ex_rs1_data),
        .rs2_data(id_ex_rs2_data)
    );

    imm_gen imm_gen_inst (
        .instruction(if_id_instruction),
        .immediate(id_ex_immediate)
    );
endmodule

`endif