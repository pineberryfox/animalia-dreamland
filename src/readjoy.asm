.include "constants.inc"

.segment "CODE"
.export readjoy
.proc readjoy
	LDA buttons
	STA prevbuttons
	LDA #$01
	STA JOYPAD1
	; enable the strobe bit, reading the first bit
	STA buttons
	LSR A ; A = 0
	STA JOYPAD1
	; clear strobe bit, allowing all 8 buttons to be read
loop:
	LDA JOYPAD1
	LSR A       ; bit 0 -> carry
	ROL buttons ; carry -> bit 0, bit 7 -> carry
	BCC loop
	RTS
.endproc

.segment "BSS"
prevbuttons: .res 1
.export prevbuttons

.segment "ZEROPAGE"
buttons: .res 1
.exportzp buttons
