# VFX_FPGA

## Rules
1. Do not edit the main. Always branch before you edit, create new files, etc. Only push to the main once your module is complete and passes its test benches
2. Once you have created a module, immediately make a test bench
3. Document your module in this README including all important info incl. clock cycles required for initialisation and/or functional use
    1. This was an issue for the debounce module. Noone making the main testbench understood it's clock cycle requirements (50,000) and tried to use it anyway
4. Read documentation before using a module

Assignment 2 for MTRX3700.

Ideas:

Buffer:
- use a fifo as  buffer
- 
