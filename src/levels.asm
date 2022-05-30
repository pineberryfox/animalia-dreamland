.include "fontmap.inc"

.segment "RODATA"
	;; levels are a fixed 48 bytes in size
	;; so get your index via multiplication and addition
.export levels
.align $100
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

end_of_real_levels:
	;; then Gauntlet and so on are special levels
	;; which appear only in all-levels mode
.incbin "gauntlet.level"
.byte "    Gauntlet   "

.export fake_level_for_end
fake_level_for_end:
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $01, $80, $00, $00, $00, $00, $00, $00
.byte $00, $00


	;; last_level is the zero-based index of the final real level.
.export last_level
last_level: .byte (end_of_real_levels - levels)/48 - 1


.export ordered_levels
ordered_levels:
.byte 0, 2, 5, 7, 4, 3, 6, 1
.byte (end_of_real_levels - levels)/48 ; Gauntlet
.byte $FF ; sentinel

.segment "BSS"
.export level_list
.align 16
level_list: .res (end_of_real_levels - levels)/48
