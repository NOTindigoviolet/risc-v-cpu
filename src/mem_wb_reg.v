`ifndef MEM_WB_REG_V
`define MEM_WB_REG_V

/*******************************************************************************
** MEM/WB Pipeline Register
**
** Latches the final data (from memory or ALU) and control signals from the
** MEM stage for use in the WB stage.
*******************************************************************************/
module mem_wb_reg (
    input  wire        clk,
    input  wire        rst,

    input  wire [1:0]  mem_mem_to_reg,
    input  wire        mem_reg_write_en,
    input  wire [31:0] mem_dmem_data_out, 
    input  wire [31:0] mem_alu_result,
    input  wire [4:0]  mem_rd_addr,

    output reg  [1:0]  wb_mem_to_reg,
    output reg         wb_reg_write_en,
    output reg  [31:0] wb_dmem_data_out,
    output reg  [31:0] wb_alu_result,
    output reg  [4:0]  wb_rd_addr
);

    always @(posedge clk or posedge rst) 
    begin
        if (rst)
        begin
            wb_mem_to_reg   <= 2'b0;
            wb_reg_write_en <= 1'b0;
            wb_dmem_data_out <= 32'b0;
            wb_alu_result    <= 32'b0;
            wb_rd_addr       <= 5'b0;
        end 
        else 
        begin
            wb_mem_to_reg   <= mem_mem_to_reg;
            wb_reg_write_en <= mem_reg_write_en;
            wb_dmem_data_out <= mem_dmem_data_out;
            wb_alu_result    <= mem_alu_result;
            wb_rd_addr      <= mem_rd_addr;
        end
    end

endmodule

`endif 