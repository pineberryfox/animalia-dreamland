.include "notes.inc"
.export cow_pulse, cow_tri

eighth = 6
quarter = eighth * 2
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"
cow_pulse:
	.byte CMD_DECAY_ON, CMD_SUSTAIN_OFF
	.byte CMD_SHAPE, $8F

	.byte F4, quarter
	.byte F4, quarter
	.byte rest, quarter
	.byte F4, quarter
	.byte rest, quarter
	.byte A3, eighth/2
	.byte B3, eighth/2
	.byte rest, eighth
	.byte CMD_SUSTAIN_ON
	.byte C4, quarter + eighth
	.byte CMD_SUSTAIN_OFF
	.byte A3, quarter / 6
	.byte C3, quarter / 6
	.byte A2, quarter / 6

	.byte D4, quarter
	.byte D4, quarter
	.byte rest, quarter
	.byte E4, quarter
	.byte rest, quarter
	.byte F4, quarter
	.byte E4, quarter
	.byte D4, quarter

	.byte CMD_JUMP
	.word cow_pulse

cow_tri:
	.byte CMD_SHAPE, $FF
	.byte F4, quarter
	.byte F4, quarter
	.byte C5, quarter
	.byte F4, quarter
	.byte CMD_SHAPE, $00, A1, quarter, CMD_SHAPE, $FF
	.byte F4, quarter
	.byte CMD_SHAPE, $00, A1, quarter, CMD_SHAPE, $FF
	.byte F4, 2
	.byte G4, half - 2
	.byte G4, quarter
	.byte G4, quarter
	.byte G4, quarter
	.byte Bb4, half
	.byte A4, half
	.byte CMD_JUMP
	.word cow_tri
