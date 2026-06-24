module iir_filter #(
    // all parameters are in Q4.32 format
    parameter real B0 = 1.0,
    parameter real B1 = 0.0,
    parameter real B2 = 0.0,
    parameter real A1 = 0.0,
    parameter real A2 = 0.0
)(
    input                   clk_in,
    input                   data_ready_in,
    input signed [35:0]     signal_in, // Q4.32
    output                  data_ready_out,
    output signed [35:0]    signal_out // Q4.32
);
    parameter [35:0] B0_FIXED = B0 * $pow(2, 32);
    parameter [35:0] B1_FIXED = B1 * $pow(2, 32);
    parameter [35:0] B2_FIXED = B2 * $pow(2, 32);
    parameter [35:0] A1_FIXED = A1 * $pow(2, 32);
    parameter [35:0] A2_FIXED = A2 * $pow(2, 32);

    // Q4.32
    var logic signed [35:0] in_history_0 = 36'b0;
    var logic signed [35:0] in_history_1 = 36'b0;
    var logic signed [35:0] in_history_2 = 36'b0;
    var logic signed [35:0] out_history_1 = 36'b0;
    var logic signed [35:0] out_history_2 = 36'b0;

    // Q4.32
    var logic signed [35:0] signal_out_reg;

    // Q8.64
    wire signed [71:0] b0_result;
    wire signed [71:0] b1_result;
    wire signed [71:0] b2_result;
    wire signed [71:0] a1_result;
    wire signed [71:0] a2_result;

    // Q4.32
    wire signed [35:0] signal_out_next = b0_result[67:32] + b1_result[67:32] + b2_result[67:32] + a1_result[67:32] + a2_result[67:32];


    mult_36x36_safe mult_b0(
        .CLK(clk_in),
        .A(B0_FIXED),
        .B(signal_in),
        .P(b0_result)
    );

    mult_36x36_safe mult_b1(
        .CLK(clk_in),
        .A(B1_FIXED),
        .B(in_history_1),
        .P(b1_result)
    );

    mult_36x36_safe mult_b2(
        .CLK(clk_in),
        .A(B2_FIXED),
        .B(in_history_2),
        .P(b2_result)
    );

    mult_36x36_safe mult_a1(
        .CLK(clk_in),
        .A(A1_FIXED),
        .B(out_history_1),
        .P(a1_result)
    );

    mult_36x36_safe mult_a2(
        .CLK(clk_in),
        .A(A2_FIXED),
        .B(out_history_2),
        .P(a2_result)
    );

    logic data_ready_q = 1'b0;
    logic data_ready_q2 = 1'b0;
    logic data_ready_q3 = 1'b0;

    always @(posedge clk_in) begin
        if (data_ready_in) begin
            in_history_0 <= signal_in;
            in_history_1 <= in_history_0;
            in_history_2 <= in_history_1;
            out_history_1 <= signal_out_next;
            out_history_2 <= out_history_1;
        end

        signal_out_reg <= signal_out_next;
        data_ready_q <= data_ready_in;
        data_ready_q2 <= data_ready_q;
        data_ready_q3 <= data_ready_q2;
    end

    assign signal_out = signal_out_reg;
    assign data_ready_out = data_ready_q3;
endmodule
