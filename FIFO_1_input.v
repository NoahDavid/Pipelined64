module FIFO_1_input ( // FIFO with latency of 2 and one 64 bit input
	input wire clk,
	input wire [63:0] in,
	output reg [63:0] out
);

reg [63:0] hold;

initial begin
	hold = 64'h0000000000000000;
	out  = 64'h0000000000000000;
end

always @(posedge(clk)) begin
	hold <= in;
	out  <= hold;
end

endmodule
