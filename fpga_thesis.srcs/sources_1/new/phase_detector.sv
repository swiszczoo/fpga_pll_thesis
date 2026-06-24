module phase_detector (
    input                   clk_in,
    input                   data_ready_in,
    input signed [15:0]     ref_in,         //Q1.15
    input signed [15:0]     vco_in,         //Q1.15
    output                  data_ready_out,
    output signed [31:0]    pd_error_out    //Q2.30
);
    wire signed [31:0] mixer_out;
    mult_16x16 mixer(
        .CLK(clk_in),
        .A(ref_in),
        .B(vco_in),
        .P(mixer_out)
    );

    logic [31:0] mixer_out_q = 32'b0;

    assign pd_error_out = mixer_out_q * 2;

    logic data_ready_q = 1'b0;
    logic data_ready_q2 = 1'b0;
    always_ff @(posedge clk_in) begin
        if (data_ready_q) begin
            mixer_out_q <= mixer_out;
        end

        data_ready_q <= data_ready_in;
        data_ready_q2 <= data_ready_q;
    end

    assign data_ready_out = data_ready_q2;
endmodule
