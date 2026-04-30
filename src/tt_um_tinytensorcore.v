module tt_um_tinytensorcore (
	clk,
	ena,
	rst_n,
	ui_in,
	uio_in,
	uo_out,
	uio_out,
	uio_oe
);
	input wire clk;
	input wire ena;
	input wire rst_n;
	input wire [7:0] ui_in;
	input wire [7:0] uio_in;
	output wire [7:0] uo_out;
	output wire [7:0] uio_out;
	output wire [7:0] uio_oe;
	wire reset;
	assign reset = ~rst_n;
	wire [9:0] instruction;
	assign instruction = {uio_in[5:4], ui_in[7:0]};
	wire signed [11:0] tensor_output;
	tensor_core_controller tensor_core_ctrl(
		.clock_in(clk),
		.reset_in(reset),
		.current_instruction(instruction),
		.tensor_core_controller_output(tensor_output)
	);
	assign uo_out = tensor_output[7:0];
	assign uio_out = {4'b0000, tensor_output[11:8]};
	assign uio_oe = 8'b00001111;
endmodule
