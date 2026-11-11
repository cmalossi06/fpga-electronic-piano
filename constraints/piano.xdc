## piano.xdc - constraints for the 8-note electronic piano
## Target board: Digilent Nexys A7 (Artix-7, same pinout as Nexys4 DDR)
## Only the pins actually used by the design are enabled. Port names match the
## top-level signals of piano_top.v.

## ---------------------------------------------------------------------------
## 100 MHz system clock
## ---------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

## ---------------------------------------------------------------------------
## Reset push button (BTNC, active high)
## ---------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { rst }];

## ---------------------------------------------------------------------------
## 8 key inputs (slide switches SW0..SW7)
##   swt[0]=do  swt[1]=re  swt[2]=mi  swt[3]=fa
##   swt[4]=sol swt[5]=la  swt[6]=si  swt[7]=high do
## ---------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports { swt[0] }];
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports { swt[1] }];
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { swt[2] }];
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { swt[3] }];
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports { swt[4] }];
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports { swt[5] }];
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { swt[6] }];
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 } [get_ports { swt[7] }];

## ---------------------------------------------------------------------------
## Indicator LED (LED0) - flashes synchronously with the tone
## ---------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { led }];

## ---------------------------------------------------------------------------
## Buzzer output on Pmod header JA, pin JA1 (top row, pin 1).
## Connect a PASSIVE buzzer / piezo speaker between JA1 and an adjacent GND pin.
## (An active buzzer ignores the frequency and only beeps, so use a passive one.)
## ---------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVCMOS33 } [get_ports { buzzer }];
