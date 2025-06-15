`ifndef DMEM_MODEL_V
`define DMEM_MODEL_V

/*******************************************************************************
**
** Data Memory Model
**
** Models a simple synchronous-write, asynchronous-read RAM for a CPU's
** load and store operations.
**
*******************************************************************************/

module dmem_model (
    input  wire        clk,
    input  wire        read_en,      // Read enable signal (often always high)
    input  wire        write_en,     // Write enable signal
    input  wire [31:0] addr,         // Address for read/write
    input  wire [31:0] write_data,   // Data to be written
    output wire [31:0] read_data_out // Data being read
);
    localparam MEM_DEPTH = 8192;

    reg [31:0] memory [0:MEM_DEPTH-1];

    always @(posedge clk) begin
        if (write_en) begin
            // The address is shifted right by 2 to convert from a byte address
            // to a 32-bit word address for the memory array.
            memory[addr[31:2]] <= write_data;
        end
    end

    // The read data is continuously driven out. If read_en is high,
    // it outputs the data at the specified address; otherwise, it outputs 'Z'.
    assign read_data_out = (read_en) ? memory[addr[31:2]] : 32'hZZZZZZZZ;
endmodule

`endif 