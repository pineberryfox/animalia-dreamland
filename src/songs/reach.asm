.include "notes.inc"
.export reach_pulse, reach_tri

eighth = 6
quarter = eighth * 2
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"
reach_pulse:
	.byte CMD_DECAY_ON, CMD_SUSTAIN_ON
	.byte CMD_SHAPE, $8F
	.byte E2, quarter
	.byte E3, quarter
	.byte Gb3, quarter
	.byte G3, half
	.byte E2, quarter
	.byte Gb3, quarter
	.byte G3, half
	.byte E2, quarter
	.byte E3, quarter
	.byte Gb3, quarter
	.byte C4, quarter
	.byte B3, quarter
	.byte A3, quarter
	.byte G3, quarter
	.byte CMD_JUMP
	.word reach_pulse

reach_tri:
	.byte CMD_SHAPE, $FF
	.byte E3, 2*whole
	.byte B3, 2*whole
	.byte C4, 2*whole
	.byte G3, 2*whole
	.byte CMD_JUMP
	.word reach_tri
