module ALU_decoder_unit ( // ALU Decoder unit. Not entirely complete.
	input wire [63:0] IR,
	output reg branch,
	output reg write_to_mem,
	output reg read_from_mem,
	output reg write_op_is_reg,
	output reg write_op_is_imm,
	output reg write_op_is_regd,
	output reg br_if_equals
);

/*
	Here we go, a overview of the ISA for reference.
	Blank spaces mean irrelavent information for that particular instruction.
	$(#num) = address from #num
	
	Regular   Instruction Format:
	63    58 57     23 22   18 17    12 11     6 5      0
	+-------+---------+-------+--------+--------+--------+
	| ID 6  | Nothing | ALU 5 | REGD 6 | REG1 6 | REG2 6 |
	+-------+---------+-------+--------+--------+--------+
	
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| Action                  | Assembly            | ID Code (6) | ALU opcode    | "D" Reg | "A" Reg | "B" Reg |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| NOP                     | NOP                 |    0x00     |               |         |         |         |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| MOV R1 -> R2            | MOV R2, R1          |    0x01     |    0x00       | Ind(R2) | Ind(R1) |         |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| MOV R1 -> R2            | MOV R2, R1          |    0x01     |    0x01       | Ind(R2) |         | Ind(R1) |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| LD $(R1) -> R2          | LD R2, $(R1)        |    0x02     |    0x00       | Ind(R2) | Ind(R1) |         |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| LD $(R1) -> R2          | LD R2, $(R1)        |    0x02     |    0x01       | Ind(R2) |         | Ind(R1) |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| STR R1 -> $(R2)         | STR $(R2), R1       |    0x03     |    0x00       | Ind(R2) | Ind(R1) |         |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| STR R1 -> $(R2)         | STR $(R2), R1       |    0x03     |    0x01       | Ind(R2) |         | Ind(R1) |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| BR $(R1)                | BR $(R1)            |    0x04     |               | Ind(R1) |  0x00   |  0x00   |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| BR $(R1) if R2 == R3    | BEQ $(R1), R2, R3   |    0x04     |               | Ind(R1) | Ind(R2) | Ind(R3) |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| BR $(R1) if R2 != R3    | BNEQ $(R1), R2, R3  |    0x05     |               | Ind(R1) | Ind(R2) | Ind(R3) |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+
	| R1 (func) R2 -> R3      | (func) R3, R1, R2   |    0x06     | CodeFor(func) | Ind(R3) | Ind(R1) | Ind(R2) |
	+-------------------------+---------------------+-------------+---------------+---------+---------+---------+

   Immediate Instruction Format:
   63   58 57   52 51                      4 3     0
   +------+-------+-------------------------+-------+
   | ID 6 | REG 6 |          ADDR           | SHIFT |
   +------+-------+-------------------------+-------+

	The Assembler/Compiler/Human may need to use several immediate/bitshift/logic
	instructions to construct a single Imm. (STR Imm not implemented yet)
	
	+-----------------------------+----------------------+-------------+---------+---------+---------+
	| Action                      | Assembly             | ID Code (6) |   Reg   |   Imm   |  shft   |
	+-----------------------------+----------------------+-------------+---------+---------+---------+
	| LD #(Imm << shft) -> R1     | LD R1, #(RawImm)     |    0x07     | Ind(R1) |   Imm   |  shft   |
	+-----------------------------+----------------------+-------------+---------+---------+---------+
	| STR $(R1) -> #(Imm << shft) | STR #(RawImm), $(R1) |    0x08     | Ind(R1) |   Imm   |  shft   |
	+-----------------------------+----------------------+-------------+---------+---------+---------+
 */

// Start parameter definitions
parameter NOP_CODE  = 6'b000000;
parameter MOV_CODE  = 6'b000001;
parameter LD_CODE   = 6'b000010;
parameter STR_CODE  = 6'b000011;
parameter BEQ_CODE  = 6'b000100;
parameter BNEQ_CODE = 6'b000101;
parameter ALU_CODE  = 6'b000110;
parameter LDI_CODE  = 6'b000111;
parameter STRI_CODE = 6'b001000; // Not implemented
// End parameter definitions

initial begin
	branch           = 1'b0;
	write_to_mem     = 1'b0;
	read_from_mem    = 1'b0;
	write_op_is_reg  = 1'b0;
	write_op_is_imm  = 1'b0;
	write_op_is_regd = 1'b0;
	br_if_equals     = 1'b0;
end

always @(IR[63:58]) begin
	case (IR[63:58])
		NOP_CODE: begin
			branch           <= 1'b0;
			write_to_mem     <= 1'b0;
			read_from_mem    <= 1'b0;
			write_op_is_reg  <= 1'b0;
			write_op_is_imm  <= 1'b0;
			write_op_is_regd <= 1'b0;
			br_if_equals     <= 1'b0;
		end
		MOV_CODE: begin
			branch           <= 1'b0;
			write_to_mem     <= 1'b0;
			read_from_mem    <= 1'b0;
			write_op_is_reg  <= 1'b1;
			write_op_is_imm  <= 1'b0;
			write_op_is_regd <= 1'b0;
			br_if_equals     <= 1'b0;
		end
		LD_CODE: begin
			branch           <= 1'b0;
			write_to_mem     <= 1'b0;
			read_from_mem    <= 1'b1;
			write_op_is_reg  <= 1'b0;
			write_op_is_imm  <= 1'b0;
			write_op_is_regd <= 1'b0;
			br_if_equals     <= 1'b0;
		end
		STR_CODE: begin
			branch           <= 1'b0;
			write_to_mem     <= 1'b1;
			read_from_mem    <= 1'b0;
			write_op_is_reg  <= 1'b1;
			write_op_is_imm  <= 1'b0;
			write_op_is_regd <= 1'b0;
			br_if_equals     <= 1'b0;
		end
		BEQ_CODE: begin
			branch           <= 1'b1;
			write_to_mem     <= 1'b0;
			read_from_mem    <= 1'b0;
			write_op_is_reg  <= 1'b0;
			write_op_is_imm  <= 1'b0;
			write_op_is_regd <= 1'b1;
			br_if_equals     <= 1'b1;
		end
		BNEQ_CODE: begin
			branch           <= 1'b1;
			write_to_mem     <= 1'b0;
			read_from_mem    <= 1'b0;
			write_op_is_reg  <= 1'b0;
			write_op_is_imm  <= 1'b0;
			write_op_is_regd <= 1'b1;
			br_if_equals     <= 1'b0;
		end
		ALU_CODE: begin
			branch           <= 1'b0;
			write_to_mem     <= 1'b0;
			read_from_mem    <= 1'b0;
			write_op_is_reg  <= 1'b1;
			write_op_is_imm  <= 1'b0;
			write_op_is_regd <= 1'b0;
			br_if_equals     <= 1'b0;
		end
		LDI_CODE: begin
			branch           <= 1'b0;
			write_to_mem     <= 1'b0;
			read_from_mem    <= 1'b0;
			write_op_is_reg  <= 1'b0;
			write_op_is_imm  <= 1'b1;
			write_op_is_regd <= 1'b0;
			br_if_equals     <= 1'b0;
		end
		default: begin
			branch           <= 1'b0;
			write_to_mem     <= 1'b0;
			read_from_mem    <= 1'b0;
			write_op_is_reg  <= 1'b0;
			write_op_is_imm  <= 1'b0;
			write_op_is_regd <= 1'b0;
			br_if_equals     <= 1'b0;
		end
	endcase
end

endmodule
