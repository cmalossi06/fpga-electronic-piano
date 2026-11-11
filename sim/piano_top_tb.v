`timescale 1ns / 1ps
//==============================================================================
// piano_top_tb.v
//------------------------------------------------------------------------------
// Self-checking testbench for the 8-note electronic piano.
//
//   * Plays each of the 8 keys in turn and measures the output period, checking
//     it against the target musical frequency (Requirements 1, 2, 5).
//   * Verifies that buzzer and LED stay silent/off with no key pressed (Req. 4)
//     and that the LED tracks the buzzer exactly (Req. 3).
//   * Verifies the multi-key priority behaviour of the decoder.
//
// A 100 MHz clock (10 ns period) is used, matching the Nexys A7 board.
//==============================================================================
module piano_top_tb;

    reg        clk;
    reg        rst;
    reg  [7:0] swt;
    wire       buzzer;
    wire       led;

    integer    errors = 0;

    // Device under test.
    piano_top dut (
        .clk    (clk),
        .rst    (rst),
        .swt    (swt),
        .buzzer (buzzer),
        .led    (led)
    );

    // 100 MHz clock.
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Target frequencies (Hz) for the readable report in the log.
    real target_hz [0:7];
    initial begin
        target_hz[0] = 261.63; target_hz[1] = 293.66;
        target_hz[2] = 329.63; target_hz[3] = 349.23;
        target_hz[4] = 392.00; target_hz[5] = 440.00;
        target_hz[6] = 493.88; target_hz[7] = 523.25;
    end

    //--------------------------------------------------------------------------
    // Measure one full output period (rising edge to rising edge) and compare
    // the resulting frequency to the target tone for the given key index.
    //--------------------------------------------------------------------------
    task play_and_check(input integer idx);
        real t1, t2, period_ns, meas_hz;
        begin
            swt = (8'b1 << idx);
            // Let the synchroniser propagate and the first edge settle.
            @(posedge buzzer);
            t1 = $realtime;
            @(posedge buzzer);
            t2 = $realtime;
            period_ns = t2 - t1;
            meas_hz   = 1.0e9 / period_ns;
            if ((meas_hz > target_hz[idx]*0.999) &&
                (meas_hz < target_hz[idx]*1.001)) begin
                $display("  [PASS] key[%0d]: target %7.2f Hz, measured %7.2f Hz (period %0.0f ns)",
                         idx, target_hz[idx], meas_hz, period_ns);
            end else begin
                $display("  [FAIL] key[%0d]: target %7.2f Hz, measured %7.2f Hz",
                         idx, target_hz[idx], meas_hz);
                errors = errors + 1;
            end
            swt = 8'b0;
            repeat (50) @(posedge clk);   // brief gap between notes
        end
    endtask

    // Continuous check: the LED must always equal the buzzer (Req. 3).
    always @(posedge clk) begin
        if (!rst && (led !== buzzer)) begin
            $display("  [FAIL] LED does not track buzzer at t=%0t", $realtime);
            errors = errors + 1;
        end
    end

    integer i;
    integer high_count;
    initial begin
        $dumpfile("piano_top_tb.vcd");
        $dumpvars(0, piano_top_tb);

        // Reset.
        swt = 8'b0;
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
        @(posedge clk);

        // -------- Requirement 4: silence when no key is pressed -----------
        $display("Test 1 - silence with no key pressed:");
        high_count = 0;
        for (i = 0; i < 100000; i = i + 1) begin
            @(posedge clk);
            if (buzzer || led) high_count = high_count + 1;
        end
        if (high_count == 0)
            $display("  [PASS] buzzer and LED stayed low for 100000 cycles");
        else begin
            $display("  [FAIL] output was active %0d cycles with no key", high_count);
            errors = errors + 1;
        end

        // -------- Requirements 1, 2, 5: correct tone per key --------------
        $display("Test 2 - tone frequency for each of the 8 keys:");
        for (i = 0; i < 8; i = i + 1)
            play_and_check(i);

        // -------- Multi-key priority (decoder is monophonic) --------------
        $display("Test 3 - priority when several keys are held (expect 'do'):");
        // Hold keys 7,4,0 simultaneously -> lowest index (do) must win.
        swt = 8'b10010001;
        begin : prio_block
            real t1, t2, mhz;
            @(posedge buzzer); t1 = $realtime;
            @(posedge buzzer); t2 = $realtime;
            mhz = 1.0e9 / (t2 - t1);
            if (mhz > target_hz[0]*0.999 && mhz < target_hz[0]*1.001)
                $display("  [PASS] priority selected 'do' (%0.2f Hz)", mhz);
            else begin
                $display("  [FAIL] priority gave %0.2f Hz, expected ~261.63 Hz", mhz);
                errors = errors + 1;
            end
        end
        swt = 8'b0;
        repeat (50) @(posedge clk);

        // -------- Summary -------------------------------------------------
        $display("--------------------------------------------------");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d TEST(S) FAILED", errors);
        $finish;
    end

endmodule
