module WB_decoder_unit ( // The write back decoder
	input wire [63:0] IR,
	input wire [63:0] old_IR,
	output reg        write_mem, // calculated from OLD IR
	output reg        write_reg,
	output reg  [5:0] reg_index,
	output reg        from_mem
);

initial begin
	write_mem = 1'b0;
	write_reg = 1'b0;
	from_mem  = 1'b0;
	reg_index = 6'b000000;
end

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

always @(old_IR[63:58]) begin
	if (old_IR[63:58] == 6'b000011) begin
		write_mem <= 1'b1;
	end else begin
		write_mem <= 1'b0;
	end
end

always @(IR[63:58],IR[57:52],IR[17:12]) begin
	if (IR[63:58] == ALU_CODE || IR[63:58] == LDI_CODE || IR[63:58] == MOV_CODE || IR[63:58] == LD_CODE) begin
		write_reg <= 1'b1;  // writing to register
	end else begin
		write_reg <= 1'b0;
	end
	if (IR[63:58] == LD_CODE) begin
		from_mem <= 1'b1;  // coming from memory
	end else begin
		from_mem <= 1'b0;
	end
	if (IR[63:58] == LDI_CODE) begin
		reg_index <= IR[57:52]; // this needint' be here if I designed my ISA a little better...
	end else begin
		reg_index <= IR[17:12];
	end
end

endmodule
