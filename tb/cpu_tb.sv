`timescale 1ns / 1ps

`include "cpu_top.v"
`include "imem_model.sv"
`include "dmem_model.sv"

module cpu_tb;
    logic clk;
    logic rst;

    localparam CLOCK_PERIOD = 10; 
    localparam HALF_PERIOD = CLOCK_PERIOD / 2;
    localparam RESET_CYCLES = 2;
    localparam SIMULATION_CYCLES = 100;

    wire [31:0] imem_addr_to_cpu;
    wire [31:0] imem_data_from_imem;
    wire [31:0] dmem_addr_from_cpu;
    wire [31:0] dmem_data_to_dmem;
    wire [31:0] dmem_data_from_dmem;
    wire        dmem_read_en_from_cpu;
    wire        dmem_write_en_from_cpu;

    cpu_top uut (
        .clk(clk),
        .rst(rst),

        .imem_addr(imem_addr_to_cpu),
        .imem_data_in(imem_data_from_imem),

        .dmem_addr(dmem_addr_from_cpu),
        .dmem_data_out(dmem_data_to_dmem),
        .dmem_data_in(dmem_data_from_dmem),
        .dmem_read_en(dmem_read_en_from_cpu),
        .dmem_write_en(dmem_write_en_from_cpu)
    );

    imem_model imem (
        .addr(imem_addr_to_cpu),
        .instruction_out(imem_data_from_imem)
    );

    dmem_model dmem (
        .clk(clk),
        .read_en(dmem_read_en_from_cpu),
        .write_en(dmem_write_en_from_cpu),
        .addr(dmem_addr_from_cpu),
        .write_data(dmem_data_to_dmem),
        .read_data_out(dmem_data_from_dmem)
    );

    always #(HALF_PERIOD) clk = ~clk;

    initial begin
        $display("--- CPU Testbench Starting ---");
        $display("NOTE: Ensure 'program.hex' is available for instruction memory.");

        $dumpfile("dump.vcd");
        $dumpvars(0, cpu_tb); 

        clk = 1; 
        rst = 1'b1;
        repeat (RESET_CYCLES * 2) @(negedge clk); 
        rst = 1'b0;
        $display("Time: %0t | --- Reset Released ---", $time);

        for (int i = 0; i < SIMULATION_CYCLES; i++) begin
            @(negedge clk); 
            $display("Time: %0t | PC: 0x%h | Instr: 0x%h | x1: 0x%h | x2: 0x%h | x5: 0x%h | x10: 0x%h | dmem_addr: 0x%h | dmem_wr_data: 0x%h | dmem_wr_en: %b",
                     $time,
                     uut.pc_unit.pc_current, // Accessing PC from instantiated pc_unit
                     uut.instruction,        // Instruction fetched by CPU
                     uut.regfile_unit.registers[1],  // Accessing x1
                     uut.regfile_unit.registers[2],  // Accessing x2
                     uut.regfile_unit.registers[5],  // Accessing x5
                     uut.regfile_unit.registers[10], // Accessing x10
                     dmem_addr_from_cpu,
                     dmem_data_to_dmem,
                     dmem_write_en_from_cpu
            );
        end

        $display("Time: %0t | --- Simulation Finished After %0d Cycles ---", $time, SIMULATION_CYCLES);
        $finish;
    end

endmodule