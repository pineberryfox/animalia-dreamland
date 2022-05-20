.MAIN : helloworld.nes
.SUFFIXES : .asm .inc .o .nes
.PATH : $(.CURDIR) $(.CURDIR)/src

.asm.o:
	ca65 $(.IMPSRC) -o $(.TARGET)

.o.nes:
	ld65 $(.ALLSRC:M*.o) --cfg-path "${.CURDIR}" -C nes.cfg -o $(.TARGET)

helloworld.nes : helloworld.o player.o lvextract.o rand.o readjoy.o reset.o collide.o

collide.o : collide.asm constants.inc
helloworld.o : helloworld.asm constants.inc abm.chr
lvextract.o : lvextract.asm constants.inc
player.o : player.asm constants.inc
rand.o : rand.asm
readjoy.o : readjoy.asm constants.inc
reset.o : reset.asm constants.inc
