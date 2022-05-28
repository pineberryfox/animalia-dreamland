.MAIN : helloworld.nes
.SUFFIXES : .asm .inc .o .nes
.PATH : $(.CURDIR) $(.CURDIR)/src $(.CURDIR)/src/levels

.asm.o:
	ca65 $(.IMPSRC) --bin-include-dir "$(.CURDIR)/src/levels" -o $(.TARGET)

.o.nes:
	ld65 $(.ALLSRC:M*.o) --cfg-path "${.CURDIR}" -C nes.cfg -m $(.TARGET:R).map -o $(.TARGET)

helloworld.nes : helloworld.o endcards.o player.o crystal.o dust.o lvextract.o rand.o readjoy.o reset.o collide.o levels.o audio.o

audio.o : audio.asm constants.inc
collide.o : collide.asm constants.inc
crystal.o : crystal.asm constants.inc
dust.o : dust.asm constants.inc
endcards.o : constants.inc fontmap.inc
helloworld.o : helloworld.asm constants.inc fontmap.inc header.inc abm.chr
lvextract.o : lvextract.asm constants.inc
player.o : player.asm constants.inc
rand.o : rand.asm
readjoy.o : readjoy.asm constants.inc
levels.o : levels.asm claw.level closed.level hill.level man.level pup.level skyland.level spider.level towers.level
reset.o : reset.asm constants.inc
