.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
	RTI
.endproc

.export wait_vblank
.proc wait_vblank
	PHA
	LDA #$90
	ORA camx
	BIT PPUSTATUS
	STA PPUCTRL
	LDA #$00
	STA PPUSCROLL
	STA PPUSCROLL
	STA ready
wait:	LDA ready
	BEQ wait
	PLA
	RTS
.endproc

.proc nmi_handler
	;; need push/pull?
	PHA
	TXA
	PHA
	TYA
	PHA
	;; pushed
	LDA #$00
	STA OAMADDR
	LDA #$02
	STA OAMDMA
	BIT PPUSTATUS
	LDA #$00
	STA PPUSCROLL
	STA PPUSCROLL
	INC ready
	;; start pulling
	PLA
	TAY
	PLA
	TAX
	PLA
	RTI
.endproc

.import reset_handler
.import readjoy
.import lvextract

.export main
.proc main
	LDX #$00
	STX camx
	STX player_state
	LDX PPUSTATUS
	LDX #$3f
	STX PPUADDR
	LDX #$00
	STX PPUADDR
load_palettes:
	LDA palettes,X
	STA PPUDATA
	INX
	CPX #$20
	BNE load_palettes

vblankwait: ; wait for another vblank before continuing
	BIT PPUSTATUS
	BPL vblankwait

	LDA #%10010000 ; turn on NMIs, sprites use first pattern table
	STA PPUCTRL
	LDA #%00011110
	STA PPUMASK
	LDA #$08
	STA player_base

	LDA #<lv2
	STA level
	LDA #>lv2
	STA level+1
	JSR lvextract
	LDA #$01
	STA camx

	BIT PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C0
	STA PPUADDR
	LDX #$40
	LDA #%01010101
wpal:	STA PPUDATA
	DEX
	BNE wpal
	JSR wait_vblank

mainloop:
	JSR draw_player
	JSR readjoy
	JSR update_player
	JSR wait_vblank
	JMP mainloop
.endproc

.proc draw_player
	; save registers
	PHP
	PHA

	LDA player_dir ; palette 0, no flippage
	EOR #$01
	CLC
	ROR A
	ROR A
	ROR A
	STA $0202
	STA $0206
	STA $020A
	STA $020E
	BNE leftface
	LDA player_tile
	CLC
	ADC player_base
	STA $0201
	CLC
	ADC #$01
	STA $0205
	CLC
	ADC #$0F
	STA $0209
	CLC
	ADC #$01
	STA $020D
	JMP placed
leftface:
	LDA player_base
	SEC
	SBC #$10
	BCS notham
	LDA player_tile
	CLC
	ADC #$20
	JMP eitherway
notham:
	LDA player_tile
eitherway:
	CLC
	ADC player_base
	STA $0205
	CLC
	ADC #$01
	STA $0201
	CLC
	ADC #$0F
	STA $020D
	CLC
	ADC #$01
	STA $0209
	JMP placed
placed:
	LDA player_y
	STA $0208
	STA $020C
	SEC
	SBC #$08
	STA $0200
	STA $0204
	LDA player_x
	STA $0207
	STA $020F
	SEC
	SBC #$08
	STA $0203
	STA $020B

	; restore registers
	PLA
	PLP
	RTS
.endproc

.proc update_player
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA

	LDA player_state
	BEQ end_update_frame
	DEC timer
	BNE end_update_frame
	LDA maxt
	STA timer
	LDA player_tile
	LSR A
	CLC
	ADC #$01
	AND #$03
	ASL A
	STA player_tile
end_update_frame:

	LDA buttons
	AND #BTN_RIGHT
	BEQ not_right
	LDA #$01
	STA player_dir
	STA player_state
	INC player_x
	JMP done
not_right:
	LDA buttons
	AND #BTN_LEFT
	BEQ idle
	LDA #$00
	STA player_dir
	LDA #$01
	STA player_state
	DEC player_x
	JMP done
idle:
	LDA #$00
	STA player_tile
	LDA #$00
	STA player_state
done:

exit_subr:
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "abm.chr"

.segment "RODATA"
palettes:
; bgs
.byte $21, $1B, $17, $29
.byte $21, $1C, $32, $32
.byte $21, $0C, $30, $27 ; sprite palette 1
.byte $21, $0C, $32, $27 ; sprite palette 2
;.byte $1D, $00, $10, $20 ; grey ramp
; sprites
.byte $21, $0c, $30, $27
.byte $21, $0C, $32, $27
.byte $1c, $0c, $30, $27
.byte $1c, $0c, $30, $27

sprites:
.byte $70, $01, $00, $80

.export maxt
maxt:
.byte $04

.import lv1
.import lv2

.segment "BSS"
camx: .res 1
.export camx

.segment "ZEROPAGE"
ready: .res 1
player_x: .res 1
player_y: .res 1
player_tile: .res 1
player_base: .res 1
player_dir: .res 1
player_state: .res 1
timer: .res 1
.exportzp player_x, player_y, player_tile, player_dir, timer, ready
.importzp buttons, level
