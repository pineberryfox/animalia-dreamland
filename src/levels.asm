.include "fontmap.inc"

.segment "RODATA"
	;; levels are a fixed 48 bytes in size
	;; so get your index via multiplication and addition
.export levels
levels:
.incbin "skyland.level"
.byte "    Skyland    "

.incbin "spider.level"
.byte "     Spider    "

.incbin "man.level"
.byte "Man and Mystery"

.incbin "claw.level"
.byte " Gripping Claw "

.incbin "hill.level"
.byte "Bifurcated Hill"

.incbin "pup.level"
.byte "      Pup      "

.incbin "closed.level"
.byte "   Closed Off  "

.incbin "towers.level"
.byte "   Two Towers  "

.incbin "ladle.level"
.byte "     Ladle     "

.incbin "cow.level"
.byte " Blessed Bovine"

.incbin "mirror.level"
.byte "  Mirror Ball  "

.incbin "silhouettes.level"
.byte "  Silhouettes  "

.incbin "checkers.level"
.byte "Game In The Sky"

.incbin "shelves.level"
.byte "Wall of Shelves"

.incbin "hat.level"
.byte "   Packed Hat  "

.incbin "peaks.level"
.byte "  Cloudy Peaks "

.incbin "goat.level"
.byte "  Loafed Goat  "

end_of_real_levels:
	;; then Gauntlet is a special level
	;; which appears only in all-levels mode
.incbin "gauntlet.level"
.byte "    Gauntlet   "

.export fake_level_for_end
fake_level_for_end:
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $01, $80, $00, $00, $00, $00, $00, $00
.byte $00, $00


	;; last_level is the zero-based index of the final real level.
.exportzp last_level = <((end_of_real_levels - levels)/48 - 1)


.export ordered_levels
ordered_levels:
.byte 0, 15, 8, 9, 5, 12, 2, 11, 7, 13, 4, 3, 10, 14, 16, 1, 6
.byte (end_of_real_levels - levels)/48 ; Gauntlet
.byte $FF ; sentinel

.segment "BSS"
.export level_list
.align 16
level_list: .res (end_of_real_levels - levels)/48
