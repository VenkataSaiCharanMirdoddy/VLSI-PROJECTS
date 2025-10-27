# VLSI-PROJECTS

## Project Overview

This project implements a 4-bit Arithmetic and Logic Unit (ALU) using Verilog HDL.
The ALU performs 16 distinct operations based on a 4-bit control signal. It is designed and simulated in Xilinx Vivado, demonstrating both arithmetic and logical functionality through waveform and monitor-based verification.

## Features and Operations

The ALU takes two 4-bit inputs (a and b) and a 4-bit control signal (s), producing a 4-bit output (o).
Each control code corresponds to one operation:

| Control (`s`) | Operation | Description             |
| :-----------: | :-------- | :---------------------- |
|      0000     | A + B     | Addition                |
|      0001     | A + B + 1 | Addition with carry     |
|      0010     | A − B     | Subtraction             |
|      0011     | A − B − 1 | Subtraction with borrow |
|      0100     | A         | Pass A                  |
|      0101     | A + 1     | Increment A             |
|      0110     | A − 1     | Decrement A             |
|      0111     | A         | Pass A                  |
|      1000     | A AND B   | Bitwise AND             |
|      1001     | A OR B    | Bitwise OR              |
|      1010     | A XOR B   | Bitwise XOR             |
|      1011     | NOT A     | Bitwise NOT             |
|      1100     | NAND      | Bitwise NAND            |
|      1101     | NOR       | Bitwise NOR             |
|      1110     | A >> 1    | Logical right shift     |
|      1111     | A << 1    | Logical left shift      |

## Block Diagram

![image alt](https://github.com/VenkataSaiCharanMirdoddy/VLSI-PROJECTS/blob/main/BLOCK%20DIAGRAM.png?raw=true)

## Simulated Output 

![image alt]()
