module dds_sine (
    input                   clk_in,
    input                   data_ready_in,
    input [35:0]            phase_incr_in,  // Q4.32
    output                  data_ready_out,
    output signed [15:0]    sample_out      // Q1.15
);
    logic [9:0] lut_addr;

    logic signed [15:0] lut_value;
    wire signed [15:0] lut_value_neg = -lut_value;

    blk_mem_sine_lut lut (
        .clka(clk_in),
        .ena(1'b1),
        .wea(1'b0),
        .addra(lut_addr),
        .dina(16'b0),
        .douta(lut_value)
    );

    logic [35:0] phase_accumulator = 36'b0;
    logic [35:0] phase_accumulator_next;
/*

        ---  2 | 3
       / | \   |
    --/-----\-----/
         |   \ | /
       0 | 1  ---

*/

    wire [1:0] sine_phase = phase_accumulator[31:30];
    logic [1:0] sine_phase_q = 2'b00;
    wire [9:0] lut_bits = phase_accumulator[29:20];

    always_comb begin
        case (sine_phase)
        2'b00: lut_addr = lut_bits;     // <0; pi/2)
        2'b01: lut_addr = ~lut_bits;    // <pi/2; pi)
        2'b10: lut_addr = lut_bits;     // <pi; 3pi/2)
        2'b11: lut_addr = ~lut_bits;    // <3pi/2; 2pi)
        default: lut_addr = lut_bits;
        endcase
    end

    logic [15:0] sample_reg = 16'b0;
    logic [15:0] sample_next;

    always_comb begin
        phase_accumulator_next = phase_accumulator + phase_incr_in;

        case (sine_phase)
        2'b00: sample_next = lut_value;
        2'b01: sample_next = lut_value;
        2'b10: sample_next = lut_value_neg;
        2'b11: sample_next = lut_value_neg;
        default: sample_next = lut_value;
        endcase
    end

    logic data_ready_q = 1'b0;
    logic data_ready_q2 = 1'b0;
    logic data_ready_q3 = 1'b0;
    logic data_ready_q4 = 1'b0;
    always_ff @(posedge clk_in) begin
        if (data_ready_in) begin
            phase_accumulator <= phase_accumulator_next;
        end

        if (data_ready_q3) begin
            sample_reg <= sample_next;
        end

        sine_phase_q <= sine_phase;

        data_ready_q <= data_ready_in;
        data_ready_q2 <= data_ready_q;
        data_ready_q3 <= data_ready_q2;
        data_ready_q4 <= data_ready_q3;
    end

    assign sample_out = sample_reg;
    assign data_ready_out = data_ready_q4;
endmodule
