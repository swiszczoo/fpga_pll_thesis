`timescale 1ns / 1ns
module tb_iir_filter (
    output [35:0]  filter_in, // Q4.32
    output [35:0]  filter_out // Q4.32
);
    var bit clk_state = 1'b0;
    var bit [35:0] signal_in_state = 36'b0;

    iir_filter #(
        .B0         (36'h0000001ca),
        .B1         (36'h000000394),
        .B2         (36'h0000001ca),
        .A1         (36'h1ffc36fd6),
        .A2         (36'hf003c88f2)
    ) uut (
        .clk_in     (clk_state),
        .signal_in  (signal_in_state),
        .signal_out (filter_out)
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
        forever begin
            signal_in_state = 36'h000000000;
            #10000;
            signal_in_state = 36'h100000000;
            #90000;
        end
    end

    initial begin
        #100000;
        $stop;
    end

    assign filter_in = signal_in_state;
endmodule
