`timescale 1ns / 1ps
//==============================================================================
// tone_generator.v
//------------------------------------------------------------------------------
// Digital frequency-division module (Requirement 5).
//
// Generates a 50%-duty square wave whose frequency is set by 'half_period':
// the input clock is divided down by toggling the output every 'half_period'
// clock cycles, so   f_out = f_clk / (2 * half_period).
//
// When 'enable' is low (no key pressed) the output is forced low and the
// internal counter is held in reset, guaranteeing silence and zero LED
// activity (Requirement 4).
//==============================================================================
module tone_generator #(
    parameter integer CNT_WIDTH = 18   // 18 bits hold up to 262143 ( > 191110 )
)(
    input  wire                  clk,          // 100 MHz system clock
    input  wire                  rst,          // synchronous active-high reset
    input  wire                  enable,        // 1 = produce tone, 0 = silent
    input  wire [CNT_WIDTH-1:0]  half_period,  // clock cycles per half wave
    output reg                   wave           // square-wave output
);

    reg [CNT_WIDTH-1:0] counter;

    always @(posedge clk) begin
        if (rst || !enable) begin
            // Idle / reset state: silent output, counter cleared.
            counter <= {CNT_WIDTH{1'b0}};
            wave    <= 1'b0;
        end else if (counter >= half_period - 1'b1) begin
            // Reached one half-period: restart counter and toggle the wave.
            counter <= {CNT_WIDTH{1'b0}};
            wave    <= ~wave;
        end else begin
            counter <= counter + 1'b1;
        end
    end

endmodule
