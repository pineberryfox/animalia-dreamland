.include "notes.inc"
.export tower_pulse, tower_tri

quarter = 13
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"
tower_pulse:
	.byte CMD_SHAPE, $89
	.byte CMD_DECAY_ON, CMD_SUSTAIN_ON
	.byte B3, quarter
	.byte E3, quarter
	.byte B3, quarter
	.byte E3, quarter
	.byte B3, quarter
	.byte E3, quarter
	.byte B3, quarter
	.byte E3, quarter
	.byte C4, halfdot
	.byte G3, halfdot
	.byte A3, half

	.byte B3, quarter
	.byte E3, quarter
	.byte B3, quarter
	.byte E3, quarter
	.byte B3, quarter
	.byte E3, quarter
	.byte B3, quarter
	.byte E3, quarter
	.byte A3, halfdot
	.byte G3, halfdot
	.byte Gb3, half
	.byte CMD_JUMP
	.word tower_pulse

tower_tri:
	.byte CMD_SHAPE, $FF
	.byte E3, whole
	.byte B3, whole
	.byte E3, quarter
	.byte G3, quarter
	.byte A3, quarter
	.byte B3, quarter
	.byte C4, quarter
	.byte B3, quarter
	.byte Bb3, quarter
	.byte B3, quarter

	.byte E3, whole
	.byte B3, whole
	.byte E3, quarter
	.byte G3, quarter
	.byte A3, quarter
	.byte B3, quarter
	.byte A3, quarter
	.byte G3, quarter
	.byte F3, quarter
	.byte Eb3, quarter
	.byte CMD_JUMP
	.word tower_tri
