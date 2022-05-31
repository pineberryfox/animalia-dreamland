.include "constants.inc"
.include "fontmap.inc"
.include "header.inc"

.import logoscreen, titlescreen, winscreen, losescreen
.importzp prevbuttons

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
	;; pushed
	LDA #$00
	STA OAMADDR
	LDA #$02
	STA OAMDMA
	INC ready

	;; start pulling
	PLA
	RTI
.endproc

.import init_apu
.import lvextract
.import rand
.import srand
.import readjoy
.import reset_handler

.import draw_player
.import update_player

.import draw_crystals
.import crystal_get

.export main
.proc main
	JSR init_apu
	LDX #$08 + MINJUMPT
	STX deltat
	LDX #$10 + MINJUMPY
	STX deltay
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
	JSR logoscreen

	LDA #$FF
	STA should_srand

	;; reshuffle the level list each time
	;; without reinitializing
	LDX #last_level
prefill:TXA
	STA level_list,X
	DEX
	BPL prefill
mainloop:
	JSR titlescreen
	BIT mode
	BMI play_everything
	JSR threelevel
	JMP mainloop
play_everything:
	JSR all_levels
	JMP mainloop
.endproc

.import ordered_levels
.proc all_levels
	LDA #$00
	STA timer
	STA timer + 1
	STA timer + 2
	STA all_level_progress

lp:	LDX all_level_progress
	LDA ordered_levels,X
	CMP #$FF
	BEQ win
	JSR load_level
	JSR maingame
	CPY #$00
	BEQ lp
	INC all_level_progress
	JMP lp
win:	JMP winscreen
.endproc

.import level_list
.proc threelevel
	;; Fisher-Yates the level list
	LDX #last_level
shuf:	INX
	TXA
	PHA
	JSR rand
	STA dividend
	LDA #$00
	STA dividend + 1
	PLA
	PHA
	STA divisor
	JSR udiv16o8
	PLA
	TAX
	DEX
	LDY remainder
	LDA level_list,Y
	STA temp
	LDA level_list,X
	STA level_list,Y
	LDA temp
	STA level_list,X
	DEX
	CMP #$01
	BNE shuf

	LDA #$00
	STA timer
	STA timer + 1
	STA timer + 2
	;; play three levels
	LDA level_list
	JSR load_level
	JSR maingame
	CPY #$00
	BEQ lost
	LDA level_list + 1
	JSR load_level
	JSR maingame
	CPY #$00
	BEQ lost
	LDA level_list + 2
	JSR load_level
	JSR maingame
	CPY #$00
	BNE all_levels::win ; tail-call, won't execute losescreen
lost:	JMP losescreen ; tail-call
.endproc

	;; maingame returns a Boolean for whether we won or not in Y
.importzp cy, player_overy
.import draw_dusts, update_dusts
.import advance_audio, load_sfx
.proc maingame
	LDA #$00
	STA sfx_to_play
	JSR draw_player
	JSR draw_crystals
	JSR draw_dusts
	JSR readjoy
	LDA prevbuttons
	EOR #$FF
	AND #BTN_START
	BIT buttons
	BEQ cont
	JSR pause_screen
	JMP maingame
cont:	JSR update_player
	JSR crystal_get
	JSR update_dusts
	LDA cy
	AND cy+1
	AND cy+2
	AND cy+3
	LDY #$01
	EOR #$FF
	BEQ end
	LDY #$00
	LDX player_overy
	DEX
	BPL end
	LDA sfx_to_play
	BEQ nosfx
	JSR load_sfx
nosfx:	JSR advance_audio
	JSR wait_vblank
	LDX #$00
	LDA #60
	INC timer
	CMP timer
	BNE fin
	STX timer
	INC timer + 1
	CMP timer + 1
	BNE fin
	STX timer + 1
	LDA #99
	INC timer + 2
	CMP timer + 2
	BPL fin
	STA timer + 2
fin:	JMP maingame
end:	RTS
.endproc

	;; which level? the contents of A
.importzp dusty, last_level
.import levels
.import load_song
.proc load_level
	PHA
	JSR load_song
	LDA #$FF
	JSR load_sfx
	PLA
	LDX #$0E
	STX PPUMASK

	LDX #$00
	STX level + 1
	STA level
	ASL A
	ROL level + 1
	CLC
	ADC level
	STA level
	LDX #$04
lvmul:	CLC
	ROL level
	ROL level + 1
	DEX
	BNE lvmul
	;; successfully multiplied, now add to pointer
	CLC
	LDA level
	ADC #<levels
	STA level
	LDA level + 1
	ADC #>levels
	STA level + 1
	;; now load it
	JSR wait_vblank
	LDA #$3F
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	LDA #$0C
	STA PPUDATA
	JSR wait_vblank
	JSR showlevel
	LDX #$00
	STX camx
	JSR wait_vblank
	JSR lvextract
	JSR wait_vblank
	LDA #$3F
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	LDA palettes
	STA PPUDATA
	JSR wait_vblank

	;; assign species
	JSR rand
	AND #$1F
	BNE next
	LDA #$48
	JMP speciesd
next:	LDA #$08
speciesd:
	STA player_base

	LDA #$00
	STA buttons
	JSR update_player
	JSR draw_player
	JSR draw_crystals
	LDA #$01
	STA camx

	;; assign jump duration deltat and height deltay
	LDA #$01
	BIT mode
	BNE lucidy
	JSR rand
	AND #$1F
	CLC
	ADC #MINJUMPY
	STA deltay
lucidy:	LDA deltay
	STA dividend + 1

	LDA #$01
	BIT mode
	BNE lucidt
	JSR rand
	AND #$0F
	CLC
	ADC #MINJUMPT
	STA deltat
lucidt:	LDA deltat
	;; find initial vertical velocity: v0 = deltay / (4 deltat)
	LSR A
	LSR A
	STA divisor
	LDA #$00
	STA dividend
	JSR udiv16o8
	;; gotta negate this (but let's not add one)
	LDA dividend
	EOR #$FF
	STA jumpforce
	LDA dividend + 1
	EOR #$FF
	STA jumpforce + 1

	;; find gravity
	LSR divisor
	LDA #$00
	STA dividend
	LDA deltay
	STA dividend + 1
	JSR udiv16o8
	LDA deltat
	STA divisor
	JSR udiv16o8
	LDA dividend
	STA grav

	JSR rand
	AND #$0F
	CLC
	ADC #$0E
	STA airfric

	JSR rand
	AND #$3F
	CLC
	ADC #$06
	STA fric
	CMP #$26
	BPL summer
	LDY #$55
	LDA #$00
	JMP season
summer:	LDY #$00
	LDA #$20
season:	ORA #$1E
	STA PPUMASK
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

	;; kill dust
	LDX #$0F
	LDA #$F7
dust:	STA dusty,X
	DEX
	BPL dust

	RTS
.endproc


.proc showlevel
	BIT PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$E8
	STA PPUADDR
	LDY #$21
	LDX #$0F
tops:	LDA (level),Y
	STA PPUDATA
	INY
	DEX
	BNE tops

	BIT PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$08
	STA PPUADDR
	LDY #$21
	LDX #$0F
bots:	LDA (level),Y
	CLC
	ADC #$30
	STA PPUDATA
	INY
	DEX
	BNE bots
	RTS
.endproc



	;; inputs:
	;; * 16-bit little-endian value in dividend
	;; * 8-bit divisor
	;; outputs:
	;; * 16-bit dividend/divisor in dividend
	;; * 8-bit remainder in remainder
	;; divisor remains unchanged
.export udiv16o8
.proc udiv16o8
	LDA #$00
	STA remainder
	STA remainder + 1
	LDX #$10
lp:	ASL dividend
	ROL dividend + 1
	ROL remainder
	ROL remainder + 1
	LDA remainder
	SEC
	SBC divisor
	TAY
	LDA remainder + 1
	SBC #$00
	BCC cont
	STA remainder + 1
	STY remainder
	INC dividend
cont:	DEX
	BNE lp
	RTS
.endproc

.proc pause_screen
	JSR init_apu
key:	JSR wait_vblank
	JSR readjoy
	LDA prevbuttons
	EOR #$FF
	AND #BTN_START
	BIT buttons
	BEQ key
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
.byte $21, $27, $21, $30
.byte $21, $25, $1B, $30
; sprites
.byte $21, $0C, $30, $27
.byte $21, $0C, $16, $27
.byte $21, $1C, $29, $32
.byte $21, $00, $10, $20

.segment "ZEROPAGE"
should_srand: .res 1
camx: .res 1
deltat: .res 1
deltay: .res 1
remainder: .res 2
dividend: .res 2
temp: ; shared with divisor
divisor: .res 1
srandr: .res 1
.exportzp camx, deltat, deltay, dividend, divisor, temp, remainder, srandr
.exportzp should_srand
.importzp airfric, fric, grav, jumpforce

.segment "ZEROPAGE"
mode: .res 1
all_level_progress: .res 1
sfx_to_play: .res 1
ready: .res 1
timer: .res 3
.exportzp ready, timer, sfx_to_play, mode
.importzp buttons, level, player_base
