`ifndef FORWARDING_UNIT_V
`define FORWARDING_UNIT_V

/*******************************************************************************
**
** Forwarding Unit
**
** Detects RAW data hazards and determines if data should be forwarded from
** the EX/MEM or MEM/WB pipeline registers to the EX stage to avoid stalls.
**
*******************************************************************************/
module forwarding_unit (
    input  wire [4:0]  id_ex_r_rs1_addr,
    input  wire [4:0]  id_ex_r_rs2_addr,
    input  wire [4:0]  ex_mem_r_rd_addr,
    input  wire        ex_mem_r_reg_write_en,
    input  wire [4:0]  mem_wb_r_rd_addr,
    input  wire        mem_wb_r_reg_write_en,
    output reg  [1:0]  forward_a_select, 
    output reg  [1:0]  forward_b_select  
);

    always @(*) begin
        forward_a_select = 2'b00;
        forward_b_select = 2'b00;

        if (ex_mem_r_reg_write_en && (ex_mem_r_rd_addr != 5'b0) && (ex_mem_r_rd_addr == id_ex_r_rs1_addr)) begin
            forward_a_select = 2'b01; 
        end
        else if (mem_wb_r_reg_write_en && (mem_wb_r_rd_addr != 5'b0) && (mem_wb_r_rd_addr == id_ex_r_rs1_addr)) begin
            forward_a_select = 2'b10; 
        end

        if (ex_mem_r_reg_write_en && (ex_mem_r_rd_addr != 5'b0) && (ex_mem_r_rd_addr == id_ex_r_rs2_addr)) begin
            forward_b_select = 2'b01; 
        end
        else if (mem_wb_r_reg_write_en && (mem_wb_r_rd_addr != 5'b0) && (mem_wb_r_rd_addr == id_ex_r_rs2_addr)) begin
            forward_b_select = 2'b10; 
        end
    end

endmodule

`endif