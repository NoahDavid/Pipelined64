module ALU_stage ( // ALU pipeline stage
	input wire clk,
	input wire [63:0] in_a,
	input wire [63:0] in_b,
	input wire [63:0] dest_reg_val,
	input wire [63:0] imm,
	input wire [63:0] reg_when_imm,
	input wire [63:0] IR,
	output reg [63:0] IR_next_stage,
	output reg [63:0] addr_out,
	output reg [63:0] data_out,
	output reg        pc_mux_ctrl
);

wire equals;
wire nequals;

wire carry;
wire [63:0] ALU_out;

wire branch;
wire write_to_mem;
wire read_from_mem;
wire write_op_is_reg;
wire write_op_is_imm;
wire write_op_is_regd;
wire br_if_equals;

ALU_decoder_unit decode(IR, branch, write_to_mem, read_from_mem, write_op_is_reg, write_op_is_imm, write_op_is_regd, br_if_equals);
ALU alu(clk, in_a, in_b, IR[22:18], ALU_out, carry);

assign nequals =| (in_a ^ in_b);
assign equals = ~nequals;

initial begin
	IR_next_stage  = 64'h0000000000000000;
	addr_out       = 64'h0000000000000000;
	data_out       = 64'h0000000000000000;
	pc_mux_ctrl    = 1'b0;
end

always @(posedge(clk)) begin
	if(branch == 1'b1 ) begin // test if this is a branch instr
		if (br_if_equals == 1'b1) begin
			pc_mux_ctrl <= equals;
		end else begin
			pc_mux_ctrl <= nequals;
		end
	end
	if(write_to_mem == 1'b1) begin // test if this is a memory write instruction
		addr_out <= dest_reg_val;
	end
	if(read_from_mem == 1'b1) begin // test if this is a memory read instruction
		addr_out <= in_a;
	end
	if(write_op_is_reg == 1'b1) begin // test if this is writing a reg, not a imm
		data_out <= ALU_out;
	end
	if(write_op_is_imm == 1'b1) begin // test if this is writing a imm, not a reg
		data_out <= imm;
	end
	if(write_op_is_regd == 1'b1) begin // test if this has branchlike requirements (could put in branch test up there)
		data_out <= dest_reg_val;
	end
	IR_next_stage <= IR;
end

endmodule
