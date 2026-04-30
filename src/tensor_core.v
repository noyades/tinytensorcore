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
	genvar _gv_generate_index_1;
	generate
		for (_gv_generate_index_1 = 0; _gv_generate_index_1 < 9; _gv_generate_index_1 = _gv_generate_index_1 + 1) begin : map_arrays
			localparam generate_index = _gv_generate_index_1;
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
