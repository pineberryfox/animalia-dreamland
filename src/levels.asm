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

	;; there should always be a number of levels
	;; equal to some power of 2.
	;; last_level is the zero-based index of the final one.
	;; that is, the binary form of the number should
	;; begin with a stream of zeros
	;; and end with a stream of ones
.export last_level
last_level: .byte $01

	;; levels are a fixed 48 bytes in size
	;; so get your index via multiplication and addition
.export levels
.align $100
levels:
lv1:
.byte $00, $00, $00, $00, $00, $00, $00, $00
.byte $0F, $E0, $00, $00, $80, $00, $00, $00
.byte $0E, $00, $0E, $00, $00, $00, $80, $03
.byte $FF, $03, $FF, $03
.byte $1B ; player spawn (1,11)
.byte $05, $D1, $FA, $AD ; crystals
.byte "    Skyland    "

lv2:
.byte $00, $00, $00, $00, $00, $00, $0F, $80
.byte $0F, $80, $0C, $00, $0C, $00, $0C, $18
.byte $00, $00, $00, $00, $01, $80, $01, $80
.byte $01, $80, $F9, $8F
.byte $79 ; player spawn (7,9)
.byte $0C, $21, $D3, $FC ; crystals
.byte " Gripping Claw "
