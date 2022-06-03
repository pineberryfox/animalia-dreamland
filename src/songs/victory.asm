.include "notes.inc"
.export victory_pulse, victory_tri

quarter = 8
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half
whole2 = 2 * whole

.segment "RODATA"
victory_pulse:
	.byte CMD_SHAPE, $8F
	.byte CMD_DECAY_OFF, CMD_SUSTAIN_ON
inner_victory:
	.byte G3, quarter
	.byte D4, quarter
	.byte G4, quarter
	.byte D4, quarter
	.byte C5, quarter
	.byte B4, quarter
	.byte F4, quarter
	.byte B4, quarter
	.byte G4, half
	.byte C4, 2
	.byte G4, 2
	.byte G3, 2
	.byte C2, 2
	.byte CMD_STOP

victory_tri:
	.byte CMD_SHAPE, $FF
	.byte CMD_JUMP
	.word inner_victory
