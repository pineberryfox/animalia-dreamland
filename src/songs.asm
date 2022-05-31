.import man_pulse,man_tri
.import western_pulse,western_tri
.import spider_pulse,spider_tri
.import rumble_pulse,rumble_tri
.import shimmer_pulse,shimmer_tri
.import tower_pulse,tower_tri
.import bubble_pulse,bubble_tri
.import split_pulse,split_tri
.import wompwomp_pulse,wompwomp_tri
.import victory_pulse,victory_tri
.import villain_pulse,villain_tri
.import ladle_pulse,ladle_tri
.import shelves_pulse,shelves_tri
.import swingy_pulse,swingy_tri
.import reach_pulse,reach_tri
.import heroes_pulse,heroes_tri
.import possessor_pulse,possessor_tri
.import clouds_pulse,clouds_tri
.import cow_pulse,cow_tri

.exportzp lose_song = <((lose_song_loc - melodies) / 2)
.exportzp win_song  = <((win_song_loc  - melodies) / 2)

.segment "RODATA"
.export melodies, bass

melodies:
.word shimmer_pulse ; skyland
.word spider_pulse ; spider
.word man_pulse ; man and myster
.word bubble_pulse ; gripping claw
.word split_pulse ; bifurcated hill
.word western_pulse ; pup
.word rumble_pulse ; closed off
.word tower_pulse ; two towers
.word ladle_pulse ; ladle
.word cow_pulse ; blessed bovine
.word reach_pulse ; mirror ball
.word heroes_pulse ; silhouttes
.word swingy_pulse ; game in the sky
.word shelves_pulse ; wall of shelves
.word possessor_pulse ; packed hat
.word clouds_pulse ; cloudy peaks
	;; the last of the real level songs has to be guantlet
.word villain_pulse ; guantlet
lose_song_loc:
.word wompwomp_pulse ; lost
win_song_loc:
.word victory_pulse ; won

bass:
	;; maintain order from above
.word shimmer_tri ; skyland
.word spider_tri ; spider
.word man_tri ; man and mystery
.word bubble_tri ; gripping claw
.word split_tri ; bifurcated hill
.word western_tri ; pup
.word rumble_tri ; closed off
.word tower_tri ; two towers
.word ladle_tri ; ladle
.word cow_tri ; blessed bovine
.word reach_tri ; mirror ball
.word heroes_tri ; silhouttes
.word swingy_tri ; game in the sky
.word shelves_tri ; wall of shelves
.word possessor_tri ; packed hat
.word clouds_tri ; cloudy peaks
.word villain_tri ; guantlet
.word wompwomp_tri ; lost
.word victory_tri ; won
