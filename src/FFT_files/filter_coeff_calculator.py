import numpy as np
from scipy.signal import firwin

# Filter parameters
sample_rate = 48000  # Sample rate in Hz
cutoff_freq = 1000   # Cutoff frequency in Hz
num_taps = 47       # Number of filter coefficients (taps)

# Generate the filter coefficients
coefficients = firwin(num_taps, cutoff_freq, fs=sample_rate, pass_zero='lowpass')

# Print the coefficients
for i in coefficients:
    print(f"{i}, ", end='')
print()
