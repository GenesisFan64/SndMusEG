echo "*** CD ***"

# Make ISO Filesystem
mkisofs -quiet -iso-level 1 -o "cd/fs.bin" -pad "cd/fs" "engine/sound/data/samples/pcm/"

# WORD-RAM programs
#wine "tools/asm68k" /q /p /e SegaCD=1 /e MARS=0 /e SMEG_Z80=1 "cd/main/default/code.asm","cd/fs/MAIN.BIN", ,"cd/main/default/out.out"

# PRG-RAM programs
wine "tools/asm68k" /q /p /e SegaCD=1 /e MARS=0 "cd/main/ram/title/code.asm","cd/fs/PRG_MAIN.BIN", ,"cd/main/ram/title/out.out"
#wine "tools/asm68k" /q /p /e SegaCD=1 /e MARS=0 "cd/main/ram/level/code.asm","cd/fs/PRG_LEVL.BIN", ,"cd/main/ram/level/out.out"

# MainCpu Init / SubCpu OS
wine "tools/asm68k" /q /p /e SegaCD=1 /e MARS=0 "cd/main/boot.asm","cd/main.bin"
wine "tools/asm68k" /q /p /e SegaCD=1 /e MARS=0 "cd/sub.asm","cd/sub.bin"
wine "tools/asm68k" /q /p /e SegaCD=1 /e MARS=0 "cd/disc.asm",rom_cd.bin, ,"cd/out.out"
rm "cd/main.bin"
rm "cd/sub.bin"
rm "cd/fs.bin"