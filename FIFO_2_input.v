module FIFO_2_input ( // FIFO with latency of 2 and two 64 bit inputs
	input wire clk,
	input wire [63:0] in_1,
	input wire [63:0] in_2,
	output reg [63:0] out_1,
	output reg [63:0] out_2
);

reg [63:0] hold_1;
reg [63:0] hold_2;

initial begin
	hold_1 = 64'h0000000000000000;
	out_1  = 64'h0000000000000000;
	hold_2 = 64'h0000000000000000;
	out_2  = 64'h0000000000000000;
end

always @(posedge(clk)) begin
	hold_1 <= in_1;
	out_1  <= hold_1;
	hold_2 <= in_2;
	out_2  <= hold_2;
end

endmodule
