.include "notes.inc"
.export rumble_pulse, rumble_tri

eighth = 6
quarter = 2 * eighth
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"

rumble_pulse:
	.byte CMD_SHAPE, $4F
	.byte CMD_DECAY_ON, CMD_SUSTAIN_OFF
	.byte F2, eighth
	.byte E2, eighth
	.byte rest, eighth
	.byte E2, eighth
	.byte rest, eighth
	.byte E2, eighth
	.byte F2, eighth
	.byte E2, eighth

	.byte F2, eighth
	.byte E2, eighth
	.byte rest, eighth
	.byte E2, eighth
	.byte rest, eighth
	.byte E2, eighth
	.byte F2, eighth
	.byte E2, eighth

	.byte CMD_SUSTAIN_ON, CMD_DECAY_OFF
	.byte CMD_SHAPE, $0F
	.byte Ab2, half
	.byte C3, 3
	.byte CMD_SHAPE, $CF
	.byte Db3, 1
	.byte CMD_SHAPE, $0F
	.byte C3, 3
	.byte CMD_SHAPE, $CF
	.byte Db3, 1
	.byte CMD_SHAPE, $0F
	.byte C3, 3
	.byte CMD_SHAPE, $CF
	.byte Db3, 1
	.byte CMD_SHAPE, $0F
	.byte C3, 3
	.byte CMD_SHAPE, $CF
	.byte Db3, 1
	.byte CMD_SHAPE, $0F
	.byte C3, 3
	.byte Db3, 1
	.byte C3, 3
	.byte Db3, 1
	.byte CMD_JUMP
	.word rumble_pulse


rumble_tri:
	.byte CMD_SHAPE, $FF
	.byte E4, whole
	.byte F4, whole
	.byte E4, quarter
	.byte G4, quarter
	.byte Ab4, quarter
	.byte F4, quarter

	.byte E4, whole
	.byte C5, whole
	.byte Bb4, quarter
	.byte Ab4, quarter
	.byte G4, quarter
	.byte E4, quarter
	.byte CMD_JUMP
	.word rumble_tri
