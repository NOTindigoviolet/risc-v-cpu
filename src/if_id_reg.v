`ifndef IF_ID_REG_V
`define IF_ID_REG_V

/*******************************************************************************
** IF/ID Pipeline Register
**
** Latches the instruction and PC+4 from the IF stage for use in the ID stage.
*******************************************************************************/
module if_id_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] if_pc_plus_4,
    input  wire [31:0] if_instruction,
    output reg  [31:0] id_pc_plus_4,
    output reg  [31:0] id_instruction
);

    always @(posedge clk or posedge rst) 
    begin
        if (rst) 
        begin
            id_pc_plus_4   <= 32'b0;
            id_instruction <= 32'h00000013; // NOP (addi x0, x0, 0)
        end 
        else 
        begin
            id_pc_plus_4   <= if_pc_plus_4;
            id_instruction <= if_instruction;
        end
    end

endmodule

`endif