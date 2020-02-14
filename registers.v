module registers ( // Register pipeline stage
	input wire clk,
	input wire [63:0] IR,
	input wire [63:0] PC,
	input wire        write_en,
	input wire [5:0]  write_index,
	input wire [63:0] write_data,
	output reg [63:0] ALU_A,
	output reg [63:0] ALU_B,
	output reg [63:0] dest_reg_value,
	output reg [63:0] reg_when_imm,
	output reg [63:0] imm,
	output reg [63:0] IR_out
);

// Immediate Instruction Format:
// 63   58 57   52 51                      4 3     0
// +------+-------+-------------------------+-------+
// | ID 6 | REG 6 |          ADDR           | SHIFT |
// +------+-------+-------------------------+-------+

// Regular   Instruction Format:
// 63    58 57     23 22   18 17    12 11     6 5      0
// +-------+---------+-------+--------+--------+--------+
// | ID 6  | Nothing | ALU 5 | REGD 6 | REG1 6 | REG2 6 |
// +-------+---------+-------+--------+--------+--------+

reg [63:0] regs [0:63];
integer i;

initial begin
	for (i = 0; i < 64; i = i + 1) begin
		regs[i] = 64'h0000000000000000;
	end
end

wire [63:0] calculated_imm;

imm_shifter shifter({{(17){1'b0}},IR[51:5]}, IR[4:0], calculated_imm); // This is an Altera IP.

initial ALU_A          = 64'h0000000000000000;
initial ALU_B          = 64'h0000000000000000;
initial dest_reg_value = 64'h0000000000000000;
initial imm            = 64'h0000000000000000;
initial IR_out         = 64'h0000000000000000;

always @(posedge(clk)) begin
	if (IR[11:6] != 6'b111111) begin
		ALU_A  <= regs[IR[11:6]];
	end else begin
		ALU_A  <= PC;
	end
	if (IR[5:0] != 6'b111111) begin
		ALU_B  <= regs[IR[5:0]];
	end else begin
		ALU_B  <= PC;
	end
	if (IR[17:12] != 6'b111111) begin
		dest_reg_value  <= regs[IR[17:12]];
	end else begin
		dest_reg_value  <= PC;
	end
	if (IR[57:52] != 6'b111111) begin
		reg_when_imm <= regs[IR[57:52]];
	end else begin
		reg_when_imm <= PC;
	end
	if (write_en) begin
		regs[write_index] <= write_data;
	end
	imm    <= calculated_imm;
	IR_out <= IR;
end

endmodule
