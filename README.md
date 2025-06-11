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