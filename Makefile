.MAIN : helloworld.nes
.SUFFIXES : .asm .inc .level .o .nes
.PATH : $(.CURDIR) $(.CURDIR)/src $(.CURDIR)/src/levels $(.CURDIR)/src/songs

.asm.o:
	ca65 $(.IMPSRC) --bin-include-dir "$(.CURDIR)/src/levels" -I "$(.CURDIR)/src/songs" -o $(.TARGET)

.o.nes:
	ld65 $(.ALLSRC:M*.o) --cfg-path "${.CURDIR}" -C nes.cfg -m $(.TARGET:R).map -o $(.TARGET)

helloworld.nes : helloworld.o nes.cfg
helloworld.nes : audio.o player.o collide.o crystal.o dust.o
helloworld.nes : lvextract.o levels.o endcards.o
helloworld.nes : rand.o readjoy.o reset.o
helloworld.nes : songs.o man.o western.o spider.o rumble.o shimmer.o
helloworld.nes : tower.o bubble.o split.o wompwomp.o victory.o villain.o
helloworld.nes : ladle.o shelves.o swingy.o reach.o heroes.o possessor.o
helloworld.nes : clouds.o cow.o

audio.o : audio.asm constants.inc notes.inc
collide.o : collide.asm constants.inc
crystal.o : crystal.asm constants.inc
dust.o : dust.asm constants.inc
endcards.o : constants.inc fontmap.inc
helloworld.o : helloworld.asm constants.inc fontmap.inc header.inc abm.chr
lvextract.o : lvextract.asm constants.inc
player.o : player.asm constants.inc
rand.o : rand.asm
readjoy.o : readjoy.asm constants.inc
levels.o : levels.asm claw.level closed.level hill.level
levels.o : man.level pup.level skyland.level spider.level towers.level
levels.o : ladle.level cow.level silhouettes.level checkers.level
levels.o : shelves.level hat.level peaks.level
levels.o : gauntlet.level
reset.o : reset.asm constants.inc
songs.o : songs.asm

man.o : man.asm notes.inc
western.o : western.asm notes.inc
spider.o : spider.asm notes.inc
rumble.o : rumble.asm notes.inc
shimmer.o : shimmer.asm notes.inc
tower.o : tower.asm notes.inc
bubble.o : bubble.asm notes.inc
split.o : split.asm notes.inc
wompwomp.o : wompwomp.asm notes.inc
victory.o : victory.asm notes.inc
villain.o : villain.asm notes.inc
ladle.o : ladle.asm notes.inc
shelves.o : shelves.asm notes.inc
swingy.o : swingy.asm notes.inc
reach.o : reach.asm notes.inc
heroes.o : heroes.asm notes.inc
