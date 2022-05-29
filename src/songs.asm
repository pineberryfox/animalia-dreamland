.import silence
.import man_pulse,man_tri
.import western_pulse,western_tri
.import spider_pulse,spider_tri
.import rumble_pulse,rumble_tri
.import shimmer_pulse,shimmer_tri
.import tower_pulse,tower_tri
.import bubble_pulse,bubble_tri

.segment "RODATA"
.export melodies, bass

melodies:
.word shimmer_pulse ; skyland
.word spider_pulse ; spider
.word man_pulse ; man and myster
.word bubble_pulse ; gripping claw
.word silence ; bifurcated hill
.word western_pulse ; pup
.word rumble_pulse ; closed off
.word tower_pulse ; two towers

bass:
.word shimmer_tri ; skyland
.word spider_tri ; spider
.word man_tri ; man and mystery
.word bubble_tri ; gripping claw
.word silence ; bifurcated hill
.word western_tri ; pup
.word rumble_tri ; closed off
.word tower_tri ; two towers
