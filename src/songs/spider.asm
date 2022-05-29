.include "notes.inc"
.export spider_pulse, spider_tri

.segment "RODATA"
	;; E B C F F F F F E C D D D D

quarter = 20
half = 2 * quarter
doublewhole = 8 * quarter

spider_pulse:
	.byte CMD_SHAPE, $8F, CMD_DECAY_ON, CMD_SUSTAIN_ON
	.byte E3, quarter
	.byte B3, quarter
	.byte C4, quarter
	.byte F3, half
	.byte CMD_SHAPE, $CF
	.byte F3, quarter
	.byte CMD_SHAPE, $0F
	.byte F3, quarter
	.byte CMD_SHAPE, $4F
	.byte F3, quarter

	.byte CMD_SHAPE, $8F
	.byte F3, quarter
	.byte E3, quarter
	.byte C3, quarter
	.byte D3, half
	.byte CMD_SHAPE, $CF
	.byte D3, quarter
	.byte CMD_SHAPE, $0F
	.byte D3, quarter
	.byte CMD_SHAPE, $4F
	.byte D3, quarter
	.byte CMD_JUMP
	.word spider_pulse

spider_tri:
	.byte CMD_SHAPE, $FF
	.byte E3, doublewhole
	.byte F3, doublewhole
	.byte C4, doublewhole
	.byte B3, doublewhole
	.byte CMD_JUMP
	.word spider_tri
