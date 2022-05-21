.include "constants.inc"

.segment "CODE"

.import init_player
.import wait_vblank

	;; lvextract
	;; precondition: "level" contains the address of a level's data
	;; postconditions:
	;; * "level" is unchanged
	;; * the pointed-to level has been drawn to the screen
.export lvextract
.proc lvextract
	LDA #$24
	STA write+1
	LDA #$40
	STA write
	LDA #$FF
	STA currow
	STA currow+1
	LDA #$F0
	STA toadd
	LDA #$0E
	STA tempi
dout:	JSR rowread
	JSR wait_vblank
	BIT PPUSTATUS
	LDA write+1
	STA PPUADDR
	LDA write
	STA PPUADDR
	LDX #$10
	LDY #$00
din:	LDA lefts,Y
	STA PPUDATA
	LDA rights,Y
	STA PPUDATA
	INY
	DEX
	BNE din
	JSR wait_vblank
	;; increment write address
	CLC
	LDA write
	ADC #$40
	STA write
	LDA write+1
	ADC #$00
	STA write+1
	;; increment to the next row
	LDA level
	CLC
	ADC #$02
	STA level
	LDA level+1
	ADC #$00
	STA level+1
	DEC tempi
	BNE dout

	;; need to move back a half a thing first
	SEC
	LDA write
	SBC #$20
	STA write
	LDA write+1
	SBC #$00
	STA write+1
	SEC
	LDA level
	SBC #$02
	STA level
	LDA level+1
	SBC #$00
	STA level+1

	;; now for down-to-up

	LDA #$FF
	STA currow
	STA currow+1
	LDA #$10
	STA toadd
	LDA #$0E
	STA tempi
uout:	JSR rowread
	JSR wait_vblank
	BIT PPUSTATUS
	LDA write+1
	STA PPUADDR
	LDA write
	STA PPUADDR
	LDX #$10
	LDY #$00
uin:	LDA lefts,Y
	STA PPUDATA
	LDA rights,Y
	STA PPUDATA
	INY
	DEX
	BNE uin
	JSR wait_vblank
	;; increment write address
	SEC
	LDA write
	SBC #$40
	STA write
	LDA write+1
	SBC #$00
	STA write+1
	;; increment to the next row
	LDA level
	SEC
	SBC #$02
	STA level
	LDA level+1
	SBC #$00
	STA level+1
	DEC tempi
	BNE uout
	;; put the level back where it was supposed to be
	CLC
	LDA level
	ADC #$02
	STA level
	LDA level + 1
	ADC #$00
	STA level + 1
	;; place player
	LDY #$1C
	LDA (level),Y
	AND #$F0
	ORA #$08
	TAX
	LDA (level),Y
	ASL A
	ASL A
	ASL A
	ASL A
	ORA #$08
	TAY
	JSR init_player

	LDX #$03
	LDY #$1D
cloop:	LDA (level),Y
	AND #$F0
	ORA #$08
	STA cx,X
	LDA (level),Y
	ASL A
	ASL A
	ASL A
	ASL A
	ORA #$08
	STA cy,X
	INY
	DEX
	BPL cloop
	RTS
.endproc


.proc rowread
	;; prevrow = currow
	LDA currow
	STA prevrow
	LDA currow+1
	STA prevrow+1
	;; currow = *level;
	LDY #$00
	LDA (level),Y
	STA currow
	INY
	LDA (level),Y
	STA currow+1
	;; 
	;; fill in the lefts from left-to-right, part 1
	LDY #$FF
	STY prevl
	LDX #$00
	CLC
	LDA #$80
ltr1:	BIT currow
	BNE ltra1
	LDY #$00
	STY nprevl
	JMP ltrx1
ltra1:	LDY #$FF
	STY nprevl
	LDY #$12
	BIT prevrow
	BNE lnox1
	PHA
	TYA
	CLC
	ADC toadd
	TAY
	PLA
	CLC
lnox1:	BIT prevl
	BMI ltrx1
	DEY
ltrx1:	STY lefts,X
	LDY nprevl
	STY prevl
	INX
	ROR A
	BNE ltr1
	;; part 2
	CLC
	LDA #$80
ltr2:	BIT currow+1
	BNE ltra2
	LDY #$00
	STY nprevl
	JMP ltrx2
ltra2:	LDY #$FF
	STY nprevl
	LDY #$12
	BIT prevrow+1
	BNE lnox2
	PHA
	TYA
	CLC
	ADC toadd
	TAY
	PLA
	CLC
lnox2:	BIT prevl
	BMI ltrx2
	DEY
ltrx2:	STY lefts,X
	LDY nprevl
	STY prevl
	INX
	ROR A
	BNE ltr2
	;; 
	;; now to the right-to-lefts in reverse order!
	LDY #$FF
	STY prevl
	LDX #$0F
	CLC
	LDA #$01
rtl1:	BIT currow+1
	BNE rtla1
	LDY #$00
	STY nprevl
	JMP rtlx1
rtla1:	LDY #$FF
	STY nprevl
	LDY #$12
	BIT prevrow+1
	BNE rnox1
	PHA
	TYA
	CLC
	ADC toadd
	TAY
	PLA
	CLC
rnox1:	BIT prevl
	BMI rtlx1
	INY
rtlx1:	STY rights,X
	LDY nprevl
	STY prevl
	DEX
	ROL A
	BNE rtl1
	;; part 2
	CLC
	LDA #$01
rtl2:	BIT currow
	BNE rtla2
	LDY #$00
	STY nprevl
	JMP rtlx2
rtla2:	LDY #$FF
	STY nprevl
	LDY #$12
	BIT prevrow
	BNE rnox2
	PHA
	TYA
	CLC
	ADC toadd
	TAY
	PLA
	CLC
rnox2:	BIT prevl
	BMI rtlx2
	INY
rtlx2:	STY rights,X
	LDY nprevl
	STY prevl
	DEX
	ROL A
	BNE rtl2
.endproc

.segment "RODATA"
.export lv1
lv1:
.byte $00, $00, $00, $00, $00, $00, $00, $00
.byte $0F, $E0, $00, $00, $80, $00, $00, $00
.byte $0E, $00, $0E, $00, $00, $00, $80, $03
.byte $FF, $03, $FF, $03
.byte $1B ; player spawn (1,11)
.byte $05
.byte $D1
.byte $FA
.byte $AD

.export lv2
lv2:
.byte $00, $00, $00, $00, $00, $00, $0F, $80
.byte $0F, $80, $0C, $00, $0C, $00, $0C, $18
.byte $00, $00, $00, $00, $01, $80, $01, $80
.byte $01, $80, $F9, $8F
.byte $0C ; player spawn (8,10)

.segment "BSS"
currow:  .res 2
prevrow: .res 2
toadd:   .res 1

.segment "ZEROPAGE"
write:   .res 2
tempi:   .res 1
prevl:   .res 1
nprevl:  .res 1
level:   .res 2
lefts:   .res 16
rights:  .res 16
cx: .res 4
cy: .res 4
.importzp ready
.exportzp cx, cy, level
