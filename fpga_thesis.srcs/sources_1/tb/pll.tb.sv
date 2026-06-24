`define iir_b0 2.2059436460686298e-05
`define iir_b1 4.4118872921372596e-05
`define iir_b2 2.2059436460686298e-05
`define iir_a1 1.9866715465479383
`define iir_a2 -0.9867597842937811

`timescale 1ns / 10ps
module tb_pll(
    output [15:0] sig_ref_in,
    output [15:0] vco_frequency_out
);
    var bit clk_state = 1'b0;
    var bit data_ready_state = 1'b0;
    var bit signed [15:0] ref_signal = 16'b0;

    const real generator_frequency = 9500.0;
    const real pi = 3.14159;

    pll #(
        .FS(500000), // 500 kHz
        .CENTER_FREQUENCY(10000), // 10 kHz
        .CONTROL_GAIN(2000), // 2 kHz

        .B0(`iir_b0 * $pow(2, 32)),
        .B1(`iir_b1 * $pow(2, 32)),
        .B2(`iir_b2 * $pow(2, 32)),
        .A1(`iir_a1 * $pow(2, 32)),
        .A2(`iir_a2 * $pow(2, 32))
    ) uut (
        .clk_in(clk_state),
        .data_ready_in(data_ready_state),
        .sig_ref_in(ref_signal),
        .vco_frequency_out(vco_frequency_out)
    );

    assign sig_ref_in = ref_signal;

    initial begin
        clk_state = 1'b0;
        forever #(0.05) clk_state = !clk_state;
    end

    initial begin
        forever begin
            @(posedge clk_state);
            data_ready_state <= 1'b1;
            @(posedge clk_state);
            data_ready_state <= 1'b0;
            for (int i = 0; i < 18; i++) @(posedge clk_state);
        end
    end

    initial begin
        real current_phase = 0.0;
        const real phase_increment = 2 * pi * generator_frequency / 500000.0;

        forever begin
            current_phase += phase_increment;
            if (current_phase > 2 * pi) begin
                current_phase -= 2 * pi;
            end

            ref_signal = $sin(current_phase) * ($pow(2, 15) - 1.0);
            #2;
        end
    end
endmodule
