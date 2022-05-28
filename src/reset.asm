.include "constants.inc"

.segment "CODE"
.import main
.import maxt
.export reset_handler
.proc reset_handler
	SEI
	CLD
	LDX #$00
	STX PPUCTRL
	STX PPUMASK
vblankwait:
	BIT PPUSTATUS
	BPL vblankwait

	LDX #$00
	LDA #$ff
clear_oam:
	STA $0200,X ; set sprite y-positions off-screen
	INX
	INX
	INX
	INX
	BNE clear_oam
	DEX

	LDX #$00
	TXA
clear_zp:
	STA $00,X
	INX
	BNE clear_zp

clear_3xx:
	STA $300,X
	INX
	BNE clear_3xx
	DEX
clear_4xx:
	STA $400,X
	INX
	BNE clear_4xx
	DEX
clear_5xx:
	STA $500,X
	INX
	BNE clear_5xx
	DEX
clear_6xx:
	STA $600,X
	INX
	BNE clear_6xx
	DEX
clear_7xx:
	STA $700,X
	INX
	BNE clear_7xx
	DEX
	TXS

	JMP main
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, player_tile, player_dir, timer
