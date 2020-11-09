# SndMusEG
A very old attempt at making a sound driver cross-compatible with
Genesis, SegaCD and 32X
Sound code is running on 68k, it also sends requests to their respective
add-on (SubCPU or comm with SH2)

Supported:
- All SegaCD's PCM channels, samples are .WAV converted on the fly
- 32X PWM, 8 channels mixed, same number of channels as SCD

Bugs:
- DAC might play corrupted sample data
