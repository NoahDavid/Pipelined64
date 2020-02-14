module PC_stage ( // Pipeline stage containing the Program Counter
	input wire clk,
	input wire mux_ctrl,
	input wire [63:0] branch_addr,
	output reg [63:0] PC
);

wire [63:0] PC_add8;

initial PC = 64'h0000000000000000;  // Start Address

assign PC_add8[63:0] = PC[63:0] + 64'h0000000000000008;

always @(posedge(clk)) begin
	if (mux_ctrl) begin
		PC <= branch_addr;
	end else begin
		PC <= PC_add8;
	end
end

endmodule
