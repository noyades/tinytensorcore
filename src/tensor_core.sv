

module tensor_core (
    input logic clock_in,
    input logic should_start_tensor_core,
    input logic reset_in,

    input logic signed [4:0] tensor_core_input1 [9], 
    input logic signed [4:0] tensor_core_input2 [9],

    output logic signed [11:0] tensor_core_output [9]
);


    logic [1:0] row_index;
    logic [1:0] column_index;


    logic signed [9:0] products_matrix_multiply [3];
    logic signed [11:0] intermediate_sum_matrix_multiply;


    logic signed [4:0]  rolled_input1 [3][3];
    logic signed [4:0]  rolled_input2 [3][3];
    logic signed [11:0] rolled_output [3][3];

    genvar generate_index;
    generate
        for (generate_index = 0; generate_index < 9; generate_index++) begin : map_arrays
            
            assign rolled_input1[generate_index/3][generate_index%3] = tensor_core_input1[generate_index];
            assign rolled_input2[generate_index/3][generate_index%3] = tensor_core_input2[generate_index];
            assign tensor_core_output[generate_index]  = rolled_output[generate_index/3][generate_index%3];
        end
    endgenerate


    always_comb begin

        if (row_index < 2'd3 && column_index < 2'd3) begin
            for (int k = 0; k < 3; k++) begin
                products_matrix_multiply[k] = 10'(rolled_input1[row_index][k]) * 10'(rolled_input2[k][column_index]);
            end

            intermediate_sum_matrix_multiply = 12'(products_matrix_multiply[0]) + 12'(products_matrix_multiply[1]) + 12'(products_matrix_multiply[2]);
        end
        else begin
            for (int k = 0; k < 3; k++) begin
                products_matrix_multiply[k] = 10'd0;
            end

            intermediate_sum_matrix_multiply = 12'd0;
        end
    end



    always_ff @(posedge clock_in) begin

        if (reset_in) begin
            row_index <= 2'd3;
            column_index <= 2'd0;

            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 3; j++) begin
                    rolled_output[i][j] <= 12'b0;
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

            else begin
                column_index <= column_index + 2'd1;
            end

            rolled_output[row_index][column_index] <= intermediate_sum_matrix_multiply;
        end


        else begin
            column_index <= column_index;
            row_index <= row_index;
        end
    end

endmodule
