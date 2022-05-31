.include "notes.inc"
.export possessor_pulse, possessor_tri

eighth = 15
quarter = eighth * 2
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"
possessor_pulse:
	.byte CMD_DECAY_ON, CMD_SUSTAIN_ON
	.byte CMD_SHAPE, $8F

	.byte E2, eighth
	.byte E2, eighth
	.byte E3, eighth
	.byte Bb3, eighth
	.byte A3, quarter
	.byte E2, eighth
	.byte E2, quarter
	.byte D3, eighth
	.byte E2, eighth
	.byte E2, eighth
	.byte F3, quarter
	.byte E3, quarter

	.byte CMD_JUMP
	.word possessor_pulse

possessor_tri:
	.byte CMD_SHAPE, $FF
	.byte D4, whole*2
	.byte F4, whole*2
	.byte E4, whole*2
	.byte CMD_JUMP
	.word possessor_tri
