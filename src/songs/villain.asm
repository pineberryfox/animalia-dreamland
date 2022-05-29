.include "notes.inc"
.export villain_pulse, villain_tri

eighth = 6
quarter = 2 * eighth
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"

villain_pulse:
	.byte CMD_SHAPE, $4F
	.byte CMD_DECAY_ON, CMD_SUSTAIN_OFF
	.byte F2, eighth
	.byte E2, eighth
	.byte A1, eighth
	.byte Eb2, eighth
	.byte D2, eighth
	.byte A1, eighth
	.byte C2, eighth
	.byte B1, eighth
	.byte CMD_JUMP
	.word rumble_pulse


villain_tri:
	.byte CMD_SHAPE, $00
	.byte rest, 2*whole + quarter
	.byte CMD_SHAPE, $FF
	.byte A4, whole
	.byte E5, whole - 2
	.byte F5, 2
	.byte G5, half
	.byte Gb5, whole
	.byte F5, quarter
	.byte Gb5, quarter

	.byte F5, whole
	.byte E5, half
	.byte C5, half
	.byte D5, half
	.byte C5, quarter
	.byte B4, quarter
	.byte G4, quarter
	.byte A4, half
	.byte CMD_JUMP
	.word rumble_tri
