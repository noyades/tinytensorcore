module tensor_core_register_file (
	clock_in,
	reset_in,
	dual_load_enable_in,
	dual_load_register_address_in,
	dual_load_data_in,
	bulk_store_data_out
);
	reg _sv2v_0;
	input wire clock_in;
	input wire reset_in;
	input wire dual_load_enable_in;
	input wire [3:0] dual_load_register_address_in;
	input wire signed [9:0] dual_load_data_in;
	output reg signed [89:0] bulk_store_data_out;
	reg signed [4:0] registers [0:17];
	always @(*) begin
		if (_sv2v_0)
			;
		begin : sv2v_autoblock_1
			reg signed [31:0] n;
			for (n = 0; n < 18; n = n + 1)
				bulk_store_data_out[(17 - n) * 5+:5] = registers[n];
		end
	end
	always @(posedge clock_in)
		if (reset_in) begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 18; i = i + 1)
				registers[i] <= 5'b00000;
		end
		else if (dual_load_enable_in) begin
			if (dual_load_register_address_in < 4'd9) begin : sv2v_autoblock_3
				reg signed [31:0] i;
				for (i = 0; i < 2; i = i + 1)
					registers[(dual_load_register_address_in << 1) + i] <= dual_load_data_in[(1 - i) * 5+:5];
			end
		end
	genvar _gv_generate_index_1;
	generate
		for (_gv_generate_index_1 = 0; _gv_generate_index_1 < 18; _gv_generate_index_1 = _gv_generate_index_1 + 1) begin : expose_regs
			localparam generate_index = _gv_generate_index_1;
			wire [4:0] reg_wire = registers[generate_index];
			wire [4:0] bulk_store_data_out_ = bulk_store_data_out[(17 - generate_index) * 5+:5];
		end
	endgenerate
	initial _sv2v_0 = 0;
endmodule
module tensor_core (
	clock_in,
	should_start_tensor_core,
	reset_in,
	tensor_core_input1,
	tensor_core_input2,
	tensor_core_output
);
	reg _sv2v_0;
	input wire clock_in;
	input wire should_start_tensor_core;
	input wire reset_in;
	input wire signed [44:0] tensor_core_input1;
	input wire signed [44:0] tensor_core_input2;
	output wire signed [107:0] tensor_core_output;
	reg [1:0] row_index;
	reg [1:0] column_index;
	reg signed [9:0] products_matrix_multiply [0:2];
	reg signed [11:0] intermediate_sum_matrix_multiply;
	wire signed [4:0] rolled_input1 [0:2][0:2];
	wire signed [4:0] rolled_input2 [0:2][0:2];
	reg signed [11:0] rolled_output [0:2][0:2];
	genvar _gv_generate_index_2;
	generate
		for (_gv_generate_index_2 = 0; _gv_generate_index_2 < 9; _gv_generate_index_2 = _gv_generate_index_2 + 1) begin : map_arrays
			localparam generate_index = _gv_generate_index_2;
			assign rolled_input1[generate_index / 3][generate_index % 3] = tensor_core_input1[(8 - generate_index) * 5+:5];
			assign rolled_input2[generate_index / 3][generate_index % 3] = tensor_core_input2[(8 - generate_index) * 5+:5];
			assign tensor_core_output[(8 - generate_index) * 12+:12] = rolled_output[generate_index / 3][generate_index % 3];
		end
	endgenerate
	function automatic [9:0] sv2v_cast_10;
		input reg [9:0] inp;
		sv2v_cast_10 = inp;
	endfunction
	function automatic [11:0] sv2v_cast_12;
		input reg [11:0] inp;
		sv2v_cast_12 = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		if ((row_index < 2'd3) && (column_index < 2'd3)) begin
			begin : sv2v_autoblock_1
				reg signed [31:0] k;
				for (k = 0; k < 3; k = k + 1)
					products_matrix_multiply[k] = sv2v_cast_10(rolled_input1[row_index][k]) * sv2v_cast_10(rolled_input2[k][column_index]);
			end
			intermediate_sum_matrix_multiply = (sv2v_cast_12(products_matrix_multiply[0]) + sv2v_cast_12(products_matrix_multiply[1])) + sv2v_cast_12(products_matrix_multiply[2]);
		end
		else begin
			begin : sv2v_autoblock_2
				reg signed [31:0] k;
				for (k = 0; k < 3; k = k + 1)
					products_matrix_multiply[k] = 10'd0;
			end
			intermediate_sum_matrix_multiply = 12'd0;
		end
	end
	always @(posedge clock_in)
		if (reset_in) begin
			row_index <= 2'd3;
			column_index <= 2'd0;
			begin : sv2v_autoblock_3
				reg signed [31:0] i;
				for (i = 0; i < 3; i = i + 1)
					begin : sv2v_autoblock_4
						reg signed [31:0] j;
						for (j = 0; j < 3; j = j + 1)
							rolled_output[i][j] <= 12'b000000000000;
					end
			end
		end
		else if (should_start_tensor_core == 1'd1) begin
			row_index <= 2'd0;
			column_index <= 2'd0;
		end
		else if (row_index < 2'd3) begin
			if (column_index == 2'd2) begin
				column_index <= 0;
				row_index <= row_index + 2'd1;
			end
			else
				column_index <= column_index + 2'd1;
			rolled_output[row_index][column_index] <= intermediate_sum_matrix_multiply;
		end
		else begin
			column_index <= column_index;
			row_index <= row_index;
		end
	initial _sv2v_0 = 0;
endmodule
module tensor_core_controller (
	clock_in,
	reset_in,
	current_instruction,
	tensor_core_controller_output
);
	input wire clock_in;
	input wire reset_in;
	input wire [9:0] current_instruction;
	output reg signed [11:0] tensor_core_controller_output;
	wire signed [89:0] tensor_core_register_file_bulk_store_data;
	wire signed [107:0] tensor_core_output;
	wire signed [44:0] tensor_core_input1;
	wire signed [44:0] tensor_core_input2;
	wire [2:0] opcode = current_instruction[2:0];
	wire signed [9:0] burst_current_dual_load_data;
	assign burst_current_dual_load_data[5+:5] = current_instruction[9:5];
	assign burst_current_dual_load_data[0+:5] = current_instruction[4:0];
	reg is_burst_state_machine_active;
	wire is_burst_load_store_active = is_burst_state_machine_active || (opcode == 3'b010);
	reg [3:0] burst_current_index;
	wire signed [11:0] burst_current_store_data = (burst_current_index < 4'd9 ? tensor_core_output[(8 - burst_current_index) * 12+:12] : 12'b000000000000);
	always @(posedge clock_in) tensor_core_controller_output <= (is_burst_load_store_active ? burst_current_store_data : 12'b000000000000);
	always @(posedge clock_in)
		if (reset_in == 1'b1) begin
			burst_current_index <= 4'd0;
			is_burst_state_machine_active <= 1'b0;
		end
		else if ((opcode == 3'b010) && (burst_current_index == 4'd0)) begin
			burst_current_index <= 4'd1;
			is_burst_state_machine_active <= 1'b1;
		end
		else if ((burst_current_index < 4'd9) && (burst_current_index != 4'd0))
			burst_current_index <= burst_current_index + 1'b1;
		else if (burst_current_index == 4'd9) begin
			burst_current_index <= 4'd0;
			is_burst_state_machine_active <= 1'b0;
		end
		else
			burst_current_index <= burst_current_index;
	tensor_core_register_file main_tensor_core_register_file(
		.clock_in(clock_in),
		.reset_in(reset_in),
		.dual_load_enable_in(is_burst_state_machine_active),
		.dual_load_register_address_in(burst_current_index - 4'd1),
		.dual_load_data_in(burst_current_dual_load_data),
		.bulk_store_data_out(tensor_core_register_file_bulk_store_data)
	);
	tensor_core main_tensor_core(
		.clock_in(clock_in),
		.reset_in(reset_in),
		.should_start_tensor_core((opcode == 3'b001) && !is_burst_load_store_active),
		.tensor_core_input1(tensor_core_input1),
		.tensor_core_input2(tensor_core_input2),
		.tensor_core_output(tensor_core_output)
	);
	genvar _gv_map_idx_1;
	generate
		for (_gv_map_idx_1 = 0; _gv_map_idx_1 < 9; _gv_map_idx_1 = _gv_map_idx_1 + 1) begin : route_bulk_store_to_inputs
			localparam map_idx = _gv_map_idx_1;
			assign tensor_core_input1[(8 - map_idx) * 5+:5] = tensor_core_register_file_bulk_store_data[(17 - map_idx) * 5+:5];
			assign tensor_core_input2[(8 - map_idx) * 5+:5] = tensor_core_register_file_bulk_store_data[(17 - (map_idx + 9)) * 5+:5];
		end
	endgenerate
	genvar _gv_i_1;
	genvar _gv_j_1;
	generate
		for (_gv_i_1 = 0; _gv_i_1 < 9; _gv_i_1 = _gv_i_1 + 1) begin : expose_regs
			localparam i = _gv_i_1;
			wire [11:0] tensor_core_output_wire = tensor_core_output[(8 - i) * 12+:12];
			wire [4:0] tensor_core_input1_wire = tensor_core_input1[(8 - i) * 5+:5];
			wire [4:0] tensor_core_input2_wire = tensor_core_input2[(8 - i) * 5+:5];
		end
	endgenerate
endmodule
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
	wire reset = ~rst_n;
	wire [9:0] instruction = {uio_in[5:4], ui_in[7:0]};
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
