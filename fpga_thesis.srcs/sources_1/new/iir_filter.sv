module iir_filter #(
    // all parameters are in Q4.32 format
    parameter [35:0] B0 = 36'b000100000000000000000000000000000000,
    parameter [35:0] B1 = 36'b000000000000000000000000000000000000,
    parameter [35:0] B2 = 36'b000000000000000000000000000000000000,
    parameter [35:0] A1 = 36'b000000000000000000000000000000000000,
    parameter [35:0] A2 = 36'b000000000000000000000000000000000000
)(
    input                   clk_in,
    input signed [35:0]     signal_in, // Q4.32
    output signed [35:0]    signal_out // Q4.32
);
    // Q4.32
    var logic signed [35:0] in_history_0 = 36'b0;
    var logic signed [35:0] in_history_1 = 36'b0;
    var logic signed [35:0] in_history_2 = 36'b0;
    var logic signed [35:0] out_history_1 = 36'b0;

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
        .A(B0),
        .B(in_history_0),
        .P(b0_result)
    );

    mult_36x36_safe mult_b1(
        .CLK(clk_in),
        .A(B1),
        .B(in_history_1),
        .P(b1_result)
    );

    mult_36x36_safe mult_b2(
        .CLK(clk_in),
        .A(B2),
        .B(in_history_2),
        .P(b2_result)
    );

    mult_36x36_safe mult_a1(
        .CLK(clk_in),
        .A(A1),
        .B(signal_out_next),
        .P(a1_result)
    );

    mult_36x36_safe mult_a2(
        .CLK(clk_in),
        .A(A2),
        .B(out_history_1),
        .P(a2_result)
    );

    always @(posedge clk_in) begin
        signal_out_reg <= signal_out_next;
        in_history_0 <= signal_in;
        in_history_1 <= in_history_0;
        in_history_2 <= in_history_1;
        out_history_1 <= signal_out_next;
    end

    assign signal_out = signal_out_reg;
endmodule
