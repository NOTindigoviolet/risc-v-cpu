`ifndef HAZARD_UNIT_V
`define HAZARD_UNIT_V

/*******************************************************************************
**
** Hazard Detection Unit
**
** Detects data and control hazards and generates control signals to stall
** or flush the pipeline stages accordingly.
**
** - Stalls for one cycle on a load-use data hazard (RAW dependency on a load).
** - Flushes the IF and ID stages when a branch is taken or a jump occurs.
**
*******************************************************************************/
module hazard_unit (
    input  wire        id_ex_r_mem_read_en,  
    input  wire [4:0]  id_ex_r_rd_addr,     
    input  wire [4:0]  id_s_rs1_addr,        
    input  wire [4:0]  id_s_rs2_addr,        
    input  wire        ex_s_branch_taken,   
    input  wire        ex_s_jump_taken,      
    output wire        pc_write_enable,      
    output wire        if_id_write_enable,   
    output wire        id_ex_bubble_en,     
    output wire        if_id_bubble_en     
);
    wire control_hazard;
    wire load_use_hazard;
    assign load_use_hazard = (id_ex_r_mem_read_en) &&
                             (id_ex_r_rd_addr != 5'b0) &&
                             ((id_ex_r_rd_addr == id_s_rs1_addr) || (id_ex_r_rd_addr == id_s_rs2_addr));
    assign control_hazard = ex_s_branch_taken || ex_s_jump_taken;
    assign pc_write_enable    = ~load_use_hazard;
    assign if_id_write_enable = ~load_use_hazard;
    assign id_ex_bubble_en = load_use_hazard || control_hazard;
    assign if_id_bubble_en = control_hazard;
endmodule

`endif