.include "fontmap.inc"

.segment "RODATA"
	;; levels are a fixed 48 bytes in size
	;; so get your index via multiplication and addition
.export levels
.align $100
levels:
.incbin "skyland.level"
.byte "    Skyland    "

.incbin "claw.level"
.byte " Gripping Claw "

.incbin "pup.level"
.byte "      Pup      "

.incbin "man.level"
.byte "Man and Mystery"

.incbin "spider.level"
.byte "     Spider    "

.incbin "hill.level"
.byte "Bifurcated Hill"

.incbin "closed.level"
.byte "   Closed Off  "

.incbin "towers.level"
.byte "   Two Towers  "

	;; there should always be a number of levels
	;; equal to some power of 2.
	;; last_level is the zero-based index of the final one.
	;; that is, the binary form of the number should
	;; begin with a stream of zeros
	;; and end with a stream of ones
.export last_level
last_level: .byte (last_level - levels)/48 - 1

.export fake_level_for_end
fake_level_for_end:
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $01, $80, $00, $00, $00, $00, $00, $00
.byte $00, $00

.segment "BSS"
.export level_list
.align 16
level_list: .res (last_level - levels)/48
