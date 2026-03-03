# Digital clock project in Verilog with Vivado.

# Project Overview
This repository contains a digital clock project implemented using Verilog and designed for synthesis using Vivado software. The digital clock is capable of displaying the current time on a 7-segment display and includes additional features such as a timer, alarm, and stopwatch.

# Features 
## Time Display

- Current Time Display: The clock accurately displays the current time in HH:MM format on a 7-segment display.
- Time Setting: Users can set the current time using dedicated input controls.
## Timer
- Countdown Timer: The timer can be set to count down from a specified time. When the countdown reaches zero, an alert signal is activated.
- Timer Display: The remaining time is displayed on the 7-segment display in MM
format.
- Pause/Resume: The timer supports pausing and resuming the countdown.
## Alarm
- Alarm Setting: Users can set an alarm time. When the current time matches the alarm time, an alarm signal is activated.
- Alarm Enable/Disable: The alarm can be enabled or disabled using input controls.
## Stopwatch
- Start/Stop: The stopwatch can be started and stopped using input controls.
- Reset: The stopwatch can be reset to zero.
# Hardware Requirements
- FPGA Board: A compatible FPGA development board (BASYS-3, ARTIX-7).
- 7-Segment Display: A display unit for visualizing time, timer, alarm, and stopwatch values.
- Input Controls: Push buttons or switches for setting time, starting/stopping the timer and stopwatch, and enabling/disabling the alarm.
# Software Requirements
Vivado: Xilinx Vivado Design Suite for synthesis, simulation, and implementation of the Verilog code.

# Getting Started
* Launch Vivado.
* Open the project file.
* Synthesize and implement the design.
* Generate the bitstream and program the FPGA.
## Directory Structure
* src/: Contains the Verilog source files.
* constraints/: Contains the XDC constraints files for pin mapping.
# Usage
- Set the current time using the input controls.
- Set the timer and start the countdown.
- Set the alarm time and enable the alarm.
- Use the stopwatch to measure elapsed time and record lap times.
