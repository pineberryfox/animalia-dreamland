.MAIN : helloworld.nes
.SUFFIXES : .asm .inc .o .nes
.PATH : $(.CURDIR) $(.CURDIR)/src

.asm.o:
	ca65 $(.IMPSRC) -o $(.TARGET)

.o.nes:
	ld65 $(.ALLSRC:M*.o) --cfg-path "${.CURDIR}" -C nes.cfg -o $(.TARGET)

lvextract.o : lvextract.asm constants.inc
helloworld.o : helloworld.asm constants.inc abm.chr
helloworld.nes : helloworld.o lvextract.o readjoy.o reset.o
readjoy.o : readjoy.asm constants.inc
reset.o : reset.asm constants.inc
