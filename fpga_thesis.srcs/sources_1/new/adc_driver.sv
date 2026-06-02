`include "vivado_interfaces.svh"

// sample rate is 961538 Hz
module adc_driver (
    input           clk_in,
    input           pos_in,
    input           neg_in,
    output          data_ready_out,
    output [11:0]   last_sample_out
);
    parameter VALUE_REG = 7'h11; // VAUXP[1]/VAUXN[1]

    typedef enum logic [1:0] {
        DRP_WAIT_FOR_EOC,
        DRP_INIT,
        DRP_WAIT_FOR_DRDY
    } drp_state;

    drp_state current_state = DRP_WAIT_FOR_EOC;
    drp_state next_state;

    logic [11:0] current_value = 12'b0;
    logic [11:0] next_value;

    logic current_data_ready = 1'b0;
    logic next_data_ready;

    wire den_in = current_state == DRP_INIT;
    wire drdy_out;
    wire [15:0] do_out;
    wire eoc_out;

    xadc_wiz_0 adc_instance (
        .di_in(16'b0), // input wire [15:0] di_in
        .daddr_in(VALUE_REG), // input wire [6:0] daddr_in
        .den_in(den_in), // input wire den_in
        .dwe_in(1'b0), // input wire dwe_in
        .drdy_out(drdy_out), // output wire drdy_out
        .do_out(do_out), // output wire [15:0] do_out
        .dclk_in(clk_in), // input wire dclk_in
        .reset_in(1'b0), // input wire reset_in
        .vp_in(1'b0), // input wire vp_in
        .vn_in(1'b0), // input wire vn_in
        .vauxp1(pos_in), // input wire vauxp1
        .vauxn1(neg_in), // input wire vauxn1
        .channel_out(), // output wire [4:0] channel_out
        .eoc_out(eoc_out), // output wire eoc_out
        .alarm_out(), // output wire alarm_out
        .eos_out(), // output wire eos_out
        .busy_out() // output wire busy_out
    );

    always_comb begin
        case (current_state)
        DRP_WAIT_FOR_EOC: begin
            if (eoc_out) next_state = DRP_INIT;
            else next_state = DRP_WAIT_FOR_EOC;
            next_value = current_value;
            next_data_ready = 1'b0;
        end
        DRP_INIT: begin
            next_state = DRP_WAIT_FOR_DRDY;
            next_value = current_value;
            next_data_ready = 1'b0;
        end
        DRP_WAIT_FOR_DRDY: begin
            if (drdy_out) begin
                next_state = DRP_WAIT_FOR_EOC;
                next_value = do_out[15:4];
                next_data_ready = 1'b1;
            end else begin 
                next_state = DRP_WAIT_FOR_DRDY;
                next_value = current_value;
                next_data_ready = 1'b0;
            end
        end
        default: begin
            next_state = DRP_INIT;
            next_value = current_value;
            next_data_ready = 1'b0;
        end
        endcase
    end

    always_ff @(posedge clk_in) begin
        current_state <= next_state;
        current_value <= next_value;
        current_data_ready <= next_data_ready;
    end

    assign data_ready_out = current_data_ready;
    assign last_sample_out = current_value;
endmodule
