.include "notes.inc"

.segment "RODATA"
.export man_pulse, man_tri

SCALEBASE = E3
BASEDUR = 12
man_pulse_loop:
	.byte CMD_SHAPE, $8F
	.byte CMD_DECAY_OFF
	.byte CMD_SUSTAIN_OFF
	.byte SCALEBASE + $00, BASEDUR
	.byte SCALEBASE + $0A, BASEDUR
	.byte CMD_SUSTAIN_ON
	.byte SCALEBASE + $0C, BASEDUR
	.byte CMD_SUSTAIN_OFF
	.byte SCALEBASE + $12, BASEDUR
	.byte SCALEBASE + $11, BASEDUR
	.byte SCALEBASE + $0F, BASEDUR
	.byte CMD_SUSTAIN_ON
	.byte SCALEBASE + $0D, BASEDUR
	.byte CMD_SUSTAIN_OFF
	.byte SCALEBASE + $0C, BASEDUR
man_pulse:
	.byte CMD_SHAPE, $8F
	.byte SCALEBASE + $00, BASEDUR
	.byte SCALEBASE + $0A, BASEDUR
	.byte SCALEBASE + $0C, BASEDUR
	.byte SCALEBASE + $0F, BASEDUR
	.byte SCALEBASE + $00, BASEDUR
	.byte SCALEBASE + $08, BASEDUR
	.byte CMD_SUSTAIN_ON
	.byte SCALEBASE + $0A, BASEDUR
	.byte CMD_DECAY_ON
	.byte SCALEBASE + $01, BASEDUR
	.byte CMD_SUSTAIN_OFF
	.byte CMD_JUMP
	.word man_pulse_loop

man_tri_loop:
	.byte SCALEBASE +12+ $00, BASEDUR * 4
	.byte SCALEBASE +12+ $03, BASEDUR * 4
man_tri:
	.byte CMD_SHAPE, $FF
	.byte SCALEBASE +12+ $00, BASEDUR * 4
	.byte SCALEBASE    + $0A, BASEDUR
	.byte SCALEBASE    + $05, BASEDUR
	.byte SCALEBASE    + $06, BASEDUR
	.byte SCALEBASE    + $0C, BASEDUR
	.byte CMD_JUMP
	.word man_tri_loop
