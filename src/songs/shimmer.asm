.include "notes.inc"
.export shimmer_pulse, shimmer_tri

eighth = 6
quarter = 2 * eighth
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"
shimmer_pulse:
	.byte CMD_SHAPE, $8F
	.byte CMD_DECAY_ON, CMD_SUSTAIN_OFF
	.byte A5, quarter
	.byte Ab5, quarter
	.byte Gb5, quarter
	.byte E5, quarter
	.byte A5, quarter
	.byte Ab5, quarter
	.byte Gb5, quarter
	.byte E5, quarter
	.byte A5, quarter
	.byte Ab5, quarter
	.byte Gb5, quarter
	.byte E5, quarter
	.byte Db5, quarter
	.byte D5, quarter
	.byte E5, quarter
	.byte Gb5, quarter
	.byte CMD_JUMP
	.word shimmer_pulse

	;; A E F# E A G# E F#  A E F# E A G# A
shimmer_tri:
	.byte CMD_SHAPE, $FF
	.byte A3, half
	.byte E4, half
	.byte Gb4, half
	.byte E4, half
	.byte A4, half
	.byte Ab4, half
	.byte E4, half
	.byte Gb4, half

	.byte A3, half
	.byte E4, half
	.byte Gb4, half
	.byte E4, half
	.byte A4, half
	.byte Ab4, half
	.byte A4, whole
	.byte CMD_JUMP
	.word shimmer_tri
