.include "constants.inc"

.segment "CODE"
.export draw_dusts
.proc draw_dusts
	LDX #$0F
	LDY #$00
place:	LDA dusty,X
	CLC
	ADC #$08
	STA DUST_OAM,Y
	INY
	LDA dustv,X
	LSR A
	LSR A
	CLC
	ADC #$05
	ADC dustd,X
	STA DUST_OAM,Y
	INY
	LDA #$03
	STA DUST_OAM,Y
	INY
	LDA dustx,X
	SEC
	SBC #$04
	STA DUST_OAM,Y
	INY
	DEX
	BPL place
	RTS
.endproc

.export update_dusts
.proc update_dusts
	LDX #$0F
loop:	LDA dustv,X
	BMI end
	DEC dustv,X
	BPL end
	LDA #$F7
	STA dusty,X
end:	DEX
	BPL loop
	RTS
.endproc

.segment "BSS"
dustx: .res 16
dusty: .res 16
dustv: .res 16
dustd: .res 16
cdust: .res 1
.export cdust, dustd, dustx, dusty, dustv
