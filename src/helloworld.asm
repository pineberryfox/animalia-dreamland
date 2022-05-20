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
	LDA #$08
	STA PPUSCROLL
	LDA #$00
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
	LDA #$08
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

.import lvextract
.import rand
.import srand
.import readjoy
.import reset_handler

.import draw_player
.import update_player

.export main
.proc main
	LDX #$00
	STX camx
	STX PPUMASK
	LDY #$00
	LDA #$00
	JSR srand
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
	LDA #$1E
	STA PPUMASK

	LDA #<lv1
	STA level
	LDA #>lv1
	STA level+1
	JSR loadlevel

mainloop:
	JSR draw_player
	JSR readjoy
	JSR update_player
	LDA #BTN_START
	bit buttons
	BEQ noload
	JSR loadlevel
noload: JSR wait_vblank
	JMP mainloop
.endproc

.proc loadlevel
	LDA #$00
	STA camx
	LDA #$0E
	STA PPUMASK
	JSR lvextract
	LDA #$00
	STA buttons
	JSR update_player
	JSR draw_player
	LDA #$01
	STA camx
	JSR rand
	AND #$3F
	CLC
	ADC #$06
	STA fric
	CMP #26
	BPL summer
	LDY #$55
	LDA #$00
	JMP season
summer: LDY #$00
	LDA #$20
season: ORA #$1E
	STA PPUMASK

	;; this is where we should assign gravity and jump force

	;; set palette accordingly
	JSR wait_vblank
	BIT PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C0
	STA PPUADDR
	LDX #$40
wpal:	STY PPUDATA
	DEX
	BNE wpal
	JSR wait_vblank

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

.import lv1
.import lv2
.import lv3

.segment "BSS"
camx: .res 1
.export camx
.import fric

.segment "ZEROPAGE"
ready: .res 1
.exportzp ready
.importzp buttons, level
