`ifndef IMEM_MODEL_SV
`define IMEM_MODEL_SV

/*******************************************************************************
**
** Instruction Memory Model
**
** Models a simple read-only memory for a CPU's instruction path.
** It is initialized from a hexadecimal file at the start of simulation.
**
*******************************************************************************/

module imem_model (
    input  wire [31:0] addr,
    output wire [31:0] instruction_out
);
    localparam MEM_DEPTH = 256; //1024
    // Name of the file containing the machine code in hex format.
    localparam MEM_FILE  = "program.hex";

    reg [31:0] memory [0:MEM_DEPTH-1];

    initial 
    begin
        $display("IMEM: Initializing instruction memory from file: %s", MEM_FILE);
        $readmemh(MEM_FILE, memory);
    end

    // --- Combinational Read Logic ---
    // The memory output is the content at the word-aligned address.
    // The address is shifted right by 2 because the memory is word-addressable,
    // but the CPU generates byte-addresses.
    assign instruction_out = memory[addr[31:2]];

endmodule

`endif