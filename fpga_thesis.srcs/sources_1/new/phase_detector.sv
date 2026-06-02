module phase_detector (
    input                   clk_in,
    input signed [15:0]     ref_in,         //Q1.15
    input signed [15:0]     vco_in,         //Q1.15
    output signed [31:0]    pd_error_out    //Q2.30
);
    wire signed [31:0] mixer_out;
    mult_16x16 mixer(
        .CLK(clk_in),
        .A(ref_in),
        .B(vco_in),
        .P(mixer_out)
    );

    assign pd_error_out = mixer_out * 2;
endmodule
