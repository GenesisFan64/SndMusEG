echo "*** MARS ***"

# SH2
wine "tools/asmsh" /q /p /o i+ /o psh2 /o w- "mars/sh2/code.asm","mars/sh2/code.bin", ,"mars/sh2/out.out"

# 68k
wine "tools/asm68k" /q /p /e SegaCD=0 /e MARS=1 "mars/main.asm",rom_mars.bin, ,"mars/out.out"
#wine "tools/fixheadr" rom_mars.bin

rm "mars/sh2/code.bin"