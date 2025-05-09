## Team members

* Pavlov Ivan(247158) (responsible for creating clock_counter and display_multiplex)
* Oleinik Ruslan(253232) (responsible for creating top level and editing xdc)
* Pryimak Yevhenii(256562) (responsible for testing simulations and github editing)
* Shvedenko Konstantin(253002) (responsible for creating stopwatch and pptx-presentation)


#Hardware description of demo application

## Easy Instruction for using our digital clock with stopwatch
![Show](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Images/Show.PNG)

## Video where our digital clock is simple running in project's previous iteration (with 1Hz blue blinker and without stopwatch and point between HH.MM.SS)
https://youtube.com/shorts/wwK6do2oKpY?feature=share

## RTL-Schematic
![Schema](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Images/Top_level_RTL.png)
There we can see logic of our project

## Software description
[src/](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1)

--[bin2seg.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/bin2seg.vhd)

--[clk_en.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/clk_en.vhd)

--[debounce.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/debounce.vhd)

--[clock_counter.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/clock_counter.vhd)

--[display_mux.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/display_mux.vhd)

--[stopwatch.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/stopwatch.vhd)

--[top_level.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/top_level.vhd)

## Component(s) simulations
[sim/](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sim_1)

--[tb_clock_counter.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sim_1/new/tb_clock_counter.vhd)

--[tb_display_mux.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sim_1/new/tb_display_mux.vhd)

--[tb_stopwatch.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sim_1/new/tb_stopwatch.vhd)

--[tb_top_level.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sim_1/new/tb_top_level.vhd)

### Sources Description
  ## [bin2seg.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/bin2seg.vhd)

  Was taken from the Tomas-Fryza's github. One-digit binary-to-7-segment decoder for a common-anode display. It maps a 4-bit hexadecimal input to the corresponding active- 
  low segment pattern (0–9, A–F), and forces all segments off when the clear input is asserted display_muxnexys-a7-50t

  ## [clk_en.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/clk_en.vhd)
  
  Was taken from the Tomas-Fryza's github. A reusable clock-enable generator that counts up to a parameterized number of main-clock cycles and emits a one-cycle-wide pulse 
  each time the count wraps.
  
  ## [clock_counter.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/clock_counter.vhd)

  A real-time clock counter with supporting RUN mode and three SET modes (hours, minutes, seconds). In RUN, it advances time on each 1 Hz pulse; in SET, it lets the user 
  select a field (with SEL) and increment it (with INC), toggling in and out of SET via the SET button 
  
  ## [debounce.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/debounce.vhd)

  Was taken from the Tomas-Fryza's github. Implements a fully synchronous button debouncer. This ensures reliable, glitch-free button presses for all user inputs 
  
  ## [display_mux.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/display_mux.vhd)

  Drives a multiplexed six-digit (HH:MM:SS) 7-segment display by first converting each 6-bit time value into two BCD digits, then cycling through digits at a ~1 kHz scan 
  rate. For each digit, it selects the corresponding anode enable pattern and feeds the 4-bit BCD to a bin2seg decoder, generating active-low segment outputs and decimal- 
  point control.
  
  ## [stopwatch.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/stopwatch.vhd)

  A simple HH:MM:SS stopwatch with three states (IDLE, RUN, PAUSE). On each 1 Hz enable pulse, it increments seconds -> minutes -> hours with proper roll- 
  over, toggles between RUN and PAUSE on a start button edge, and resets to zero on a reset button edge
  
  ## [top_level.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/top_level.vhd)

  Wires everything together: debounces all five buttons with debouncer, generates en_1 Hz and en_1 kHz pulses, multiplexes between Clock and Stopwatch modes via 
  MODE button, gates the other buttons depending on mode, instantiates the clock counter or stopwatch, and drives the display_mux.

### Simulation Description
## [tb_clock_counter.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sim_1/new/tb_clock_counter.vhd)
![Show](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Images/tb_clock_counter.png)

In this simulation we can see seconds are going with every en_1hz (which is actually 1s), minutes and hours are changings after we pushed button "select" -> button "increment"
## [tb_display_mux.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sim_1/new/tb_display_mux.vhd)
![Show](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Images/tb_display_mux.png)

In this simulation we can see that display shows correctly 7-segments digits
## [tb_stopwatch.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sim_1/new/tb_stopwatch.vhd)
![Show](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Images/tb_stopwatch.png)

In this simulation we can see that after we pushed "start" button our stopwatch is actually starting running
## [tb_top_level.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sim_1/new/tb_top_level.vhd)
![Show](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Images/tb_top_level.png)

In this simulation we can see that after we pushed "mode" button and select stopwatch mode we will push "start" button that will run our stopwatch then we will change mode back to "clock_counter" mode and set time 

## References
We have used the materials (like clk_en, bin2seg and debounce) from the Tomas-Fryza's github as a tools
https://github.com/tomas-fryza/vhdl-labs/commits?author=tomas-fryza
