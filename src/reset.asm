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

	; initialize zero-page
	LDA #$20
	STA player_x
	LDA #$d0
	STA player_y
	LDA #$01
	STA player_tile
	LDA maxt
	STA timer
	LDA #$01
	STA player_dir
	JMP main
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, player_tile, player_dir, timer
