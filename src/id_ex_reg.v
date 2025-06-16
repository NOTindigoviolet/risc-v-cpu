`ifndef ID_EX_REG_V
`define ID_EX_REG_V

/*******************************************************************************
** ID/EX Pipeline Register
**
** Latches all control signals, register data, and immediate values from the
** ID stage for use in the EX stage.
*******************************************************************************/
module id_ex_reg (
    input  wire        clk,
    input  wire        rst,

    input  wire [1:0]  id_mem_to_reg,
    input  wire        id_mem_read_en,
    input  wire        id_mem_write_en,
    input  wire        id_alu_src_b,
    input  wire [3:0]  id_alu_op,
    input  wire        id_reg_write_en,

    input  wire [31:0] id_pc_plus_4,
    input  wire [31:0] id_rs1_data,
    input  wire [31:0] id_rs2_data,
    input  wire [31:0] id_immediate,
    input  wire [4:0]  id_rd_addr,

    output reg  [1:0]  ex_mem_to_reg,
    output reg         ex_mem_read_en,
    output reg         ex_mem_write_en,
    output reg         ex_alu_src_b,
    output reg  [3:0]  ex_alu_op,
    output reg         ex_reg_write_en,

    output reg  [31:0] ex_pc_plus_4,
    output reg  [31:0] ex_rs1_data,
    output reg  [31:0] ex_rs2_data,
    output reg  [31:0] ex_immediate,
    output reg  [4:0]  ex_rd_addr
);

    always @(posedge clk or posedge rst) 
    begin
        if (rst) 
        begin
            // Reset all control signals to 0 to prevent unintended operations
            ex_mem_to_reg   <= 2'b0;
            ex_mem_read_en  <= 1'b0;
            ex_mem_write_en <= 1'b0;
            ex_alu_src_b    <= 1'b0;
            ex_alu_op       <= 4'b0;
            ex_reg_write_en <= 1'b0;
            ex_pc_plus_4    <= 32'b0;
            ex_rs1_data     <= 32'b0;
            ex_rs2_data     <= 32'b0;
            ex_immediate    <= 32'b0;
            ex_rd_addr      <= 5'b0;
        end 
        else
        begin
            ex_mem_to_reg   <= id_mem_to_reg;
            ex_mem_read_en  <= id_mem_read_en;
            ex_mem_write_en <= id_mem_write_en;
            ex_alu_src_b    <= id_alu_src_b;
            ex_alu_op       <= id_alu_op;
            ex_reg_write_en <= id_reg_write_en;
            ex_pc_plus_4    <= id_pc_plus_4;
            ex_rs1_data     <= id_rs1_data;
            ex_rs2_data     <= id_rs2_data;
            ex_immediate    <= id_immediate;
            ex_rd_addr      <= id_rd_addr;
        end
    end

endmodule

`endif