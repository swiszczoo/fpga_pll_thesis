module vco_sine #(
    parameter real FS = 1000000.0,
    parameter real CENTER_FREQUENCY = 10000.0,
    parameter real CONTROL_GAIN = 1000.0 // Hz per Volt
) (
    input                   clk_in,
    input                   data_ready_in,
    input signed [35:0]     voltage_in,     // Q4.32
    output                  data_ready_out,
    output signed [15:0]    sample_out,     // Q1.15
    output [15:0]           control_frequency_out
);
    parameter real PHASE_INCR_PER_HZ = real'(1.0) / FS;

    // For DDS control
    parameter real BASE_PHASE_INCR = CENTER_FREQUENCY * PHASE_INCR_PER_HZ * $pow(2, 32);
    parameter real CONTROL_GAIN_FACTOR = CONTROL_GAIN * PHASE_INCR_PER_HZ * $pow(2, 32);

    parameter [35:0] BASE_PHASE_INCR_FIXED = (BASE_PHASE_INCR);
    parameter [35:0] CONTROL_GAIN_FACTOR_FIXED = (CONTROL_GAIN_FACTOR);

    // For digital frequency output (Q20.16)
    parameter real BASE_PHASE_CTRL = CENTER_FREQUENCY * $pow(2, 16);
    parameter real CONTROL_GAIN_CTRL_FACTOR = CONTROL_GAIN * $pow(2, 16);

    parameter [35:0] BASE_PHASE_CTRL_FIXED = (BASE_PHASE_CTRL);
    parameter [35:0] CONTROL_GAIN_CTRL_FACTOR_FIXED = (CONTROL_GAIN_CTRL_FACTOR);

    // Q4.32
    logic [35:0] phase_incr_reg = 36'b0;
    logic [35:0] phase_incr_next;

    // Q20.16
    logic [35:0] control_frequency_reg = 36'b0;
    logic [35:0] control_frequency_next;

    // Q8.64
    logic signed [71:0] gain_result;

    // Q24.48
    logic signed [71:0] ctrl_result;

    mult_36x36_safe gain_mult (
        .CLK(clk_in),
        .A(CONTROL_GAIN_FACTOR_FIXED),
        .B(voltage_in),
        .P(gain_result)
    );

    mult_36x36_safe ctrl_mult (
        .CLK(clk_in),
        .A(CONTROL_GAIN_CTRL_FACTOR_FIXED),
        .B(voltage_in),
        .P(ctrl_result)
    );

    always_comb begin
        phase_incr_next = BASE_PHASE_INCR_FIXED + gain_result[67:32];
        control_frequency_next = BASE_PHASE_CTRL_FIXED + ctrl_result[67:32];
    end

    logic data_ready_q = 1'b0;
    logic data_ready_q2 = 1'b0;
    always_ff @(posedge clk_in) begin
        phase_incr_reg <= phase_incr_next;
        control_frequency_reg <= control_frequency_next;
        data_ready_q <= data_ready_in;
        data_ready_q2 <= data_ready_q;
    end

    dds_sine dds (
        .clk_in(clk_in),
        .data_ready_in(data_ready_q2),
        .phase_incr_in(phase_incr_reg),
        .data_ready_out(data_ready_out),
        .sample_out(sample_out)
    );

    assign control_frequency_out = control_frequency_reg[31:16];
endmodule
