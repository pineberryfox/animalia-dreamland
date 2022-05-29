.include "notes.inc"
.export bubble_pulse, bubble_tri

quarter = 10
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half
whole2 = 2 * whole

.segment "RODATA"
bubble_pulse:
	.byte CMD_SHAPE, $87
	.byte CMD_DECAY_OFF, CMD_SUSTAIN_ON
	.byte rest, whole2
	.byte G3, whole2
	.byte CMD_SHAPE, $8A
	.byte Gb3, whole2
	.byte CMD_SHAPE, $4C
	.byte B3, whole2
	.byte CMD_SHAPE, $8A
	.byte A3, whole+half
	.byte CMD_SHAPE, $87
	.byte G3, half
	.byte E3, whole
	.byte rest, whole
	.byte CMD_JUMP
	.word bubble_pulse

bubble_tri:
	.byte CMD_SHAPE, $FF
	.byte E3, quarter
	.byte G3, quarter
	.byte B3, quarter
	.byte E4, quarter
	.byte CMD_JUMP
	.word bubble_tri
