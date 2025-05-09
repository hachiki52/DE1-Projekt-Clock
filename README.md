### Team members

* Pavlov Ivan(247158) (responsible for creating clock_counter and display_multiplex)
* Oleinik Ruslan(253232) (responsible for creating top level and editing xdc)
* Pryimak Yevhenii(256562) (responsible for testing simulations and github editing)
* Shvedenko Konstantin(253002) (responsible for creating stopwatch and pptx-presentation)


## Hardware description of demo application

### Easy Instruction for using our digital clock with stopwatch
![Show](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Images/Show.PNG)

### Video where our digital clock is simple running in project's previous iteration (with 1Hz blue blinker and without stopwatch and point between HH.MM.SS)
https://youtube.com/shorts/wwK6do2oKpY?feature=share

### RTL-Schematic
![Schema](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Images/Top_level_RTL.png)
There we can see logic of our project

## Software description
/
|── src/
│   ├── [bin2seg.vhd](https://github.com/hachiki52/DE1-Projekt-Clock/blob/digital_clock_only_clock/Digital_clock.srcs/sources_1/new/bin2seg.vhd)
│   ├── clk_en.vhd
│   ├── debounce.vhd
│   ├── clock_counter.vhd
│   ├── display_mux.vhd
│   ├── stopwatch.vhd
│   └── top_level.vhd
└── sim/
    ├── tb_clock_counter.vhd
    ├── tb_display_mux.vhd
    ├── tb_stopwatch.vhd
    └── tb_top_level.vhd



### Component(s) simulations

Write descriptive text and put simulation screenshots of components you created during the project.

## References
We have used the materials (like clk_en, bin2seg and debounce) from the Tomas-Fryza's github as a tools
https://github.com/tomas-fryza/vhdl-labs/commits?author=tomas-fryza
