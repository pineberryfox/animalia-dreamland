.segment "RODATA"

.charmap $41, $30
.charmap $42, $31
.charmap $43, $32
.charmap $44, $33
.charmap $45, $34
.charmap $46, $35
.charmap $47, $36
.charmap $48, $37
.charmap $49, $38
.charmap $4a, $39
.charmap $4b, $3a
.charmap $4c, $3b
.charmap $4d, $3c
.charmap $4e, $3d
.charmap $4f, $3e
.charmap $50, $3f
.charmap $51, $40
.charmap $52, $41
.charmap $53, $42
.charmap $54, $43
.charmap $55, $44
.charmap $56, $45
.charmap $57, $46
.charmap $58, $47
.charmap $59, $48
.charmap $5a, $49
.charmap $5b, $4a
.charmap $61, $30
.charmap $62, $31
.charmap $63, $32
.charmap $64, $33
.charmap $65, $34
.charmap $66, $35
.charmap $67, $36
.charmap $68, $37
.charmap $69, $38
.charmap $6a, $39
.charmap $6b, $3a
.charmap $6c, $3b
.charmap $6d, $3c
.charmap $6e, $3d
.charmap $6f, $3e
.charmap $70, $3f
.charmap $71, $40
.charmap $72, $41
.charmap $73, $42
.charmap $74, $43
.charmap $75, $44
.charmap $76, $45
.charmap $77, $46
.charmap $78, $47
.charmap $79, $48
.charmap $7a, $49
.charmap $7b, $4a

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

