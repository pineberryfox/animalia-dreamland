.include "notes.inc"
.export split_pulse, split_tri


quarter = 9
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half
whole2 = 2 * whole

.segment "RODATA"
split_pulse:
	.byte CMD_SHAPE, $80
	.byte CMD_DECAY_OFF, CMD_SUSTAIN_OFF
split_pulse_in:
	.byte rest, whole * 4
	.byte CMD_SHAPE, $8F
	.byte CMD_SUSTAIN_ON, CMD_DECAY_ON
	.byte E3, half
	.byte CMD_SUSTAIN_OFF
	.byte D3, quarter
	.byte CMD_SUSTAIN_ON
	.byte E3, half
	.byte CMD_SUSTAIN_OFF
	.byte D3, quarter
	.byte E3, quarter
	.byte Gb3, quarter
	.byte CMD_SUSTAIN_ON
	.byte G3, half
	.byte CMD_SUSTAIN_OFF
	.byte Gb3, quarter
	.byte CMD_SUSTAIN_ON
	.byte E3, quarter + half
	.byte CMD_SHAPE, $80
	.byte CMD_DECAY_OFF
	.byte rest, half + whole
	.byte rest, whole
	.byte CMD_JUMP
	.word split_pulse_in

split_tri:
	.byte CMD_SHAPE, $FF
	.byte E4, quarter
	.byte Gb4, quarter
	.byte G4, quarter
	.byte E4, quarter
	.byte Gb4, quarter
	.byte G4, quarter
	.byte E4, quarter
	.byte G4, quarter

	.byte E4, quarter
	.byte Gb4, quarter
	.byte B4, quarter
	.byte E4, quarter
	.byte Gb4, quarter
	.byte B4, quarter
	.byte E4, quarter
	.byte B4, quarter

	.byte E4, quarter
	.byte Gb4, quarter
	.byte C5, quarter
	.byte E4, quarter
	.byte Gb4, quarter
	.byte C5, quarter
	.byte E4, quarter
	.byte C5, quarter

	.byte E4, quarter
	.byte Gb4, quarter
	.byte B4, quarter
	.byte E4, quarter
	.byte Gb4, quarter
	.byte B4, quarter
	.byte E4, quarter
	.byte B4, quarter

	.byte E4, quarter
	.byte C5, quarter
	.byte B4, quarter
	.byte A4, quarter
	.byte G4, quarter
	.byte Gb4, quarter
	.byte D4, quarter
	.byte F4, quarter
	.byte CMD_JUMP
	.word split_tri
