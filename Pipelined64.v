module Pipelined64 ( // top level design file.
	input  wire clk,
	output wire [63:0] prg_addr,
	input  wire [63:0] prg_q,  // assumes a 2 cycle latency for both program and data memories
	output wire [63:0] dat_addr,
	input  wire [63:0] dat_q,
	output wire [63:0] dat_write,
	output wire        dat_write_enable
);

wire        pc_mux_ctrl;             // determines whether the PC increments or branches
wire [63:0] branch_addr;             // the branch address loaded into the PC if mux is set accordingly
wire [63:0] PC_delayed;              // the PC coming out of the 2 cycle latency FIFO buffer
wire        reg_write_en;            // if set, the register determined by reg_write_index will be written with reg_write_data
wire [5:0]  reg_write_index;         // the index of the register to be written to
wire [63:0] reg_write_data;          // the value to be written into the register determined by reg_write_index
wire [63:0] to_ALU_a;                // the first input to the ALU stage
wire [63:0] to_ALU_b;                // the second input to the ALU stage
wire [63:0] dest_reg_value;          // the "destination" (D) register forwarded to the ALU stage
wire [63:0] reg_when_imm;            // the Register operand in an immediate instruction (A redesign of the ISA would delete this, but oh well...)
wire [63:0] imm;                     // the bit shifted, sign extended immediate operand
wire [63:0] IR_to_ALU;               // the IR value going into the ALU stage
wire [63:0] IR_to_fifo;              // the IR value going into the Data memory "latency absorber" FIFO buffer
wire [63:0] IR_to_last;              // the IR value going into the write back stage
wire [63:0] reg_wb_data_before_fifo; // the write back data before going through the Data memory FIFO buffer


PC_stage      program_counter_stage(clk, pc_mux_ctrl, branch_addr,
									prg_addr);
									assign branch_addr = dat_write;
FIFO_1_input   program_lat_absorber(clk, prg_addr,
									PC_delayed);
registers            register_stage(clk, prg_q, PC_delayed, reg_write_en, reg_write_index, reg_write_data,
									to_ALU_a, to_ALU_b, dest_reg_value, reg_when_imm, imm, IR_to_ALU);
ALU_stage                 ALU_stage(clk, to_ALU_a, to_ALU_b, dest_reg_value, imm, reg_when_imm, IR_to_ALU,
									IR_to_fifo, dat_addr, dat_write, pc_mux_ctrl);
FIFO_2_input      data_lat_absorber(clk, IR_to_fifo, dat_write,
									IR_to_last, reg_wb_data_before_fifo);
write_back_stage        final_stage(clk, IR_to_last, IR_to_fifo, dat_q, reg_wb_data_before_fifo,
									reg_write_data, reg_write_en, reg_write_index, dat_write_enable);

endmodule
