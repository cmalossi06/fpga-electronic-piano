# Functional simulation with Icarus Verilog
#   make sim    compile and run the self-checking testbench
#   make wave   open the waveform dump in GTKWave
#   make clean  remove generated files

SRC = src/piano_top.v src/note_decoder.v src/tone_generator.v
TB  = sim/piano_top_tb.v
OUT = build

sim: $(OUT)/tb.vvp
	cd $(OUT) && vvp -n tb.vvp

$(OUT)/tb.vvp: $(SRC) $(TB)
	mkdir -p $(OUT)
	iverilog -g2012 -o $@ $(TB) $(SRC)

wave: sim
	gtkwave $(OUT)/piano_top_tb.vcd &

clean:
	rm -rf $(OUT)

.PHONY: sim wave clean
