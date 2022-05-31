.include "notes.inc"
.export clouds_pulse, clouds_tri

eighth = 12
quarter = eighth * 2
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"
clouds_pulse:
	.byte CMD_DECAY_ON, CMD_SUSTAIN_ON
	.byte CMD_SHAPE, $8F

	.byte C6, eighth
	.byte F5, eighth
	.byte D5, eighth
	.byte C5, eighth
	.byte C6, eighth
	.byte F5, eighth
	.byte D5, eighth
	.byte C5, eighth
	.byte C6, eighth
	.byte F5, eighth
	.byte D5, eighth
	.byte C5, eighth
	.byte D5, quarter
	.byte F5, quarter

	.byte CMD_JUMP
	.word clouds_pulse

clouds_tri:
	.byte CMD_SHAPE, $00
	.byte A1, whole * 2
	.byte CMD_SHAPE, $FF
	.byte C5, half
	.byte F5, half
	.byte G5, half
	.byte Bb5, half
	.byte A5, whole - quarter
	.byte C5, quarter / 6
	.byte A4, quarter / 6
	.byte C4, quarter / 6
	.byte A3, quarter / 6
	.byte C3, quarter / 6
	.byte A2, quarter / 6
	.byte CMD_JUMP
	.word clouds_tri
