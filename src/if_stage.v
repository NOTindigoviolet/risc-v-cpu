`ifndef IF_STAGE_V
`define IF_STAGE_V

/*******************************************************************************
**
** Instruction Fetch Stage
**
** This module fetches instructions from instruction memory based on the current
** program counter (PC) and handles branching and jumping.
**
*******************************************************************************/

module if_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] branch_target_i,
    input  wire [31:0] jump_target_i,
    input  wire [1:0]  pc_src_sel_i,      // 00: PC+4, 01: branch, 10: jump
    input  wire        pc_write_enable_i, // For stalls

    output reg  [31:0] pc_out,
    output reg  [31:0] pc_plus4_out,
    output reg  [31:0] instruction_out,

    output wire [31:0] imem_addr,
    input  wire [31:0] imem_data_in
);
    reg [31:0] pc_reg;

    assign imem_addr = pc_reg;

    always @(posedge clk or negedge rst_n) 
    begin
        if (!rst_n)
            pc_reg <= 32'b0;
        else if (pc_write_enable_i) 
        begin
            case (pc_src_sel_i)
                2'b00: pc_reg <= pc_reg + 4;
                2'b01: pc_reg <= branch_target_i;
                2'b10: pc_reg <= jump_target_i;
                default: pc_reg <= pc_reg + 4;
            endcase
        end
    end

    always @(*) 
    begin
        pc_out          = pc_reg;
        pc_plus4_out    = pc_reg + 4;
        instruction_out = imem_data_in;
    end

endmodule

`endif