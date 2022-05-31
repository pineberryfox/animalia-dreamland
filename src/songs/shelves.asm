.include "notes.inc"
.export shelves_pulse, shelves_tri

eighth = 9
quarter = eighth * 2
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"
shelves_pulse:
	.byte CMD_SHAPE, $8F
	.byte CMD_DECAY_ON, CMD_SUSTAIN_ON
	.byte E3, quarter
	.byte CMD_SUSTAIN_OFF, CMD_SHAPE, $4F
	.byte E2, eighth
	.byte E2, eighth
	.byte CMD_SUSTAIN_ON, CMD_SHAPE, $8F
	.byte A3, eighth
	.byte E4, eighth
	.byte CMD_SUSTAIN_OFF, CMD_SHAPE, $4F
	.byte E2, eighth
	.byte E2, eighth
	.byte CMD_SUSTAIN_ON, CMD_SHAPE, $8F
	.byte G4, quarter + eighth
	.byte F4, quarter + eighth
	.byte E4, quarter / 3
	.byte F4, quarter / 3
	.byte E4, quarter / 3
	.byte CMD_JUMP
	.word shelves_pulse

shelves_tri:
	.byte CMD_SHAPE, $FF
	.byte E3, half
	.byte A3, half
	.byte C4, half
	.byte B3, half
	.byte CMD_JUMP
	.word shelves_tri
