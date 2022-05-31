.include "notes.inc"
.export swingy_pulse, swingy_tri

eighth = 6
quarter = eighth * 2
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"
swingy_pulse:
	.byte CMD_DECAY_ON, CMD_SUSTAIN_ON
	.byte CMD_SHAPE, $8F
	.byte E3, quarter + eighth
	.byte CMD_SHAPE, $4F
	.byte E3, eighth
	.byte CMD_SHAPE, $8F
	.byte Gb3, quarter + eighth
	.byte CMD_SHAPE, $4F
	.byte Gb3, eighth
	.byte CMD_SHAPE, $8F
	.byte E3, quarter + eighth
	.byte CMD_SHAPE, $4F
	.byte E3, eighth
	.byte CMD_SHAPE, $8F
	.byte Ab3, quarter + eighth
	.byte CMD_SHAPE, $4F
	.byte Ab3, eighth
	.byte CMD_SHAPE, $8F
	.byte E3, quarter + eighth
	.byte CMD_SHAPE, $4F
	.byte E3, eighth
	.byte CMD_SHAPE, $8F
	.byte C4, quarter
	.byte B3, eighth / 2
	.byte Db4, eighth / 2
	.byte B3, half
	.byte A3, eighth
	.byte Ab3, quarter + eighth
	.byte Gb3, eighth
	.byte CMD_JUMP
	.word swingy_pulse

swingy_tri:
	.byte CMD_SHAPE, $FF
	.byte E3, half
	.byte Ab3, half
	.byte Gb3, quarter
	.byte E3, quarter
	.byte Eb3, quarter
	.byte Db3, half
	.byte A2, quarter
	.byte Eb3, quarter
	.byte B2, half
	.byte A2, quarter
	.byte Db3, quarter
	.byte Eb3, quarter
	.byte CMD_JUMP
	.word swingy_tri
