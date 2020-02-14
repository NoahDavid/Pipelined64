module ALU ( // The actual ALU. Not entirely complete.
	input wire clk,
	input wire  [63:0] in_a,
	input wire  [63:0] in_b,
	input wire   [4:0] operand,
	output wire [63:0] out,
	output reg         carry_bit
);

integer i;

wire [63:0] outputs [0:31];
wire carrys  [0:31];
reg enables [0:31];

add_sub AS(enables[2] | enables[3] | enables[4] | enables[5], ((enables[4] | enables[5]) ? carry_bit : 1'b0), in_a, in_b, // This is an Altera IP.
		   carrys[2], outputs[2]);
assign carrys[3] = carrys[2];
assign carrys[4] = carrys[2];
assign carrys[5] = carrys[2];
assign outputs[3] = outputs[2];
assign outputs[4] = outputs[2];
assign outputs[5] = outputs[2];

assign outputs[0] = in_a;
assign outputs[1] = in_b;
assign outputs[6] = ~in_a;
assign outputs[7] = in_a & in_b;
assign outputs[8] = in_a | in_b;
assign outputs[9] = in_a ^ in_b;

initial begin
	carry_bit    <= 1'b0;
end

assign out = outputs[operand];

always @(operand) begin
	for (i = 0; i < 32; i = i + 1) begin
		if(operand == i) begin
			enables[i] = 1'b1;
		end else begin
			enables[i] = 1'b0;
		end
	end
end

always @(posedge(clk)) begin
	carry_bit <= carrys[operand];
end

/*
 * 
 * This is the ALU opcode reference:
 *
 *       +-+-+-+-+-+
 * Bits: |4|3|2|1|0|
 *       +-+-+-+-+-+
 *       |0|0|0|0|0| : A -> Out  (This is probably a not very smart way of dealing with this)
 *       +-+-+-+-+-+
 *       |0|0|0|0|1| : B -> Out  (This is probably a not very smart way of dealing with this)
 *       +-+-+-+-+-+
 *       |0|0|0|1|0| : Add
 *       +-+-+-+-+-+
 *       |0|0|0|1|1| : Subtract
 *       +-+-+-+-+-+
 *       |0|0|1|0|0| : Add with carry
 *       +-+-+-+-+-+
 *       |0|0|1|0|1| : Subtract with carry
 *       +-+-+-+-+-+
 *       |0|0|1|1|0| : NOT A
 *       +-+-+-+-+-+
 *       |0|0|1|1|1| : AND
 *       +-+-+-+-+-+
 *       |0|1|0|0|0| : OR
 *       +-+-+-+-+-+
 *       |0|1|0|0|1| : XOR
 *       +-+-+-+-+-+
 *       |0|1|0|1|0| : Not implemented
 *       +-+-+-+-+-+
 *       |0|1|0|1|1| : Not implemented
 *       +-+-+-+-+-+
 *       |0|1|1|0|0| : Not implemented
 *       +-+-+-+-+-+
 *       |0|1|1|0|1| : Not implemented
 *       +-+-+-+-+-+
 *       |0|1|1|1|0| : Not implemented
 *       +-+-+-+-+-+
 *       |0|1|1|1|1| : Not implemented
 *       +-+-+-+-+-+
 *       |1|0|0|0|0| : Not implemented
 *       +-+-+-+-+-+
 *       |1|0|0|0|1| : Not implemented
 *       +-+-+-+-+-+
 *       |1|0|0|1|0| : Not implemented
 *       +-+-+-+-+-+
 *       |1|0|0|1|1| : Not implemented
 *       +-+-+-+-+-+
 *       |1|0|1|0|0| : Not implemented
 *       +-+-+-+-+-+
 *       |1|0|1|0|1| : Not implemented
 *       +-+-+-+-+-+
 *       |1|0|1|1|0| : Not implemented
 *       +-+-+-+-+-+
 *       |1|0|1|1|1| : Not implemented
 *       +-+-+-+-+-+
 *       |1|1|0|0|0| : Not implemented
 *       +-+-+-+-+-+
 *       |1|1|0|0|1| : Not implemented
 *       +-+-+-+-+-+
 *       |1|1|0|1|0| : Not implemented
 *       +-+-+-+-+-+
 *       |1|1|0|1|1| : Not implemented
 *       +-+-+-+-+-+
 *       |1|1|1|0|0| : Not implemented
 *       +-+-+-+-+-+
 *       |1|1|1|0|1| : Not implemented
 *       +-+-+-+-+-+
 *       |1|1|1|1|0| : Not implemented
 *       +-+-+-+-+-+
 *       |1|1|1|1|1| : Not implemented
 *       +-+-+-+-+-+
 * 
 * Most Arithmetic functions will be implemented with 
 * ALTERA MegaFunctions. Possibly will implement Floating Point opcodes in the future...
 * 
 */

endmodule
