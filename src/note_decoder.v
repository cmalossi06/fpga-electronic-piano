`timescale 1ns / 1ps
//==============================================================================
// note_decoder.v
//------------------------------------------------------------------------------
// Maps the 8 key inputs to the half-period count of the corresponding musical
// tone (Requirements 1 & 2). Each key drives one of the 8 standard tones of a
// C-major octave:
//
//   key[0] -> do  (C4, 261.63 Hz)      key[4] -> sol (G4, 392.00 Hz)
//   key[1] -> re  (D4, 293.66 Hz)      key[5] -> la  (A4, 440.00 Hz)
//   key[2] -> mi  (E4, 329.63 Hz)      key[6] -> si  (B4, 493.88 Hz)
//   key[3] -> fa  (F4, 349.23 Hz)      key[7] -> do' (C5, 523.25 Hz)
//
// The half-period counts are computed for a 100 MHz clock as
//   half_period = round( 100e6 / (2 * f) ) = round( 50e6 / f ).
//
// If several keys are active at once a fixed-priority scheme selects a single
// tone (key[0] = highest priority), so the output is always well defined and
// monophonic. 'active' is high only while at least one key is pressed.
//==============================================================================
module note_decoder (
    input  wire [7:0]  key,          // 8 key inputs (debounced/synchronised)
    output reg  [17:0] half_period,  // half-period count for tone_generator
    output reg         active         // 1 = a key is pressed
);

    // Half-period counts (clock cycles) for a 100 MHz reference clock.
    localparam [17:0] DO  = 18'd191110;  // C4  261.63 Hz
    localparam [17:0] RE  = 18'd170265;  // D4  293.66 Hz
    localparam [17:0] MI  = 18'd151685;  // E4  329.63 Hz
    localparam [17:0] FA  = 18'd143172;  // F4  349.23 Hz
    localparam [17:0] SOL = 18'd127551;  // G4  392.00 Hz
    localparam [17:0] LA  = 18'd113636;  // A4  440.00 Hz
    localparam [17:0] SI  = 18'd101239;  // B4  493.88 Hz
    localparam [17:0] DO2 = 18'd95557;   // C5  523.25 Hz

    always @(*) begin
        active = 1'b1;
        // Priority encoder: lowest index wins when multiple keys are held.
        casez (key)
            8'b???????1: half_period = DO;
            8'b??????10: half_period = RE;
            8'b?????100: half_period = MI;
            8'b????1000: half_period = FA;
            8'b???10000: half_period = SOL;
            8'b??100000: half_period = LA;
            8'b?1000000: half_period = SI;
            8'b10000000: half_period = DO2;
            default: begin
                half_period = DO;   // don't-care value while idle
                active      = 1'b0; // no key pressed -> silence
            end
        endcase
    end

endmodule
