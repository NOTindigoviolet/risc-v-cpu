# Pipelined RISC-V CPU Project

## Project Overview

This repository contains the Verilog/SystemVerilog implementation of a 32-bit pipelined RISC-V CPU, targeting the RV32I (Integer) instruction set architecture. This project serves as a hands-on exploration of digital logic design, computer architecture principles, and hardware description languages, aiming to build a functional processor from the ground up.

The CPU features a classic 5-stage pipeline (Instruction Fetch, Instruction Decode, Execute, Memory Access, Write Back) and incorporates mechanisms to handle pipeline hazards for correct execution.

## Goals

* Implement the core RV32I instruction set.
* Design a 5-stage classic pipeline.
* Implement data forwarding (bypassing) to mitigate data hazards.
* Implement stalling mechanisms for hazards that cannot be bypassed (e.g., load-use hazards).
* Implement control hazard resolution (e.g., branch prediction with flushing).
* Develop a comprehensive verification environment using SystemVerilog.
* (Future) Explore adding RISC-V extensions (e.g., M for multiplication/division).
* (Future) Implement a basic memory hierarchy (e.g., instruction and data caches).
* (Future) Target an FPGA for hardware validation.

## Architecture

The CPU pipeline is structured as follows:

1.  **Instruction Fetch (IF):** Fetches instructions from Instruction Memory based on the Program Counter (PC).
2.  **Instruction Decode (ID):** Decodes instructions, reads operands from the Register File, and computes branch targets.
3.  **Execute (EX):** Performs ALU operations, evaluates branch conditions, and calculates memory addresses.
4.  **Memory Access (MEM):** Performs load and store operations on Data Memory.
5.  **Write Back (WB):** Writes results back to the Register File.

Hazard detection and forwarding units are integrated to ensure correct data dependencies and control flow are maintained across the pipeline stages.

## Repository Structure

.
├── src/                # Verilog/SystemVerilog source files for CPU modules
│   ├── alu.v           # Arithmetic Logic Unit
│   ├── regfile.v       # General-purpose Register File
│   ├── control_unit.v  # Generates control signals for pipeline stages
│   ├── if_stage.v      # Instruction Fetch stage logic
│   ├── id_stage.v      # Instruction Decode stage logic
│   ├── ex_stage.v      # Execute stage logic
│   ├── mem_stage.v     # Memory Access stage logic
│   ├── wb_stage.v      # Write Back stage logic
│   ├── hazard_unit.v   # Detects and handles pipeline hazards
│   ├── forwarding_unit.v # Implements data forwarding
│   ├── pipeline_regs/  # Directory for IF/ID, ID/EX, EX/MEM, MEM/WB registers
│   └── cpu_top.v       # Top-level CPU module instantiating all stages
├── tb/                 # SystemVerilog testbenches for verification
│   ├── cpu_tb.sv       # Top-level testbench for the entire CPU
│   ├── imem_model.sv   # Behavioral Instruction Memory model
│   ├── dmem_model.sv   # Behavioral Data Memory model
│   ├── alu_tb.sv       # Testbench for ALU unit (example)
│   └── ... (other unit testbenches)
├── tests/              # RISC-V assembly and C programs for testing
│   ├── fibonacci.s     # Example Fibonacci sequence in assembly
│   ├── sum_array.c     # Example C program to sum array elements
│   ├── custom_test.s   # Your custom test programs
│   └── Makefile        # (Optional) For automating compilation of tests
├── scripts/            # Automation scripts (simulation, compilation)
│   ├── compile_test.sh # Example script to compile a RISC-V test
│   ├── run_sim.sh      # Example script to run simulation with Icarus Verilog
│   └── clean.sh        # Script to clean build/simulation artifacts
├── docs/               # Design documentation, notes, diagrams
│   └── design_notes.md
│   └── pipeline_diagram.drawio # (Optional)
├── .gitignore          # Specifies intentionally untracked files to ignore
└── README.md           # This file

## Getting Started

### Prerequisites

* **Linux Environment:** WSL (Windows Subsystem for Linux)
* **HDL Simulator:**
    * **Icarus Verilog (`iverilog`) & GTKWave:** Free and open-source.
    ```bash
    sudo apt update
    sudo apt install iverilog gtkwave
    ```
    * (Optional) Commercial simulators like Mentor QuestaSim/ModelSim for advanced features.
* **RISC-V GNU Toolchain:** For compiling RISC-V assembly/C code into machine code.
    Download pre-built binaries (e.g., from SiFive) and add to PATH.

### Setup

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/riscv_cpu_project.git](https://github.com/your-username/riscv_cpu_project.git)
    cd riscv_cpu_project
    ```
2.  **Ensure toolchain is in your PATH:**
    Verify `riscv-elf-gcc --version` works in your terminal. If not, follow toolchain installation instructions to add its `bin` directory to your `~/.bashrc` (or `~/.zshrc`).

### Compiling a Test Program

To compile a RISC-V assembly test (e.g., `tests/fibonacci.s`):

```bash
# Example script (you might create scripts/compile_test.sh)
riscv-elf-as -o tests/fibonacci.o tests/fibonacci.s
riscv-elf-ld -Ttext=0x0 -o tests/fibonacci.elf tests/fibonacci.o
riscv-elf-objcopy -O binary tests/fibonacci.elf tests/fibonacci.bin
riscv-elf-objdump -d tests/fibonacci.elf > tests/fibonacci.dump