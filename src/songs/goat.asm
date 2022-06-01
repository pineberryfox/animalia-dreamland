.include "notes.inc"
.export goat_pulse, goat_tri

.segment "RODATA"

quarter = 12
half = 2 * quarter
whole = 2 * half
doublewhole = 2 * whole

goat_pulse:
	.byte CMD_SHAPE, $8F, CMD_DECAY_ON, CMD_SUSTAIN_ON
	.byte D3, half
	.byte A3, half
	.byte D4, half
	.byte G3, quarter
	.byte Bb3, quarter

	.byte D3, half
	.byte D4, half
	.byte Bb3, half
	.byte A3, half

	.byte D3, half
	.byte A3, half
	.byte D4, half
	.byte G3, quarter
	.byte Bb3, quarter

	.byte A3, whole
	.byte F3, whole
	.byte CMD_JUMP
	.word goat_pulse

goat_tri:
	.byte CMD_SHAPE, $FF
	.byte D3, doublewhole
	.byte G3, doublewhole
	.byte F4, doublewhole
	.byte E4, whole
	.byte F4, whole
	.byte CMD_JUMP
	.word goat_tri
