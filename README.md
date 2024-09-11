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
