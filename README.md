# VFX_FPGA: Assignment 2 for MTRX3700.

## Rules
1. Do not edit the main. Always branch before you edit, create new files, etc. Only push to the main once your module is complete and passes its test benches
2. Once you have created a module, immediately make a test bench
3. Record test bench goals and things you want to see from it in the overleaf before its made (make sure tb's are informative).
4. Document your module in this README including all important info incl. clock cycles required for initialisation and/or functional use
    1. This was an issue for the debounce module. Noone making the main testbench understood it's clock cycle requirements (50,000) and tried to use it anyway
5. Read documentation before using a module
6. 
7. 

## Branch Naming Convention
name.date.whatever tf you're trying to do

## Things to Do:

- Microphone working
  Make sure that appropriate filtering is done to detect things in the human voice range.
  Determine the max frequency based on sampling frequency. Then filter out everything above that using a low pass filter.
  When using the fft in the IP's don't worry about the imaginary components (just enter them as zero)
  HUman Frequency f = fs * k/N (N shouldbe 1024, fs sampling frequency, k is the output of the fft)
  
    - implement an FFT
    - output the peak frequency (and hopefully amplitude of signal)

- Streaming from camera into BRAM
    - storing in BRAM
    - sending to VGA
    - Handle FIFO stuff
    - Stream output to VGA

- Apply filters to frames including:
      the filters should be general enough so that they can be reconfigured easily if we want to change
      them based on the amplitude and different frequencies.
    - colour
    - brightness
    - blurring
    - edge detection

- Board interface LCD and pushbuttons 
    - Create module to interface with board to select frames based on this (probably be an fsm)
    - Make sure that the states here are binary so that they can be easily read by a different operation
    - Create LCD interface based on the state output of the fsm in the previous task

## Responsibilities

## General Ideas:
### Adam
1. receive data in buffer. 320x240 pixels.
2. each pixel is 12 bits RGB
3. turn 12 bit RGB (4R, 4G, 4B) into 30 bit RGB - repeat each twice with 00 padding in between

# Modules

## video_data_expander.sv
This module takes a static image from BRAM of which has AxB pixels and where each pixel is represented by 3 bit RGB value. 
It takes the number of pixels as an input parameter as well as the number of bits representing each pixel. However it is currently only configured for 3 bit GRB values and is not smart enough to change yet.
It is always outputting VALID unless a reset signal is received.
It is receives a ready signal and will only output a new value if the ready signal is received!!
It has a pulse to indicate the beginning and end of a packet (a frame, an image etc.)

## State_machine_with_display.sv
Inputs: 
    [3:0]key: All of the keys on the FPGA
    A bunch of other DATA I/O ports on the FPGA (if its in caps then just use as a pin assignment)
Outputs:
    [1:0]filter_type: The current 'state' of the machine. Filter type mapping shown below.

STATE MAPPING
    00: COLOUR
    01: BLUR
    10: BRIGHTNESS
    11: EDGES

Module Explanation
This module controls what the current state of the overall machine is and displays the state on the LCD.
Pressing any of the keys on the FPGA will correspond to a change to that state.
    
