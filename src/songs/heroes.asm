.include "notes.inc"
.export heroes_pulse, heroes_tri

eighth = 12
quarter = eighth * 2
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"
heroes_pulse:
	.byte CMD_DECAY_ON, CMD_SUSTAIN_ON
	.byte CMD_SHAPE, $8F

	.byte G3, eighth
	.byte C3, eighth
	.byte G3, eighth
	.byte C3, eighth
	.byte G3, eighth
	.byte F3, eighth
	.byte Eb3, eighth
	.byte Bb2, quarter

	.byte Bb2, eighth
	.byte F3, eighth
	.byte Bb2, eighth
	.byte F3, eighth
	.byte Eb3, eighth
	.byte D3, eighth
	.byte Ab2, quarter

	.byte Ab2, eighth
	.byte Eb3, eighth
	.byte Ab2, eighth
	.byte Eb3, eighth
	.byte D3, eighth
	.byte Bb2, eighth
	.byte G2, quarter

	.byte G2, eighth
	.byte D3, eighth
	.byte G2, eighth
	.byte D3, eighth
	.byte G2, eighth
	.byte C3, eighth
	.byte rest, eighth

	.byte CMD_JUMP
	.word heroes_pulse

heroes_tri:
	.byte CMD_SHAPE, $FF
	.byte C4, whole
	.byte D4, whole
	.byte Eb4, whole
	.byte Bb3, whole - quarter
	.byte B3, quarter
	.byte CMD_JUMP
	.word heroes_tri
