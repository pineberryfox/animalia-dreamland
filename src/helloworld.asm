.include "constants.inc"
.include "fontmap.inc"
.include "header.inc"

.import logoscreen, titlescreen, winscreen, losescreen

.segment "CODE"
.proc irq_handler
	RTI
.endproc

.export wait_vblank
.proc wait_vblank
	PHA
	LDA #$FF
	STA frame
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

	LDA frame
	BMI end
	INC $FF
end:
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
	LDX #$00
	STX srandr
	STX frame
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
	JSR logoscreen

	LDA #$FF
	STA should_srand

	.import song, testsong_pulse, testsong_tri
	.importzp duration
	LDA #<testsong_pulse
	STA song
	LDA #>testsong_pulse
	STA song + 1
	LDA #<testsong_tri
	STA song + 2
	LDA #>testsong_tri
	STA song + 3
	LDA #$01
	STA duration
	STA duration + 1
mainloop:
	JSR titlescreen
	JSR threelevel
	CPY #$00
	BNE won
lost:	JSR losescreen
	JMP mainloop
won:	JSR winscreen
	JMP mainloop
.endproc

.import level_list
.proc threelevel
	;; Fisher-Yates the level list
	LDX last_level
prefill:TXA
	STA level_list,X
	DEX
	BPL prefill

	LDX last_level
	DEX
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
	JSR loadlevel
	JSR maingame
	CPY #$00
	BEQ end
	LDA level_list + 1
	JSR loadlevel
	JSR maingame
	CPY #$00
	BEQ end
	LDA level_list + 2
	JSR loadlevel
	JSR maingame
end:	RTS
.endproc

	;; maingame returns a Boolean for whether we won or not in Y
.importzp cy, player_overy
.import draw_dusts, update_dusts
.proc maingame
	LDA #$00
	STA frame
	JSR draw_player
	JSR draw_crystals
	JSR draw_dusts
	JSR readjoy
	JSR update_player
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
.import dusty, last_level, levels
.proc loadlevel
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
	AND #$07
	BNE next
	LDA #$40
next:	AND #$F8
	ORA #$08
	STA player_base ; either $08 or $48

	LDA #$00
	STA buttons
	JSR update_player
	JSR draw_player
	JSR draw_crystals
	LDA #$01
	STA camx

	;; assign jump duration deltat and height deltay
	JSR rand
	AND #$1F
	CLC
	ADC #$42
	STA deltay
	STA dividend + 1

	JSR rand
	AND #$0F
	CLC
	ADC #$28
	STA deltat
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

.import lv1
.import lv2
.import lv3

.segment "BSS"
should_srand: .res 1
camx: .res 1
deltat: .res 1
deltay: .res 1
remainder: .res 2
dividend: .res 2
temp: ; shared with divisor
divisor: .res 1
srandr: .res 1
.export camx, deltat, deltay, dividend, divisor, temp, remainder, srandr
.export should_srand
.import airfric, fric, grav, jumpforce

.segment "ZEROPAGE"
ready: .res 1
frame: .res 1
timer: .res 3
.exportzp ready, timer
.importzp buttons, level, player_base
