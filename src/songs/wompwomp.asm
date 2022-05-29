.include "notes.inc"
.export wompwomp_pulse, wompwomp_tri

eighth = 6
quarter = 2 * eighth
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half
whole2 = 2 * whole

.segment "RODATA"
wompwomp_pulse:
	.byte CMD_SHAPE, $8F
	.byte CMD_DECAY_OFF, CMD_SUSTAIN_ON
inner_womp:
	.byte C3, 2
	.byte D3, 2
	.byte F3, 2
	.byte G3, quarter * 3 + 3
	.byte E3, 1
	.byte C3, 1
	.byte C2, 1

	.byte C3, 2
	.byte Db3, 2
	.byte D3, 2
	.byte E3, quarter * 3 + 3
	.byte C3, 1
	.byte G2, 1
	.byte C2, 1

	.byte G3, 2
	.byte F3, 2
	.byte E3, 2
	.byte C3, quarter * 7
	.byte G2, 2
	.byte C2, 2
	.byte A1, 2
	.byte CMD_STOP

wompwomp_tri:
	.byte CMD_SHAPE, $FF
	.byte CMD_JUMP
	.word inner_womp
