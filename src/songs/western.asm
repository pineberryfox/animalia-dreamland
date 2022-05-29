.include "notes.inc"

whole = 48
half = 24
quarter = 12
eighth  = 6
quarterdot = quarter + eighth

.export western_pulse, western_tri

western_pulse:
	.byte CMD_SHAPE, $8F
	.byte CMD_DECAY_ON
western_pulse_loop:
	.byte CMD_SUSTAIN_OFF
	.byte F4, quarter
	.byte F4, eighth
	.byte F4, eighth
	.byte F4, quarter
	.byte G4, quarter
	.byte CMD_SUSTAIN_ON
	.byte Ab4, half
	.byte CMD_SUSTAIN_OFF
	.byte rest, quarter
	.byte Bb4, quarter
	.byte CMD_SUSTAIN_ON
	.byte C5, quarterdot
	.byte CMD_SUSTAIN_OFF
	.byte rest, quarterdot
	.byte Db5, quarter
	.byte C5, quarter
	.byte rest, quarter
	.byte Bb4, quarter
	.byte rest, quarter
	.byte CMD_SUSTAIN_ON
	.byte F4, half
	.byte Ab4, half
	.byte G4, half
	.byte Eb4, half
	.byte F4, whole
	.byte F4, whole
	.byte CMD_JUMP
	.word western_pulse_loop

western_tri:
	.byte CMD_SHAPE, $FF
	.byte F4, quarter
	.byte C5, quarter
	.byte F4, quarter
	.byte C5, quarter
	.byte F4, quarter
	.byte C5, quarter
	.byte F4, quarter
	.byte C5, quarter
	.byte F4, quarter
	.byte C5, quarter
	.byte F4, quarter
	.byte C5, quarter
	.byte F4, quarter
	.byte C5, quarter
	.byte F4, quarter
	.byte C5, quarter

	.byte F4, quarter
	.byte Db5, quarter
	.byte C5, quarter
	.byte Bb4, quarter
	.byte Ab4, quarter
	.byte G4, quarter
	.byte F4, quarter
	.byte Eb4, quarter
	.byte F4, whole
	.byte C4, whole
	.byte CMD_JUMP
	.word western_tri
