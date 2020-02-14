# Pipelined 64
---
A 64-bit pipelined RISC processor designed by Noah Koliadko in Verilog.

## Information
---
I designed this in Quartus Prime Lite 18.1 using several Altera MegaFunctions*. Here is a list of the ones that I used in the processor along with their names:
| MegaFunction | Name | Notes |
| ----------- | ----------- | ----------- |
| LPM\_ADD\_SUB | `add_sub` | 64 bit wide, create add_sub port, unsigned, carry/borrow in/out, no output latency |
| LPM_CLSHIFT | `imm_shifter` | logical shift, always shift left, 64 bit, restrict shifting range to 4 bits, no optional outputs, no output latency |

Here is a list of the ones that I used to test the processor:
| MegaFunction | Function |
| ----------- | ----------- |
| RAM: 2-PORT | Main Memory/Program Memory |
I connected one of the RAM ports to the program memory connection on the processor, and the other one to the data memory connection.

## Setup
---
Create a project in Quartus, and create a top-level design file (preferably with a dual port RAM instance to connect to the processor). Copy all the verilog design files from the repository into the project directory, and add them to the project. Create all the necessary MegaFunctions and add them to the project.
More detailed instructions coming soon!

*: I'm not entirely sure if they are all technically called MegaFunctions, but you get the point...