module write_back_stage ( // Last stage in the pipeline. 
    input wire clk,
    input wire  [63:0] IR,
    input wire  [63:0] IR_old,
    input wire  [63:0] mem_out,
    input wire  [63:0] mem_in,
    output reg  [63:0] reg_wb_data,
    output wire        reg_wb_en,
    output wire [5:0]  reg_wb_index,
    output wire        dat_wb_en
);

wire from_mem;

initial begin
    reg_wb_data = 64'h0000000000000000;
end

always @(mem_out, mem_in, from_mem) begin
    if (from_mem) begin
        reg_wb_data <= mem_out;
    end else begin
        reg_wb_data <= mem_in;
    end
end

WB_decoder_unit decoder(IR, IR_old, dat_wb_en, reg_wb_en, reg_wb_index, from_mem);

endmodule
