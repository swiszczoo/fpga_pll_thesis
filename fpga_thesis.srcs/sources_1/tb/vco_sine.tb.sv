`timescale 1ns / 1ns
module tb_vco_sine(
    output [15:0] sample_out,
    output [15:0] control_frequency_out
);
    var bit clk_state = 1'b0;
    var bit [35:0] voltage_state = 36'b0;

    vco_sine #(
        .FS(500000), // 500 kHz
        .CENTER_FREQUENCY(10000), // 10 kHz
        .CONTROL_GAIN(10000) // 10 kHz
    ) uut (
        .clk_in(clk_state),
        .voltage_in(voltage_state),
        .sample_out(sample_out),
        .control_frequency_out(control_frequency_out)
    );

    initial begin
        forever begin
            clk_state = 1'b1;
            #1;
            clk_state = 1'b0;
            #1;
        end
    end

    initial begin
        voltage_state = 36'h000000000;
        #100;
        voltage_state = 36'h100000000;
        #200;
        voltage_state = 36'hf00000000;
        #200;
        $stop;
    end
endmodule
