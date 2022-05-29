.include "constants.inc"

.segment "CODE"
.import main
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
	TXS

	JMP main
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, player_tile, player_dir, timer
