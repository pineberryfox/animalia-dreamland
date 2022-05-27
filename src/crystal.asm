.include "constants.inc"

.segment "CODE"
.import temp
.export draw_crystals
.proc draw_crystals
	LDX #$03
	LDY #$00
lt:	LDA cy,X
	STA CRYSTAL_OAM,Y
	INY
	LDA #$00
	STA CRYSTAL_OAM,Y
	INY
	LDA #$02
	STA CRYSTAL_OAM,Y
	INY
	LDA cx,X
	SEC
	SBC #$04
	STA CRYSTAL_OAM,Y
	INY
	DEX
	BPL lt

	LDX #$03
lb:	LDA cy,X
	CMP #$FF
	BEQ noadd
	CLC
	ADC #$08
noadd:  STA CRYSTAL_OAM,Y
	INY
	LDA #$10
	STA CRYSTAL_OAM,Y
	INY
	LDA #$02
	STA CRYSTAL_OAM,Y
	INY
	LDA cx,X
	SEC
	SBC #$04
	STA CRYSTAL_OAM,Y
	INY
	DEX
	BPL lb
	RTS
.endproc

.importzp player_x, player_y, player_overy
.export crystal_get
.proc crystal_get
	;; compute manhattan distance of player-center from crystal
	;; if sufficiently small, collect!
	BIT player_overy
	BMI notouchy
	LDX #$03
cloop:  LDA cx,X
	SEC
	SBC player_x
	BPL nonegx
	EOR #$FF ; should add one, but who cares
nonegx: CMP #$0B
	BPL end
	STA temp
	LDA cy,X
	SEC
	SBC player_y
	BPL nonegy
	EOR #$FF ; see above
nonegy: CMP #$0D
	BPL end
	LSR A
	CLC
	ADC temp
	CMP #$0D
	BPL end
	LDY #$FF
	STY cy,X
end:    DEX
	BPL cloop
notouchy:
	RTS
.endproc

.segment "ZEROPAGE"
cx: .res 4
cy: .res 4
.exportzp cx, cy
