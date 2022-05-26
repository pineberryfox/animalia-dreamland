.include "constants.inc"
.include "fontmap.inc"

.import readjoy, srand, udiv16o8, wait_vblank
.import draw_player, update_player
.import fake_level_for_end, player_vx, player_vy, prevbuttons
.import camx, deltat, deltay, dividend, divisor, temp, remainder, srandr
.import should_srand
.importzp buttons, player_base, player_dir, player_tile
.importzp level, timer, player_x, player_y, player_overy

.segment "CODE"

.proc clear2000
	LDA #$00
	STA PPUMASK
	LDY #$03
ol:	TYA
	CLC
	ADC #$20
	BIT PPUSTATUS
	STA PPUADDR
	LDX #$00
	STX PPUADDR
	TXA
il:	STA PPUDATA
	DEX
	BNE il
	DEY
	BPL ol
	LDA #$23
	STA PPUADDR
	LDA #$C0
	STA PPUADDR
	LDA #$AA
	LDX #$40
wpal:	STA PPUDATA
	DEX
	BNE wpal
	LDA #$0E
	STA PPUMASK
	RTS
.endproc


.export logoscreen
.proc logoscreen
	JSR clear2000
	LDA #$00
	BIT PPUSTATUS
	STA PPUMASK
	LDA #$23
	STA PPUADDR
	LDA #$C0
	STA PPUADDR
	LDA #$FF
	LDX #$40
wpal:	STA PPUDATA
	DEX
	BNE wpal
	LDA #$3F
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	LDA #$0C
	STA PPUDATA
	;; palettes set; now let's display the logo
	BIT PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$CD
	STA PPUADDR
	LDY #$CA
	LDX #$06
logo1:	STY PPUDATA
	INY
	DEX
	BNE logo1
	LDA #$21
	STA PPUADDR
	LDA #$ED
	STA PPUADDR
	LDY #$DA
	LDX #$06
logo2:	STY PPUDATA
	INY
	DEX
	BNE logo2
	LDA #$22
	STA PPUADDR
	LDA #$0D
	STA PPUADDR
	LDY #$EA
	LDX #$06
logo3:	STY PPUDATA
	INY
	DEX
	BNE logo3
	LDA #$22
	STA PPUADDR
	LDA #$2D
	STA PPUADDR
	LDY #$FA
	LDX #$06
logo4:	STY PPUDATA
	INY
	DEX
	BNE logo4
	;; wordmark time :D
	LDY #$00
	LDA #$22
	STA PPUADDR
	LDA #$4B
	STA PPUADDR
word1:	LDA logomark,Y
	BEQ word1e
	CLC
	ADC #$60
	STA PPUDATA
	INY
	JMP word1
word1e:	INY
	LDA #$22
	STA PPUADDR
	LDA #$6E
	STA PPUADDR
word2:	LDA logomark,Y
	BEQ word2e
	CLC
	ADC #$60
	STA PPUDATA
	INY
	JMP word2
word2e:
	;; turn the display on (no sprites tho)
	LDA #$0E
	STA PPUMASK
	LDX #$80
lp:	JSR wait_vblank
	DEX
	BNE lp
	RTS
.endproc


.export titlescreen
.proc titlescreen
	JSR clear2000
	JSR wait_vblank
	LDA #$00
	STA cheatpos
	STA PPUMASK
	;; display title
	BIT PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$EC
	STA PPUADDR
	LDX #$06
	LDY #$2A
tl:	STY PPUDATA
	INY
	CPY #$2C
	BNE nospc
	LDA #$20
	STA PPUDATA
nospc:	DEX
	BNE tl
	LDA #$21
	STA PPUADDR
	LDA #$0B
	STA PPUADDR
	LDY #$00
tlt:	LDA title_word,Y
	BEQ endtitletop
	STA PPUDATA
	INY
	JMP tlt
endtitletop:
	LDA #$21
	STA PPUADDR
	LDA #$2B
	STA PPUADDR
	LDY #$00
tlb:	LDA title_word,Y
	BEQ endtitleword
	CLC
	ADC #$30
	STA PPUDATA
	INY
	JMP tlb
endtitleword:
	;; now add "press start"
	LDA #$22
	STA PPUADDR
	LDA #$EA
	STA PPUADDR
	LDY #$00
st:	LDA press_start,Y
	BEQ endst
	CLC
	ADC #$60
	STA PPUDATA
	INY
	JMP st
endst:
	;; BG colour
	LDA #$0E
	STA PPUMASK
	LDA #$3F
	BIT PPUSTATUS
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	STA camx ; and ensure we're using the right screen
	LDA #$0C
	STA PPUDATA

getkey:	INC srandr
	JSR wait_vblank
	JSR readjoy
	LDA prevbuttons
	EOR #$FF
	AND buttons
	AND #(BTN_UP | BTN_DOWN | BTN_LEFT | BTN_RIGHT)
	BEQ real_check
	LDX cheatpos
	STA cheat,X
	INX
	TXA
	AND #$0F
	STA cheatpos
real_check:
	LDA prevbuttons
	EOR #$FF
	AND #BTN_SELECT
	BIT buttons
	BEQ no_cheat
	JSR handle_cheat
no_cheat:
	LDA prevbuttons
	EOR #$FF
	AND #(BTN_A | BTN_B | BTN_START)
	BIT buttons
	BEQ getkey
	LDX srandr
	LDY should_srand
	BEQ no_srand
	LDY #$00
	STA should_srand
	JSR srand
no_srand:
	JSR wait_vblank
	JSR clear2000
	JSR wait_vblank
	RTS
.endproc


.proc fill_timerstr
	;; fill timerstr from timer,
	;; we'll be using the division vars as temps later
	LDA #$BA
	LDX #$08
dashy:	STA timerstr,X
	DEX
	BPL dashy
	LDA #99
	CMP timer + 2
	BPL mins
	JMP colondot
	;; minutes
mins:	LDA timer + 2
	STA dividend
	LDA #$00
	STA dividend + 1
	LDA #$0A
	STA divisor
	JSR udiv16o8
	LDA dividend
	ORA #$B0
	STA timerstr
	LDA remainder
	ORA #$B0
	STA timerstr + 1
	;; seconds
	LDA timer + 1
	STA dividend
	LDA #$0A
	STA divisor
	JSR udiv16o8
	LDA dividend
	ORA #$B0
	STA timerstr + 3
	LDA remainder
	ORA #$B0
	STA timerstr + 4
	;; frame
	;; x1000/60 is x50/3; x50 is (x16+x8+x1)x2
	LDA timer
	STA dividend
	STA temp
	ASL dividend
	ROL dividend + 1
	LDA dividend
	CLC
	ADC temp
	STA dividend
	LDA dividend + 1
	ADC #$00
	STA dividend + 1
	ASL temp
	LDX #$04
mul16:	ASL dividend
	ROL dividend + 1
	DEX
	BNE mul16
	LDA dividend
	CLC
	ADC temp
	STA dividend
	LDA dividend + 1
	ADC #$00
	STA dividend + 1
	LDA #$03 ; divide by 3
	STA divisor
	JSR udiv16o8 ; and we're actually using more than 8 bits!
	;; now let's get some digits!
	LDA #$0A
	STA divisor
	JSR udiv16o8
	LDA remainder
	ORA #$B0
	STA timerstr + 8
	JSR udiv16o8
	LDA remainder
	ORA #$B0
	STA timerstr + 7
	LDA dividend
	ORA #$B0
	STA timerstr + 6
colondot:
	LDX #$BB
	STX timerstr + 2
	INX
	STX timerstr + 5
	RTS
.endproc


	;; clear the screen, draw the bed
	;; and display the timer under the bed
.proc win_or_lose
	JSR clear2000
	LDX #$00
	STX PPUMASK
	STX player_tile
	STX player_vx
	STX player_vx + 1
	STX player_y
	STX player_y + 1
	STX player_overy
	STX dividend
	INX
	STX player_dir
	LDA #$80
	STA player_x
	LDA #$78
	STA player_y
	LDA #$FF
	TAX
	INX
lp:	STA $200,X
	DEX
	BNE lp

	LDA #$23
	STA PPUADDR
	LDA #$C0
	STA PPUADDR
	LDA #$AA
	LDX #$40
wpal:	STA PPUDATA
	DEX
	BNE wpal

	LDA #$3F
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	LDA #$0C
	STA PPUDATA

	LDA #$22
	STA PPUADDR
	LDA #$4B
	STA PPUADDR
	LDY #$E5
	STY PPUDATA
	INY
	LDX #$05
bed:	STY PPUDATA
	DEX
	BNE bed
	INY
	STY PPUDATA
	INY
	STY PPUDATA
	INY
	STY PPUDATA

	LDA #$22
	STA PPUADDR
	LDA #$6B
	STA PPUADDR
	LDY #$F5
	STY PPUDATA
	INY
	LDX #$05
bedb:	STY PPUDATA
	DEX
	BNE bedb
	INY
	STY PPUDATA
	INY
	STY PPUDATA
	INY
	STY PPUDATA

	LDA #$22
	STA PPUADDR
	LDA #$31
	STA PPUADDR
	LDY #$D7
	STY PPUDATA
	INY
	STY PPUDATA
	INY
	STY PPUDATA

	LDA #$22
	STA PPUADDR
	LDA #$AB
	STA PPUADDR
	LDY #$00
	LDX #$09
tstr:	LDA timerstr,Y
	STA PPUDATA
	INY
	DEX
	BNE tstr
	RTS
.endproc


.export winscreen
.proc winscreen
	JSR fill_timerstr
	JSR win_or_lose

	JSR draw_player

	LDA #$00
	STA camx
	LDA #$1E
	STA PPUMASK
	LDX #$40
cd:	JSR wait_vblank
	DEX
	BNE cd

	;; gonna have some hops, fake a level and do it in-engine
	LDA #<fake_level_for_end
	STA level
	LDA #>fake_level_for_end
	STA level + 1
	LDA buttons
	STA temp
	LDA deltat
	LSR A
	LSR A
	STA dividend + 1

key:	JSR wait_vblank
	LDA temp
	STA buttons
	JSR readjoy
	LDA buttons
	STA temp
	LDA prevbuttons
	EOR #$FF
	AND #(BTN_A | BTN_B | BTN_START)
	BIT buttons
	BNE end
	LDA dividend
	STA prevbuttons
	DEC dividend + 1
	BNE nofl
	EOR #BTN_A
	STA dividend
	LDA deltat
	LSR A
	LSR A
	STA dividend + 1
nofl:	LDA dividend
	STA buttons
	JSR update_player
	JSR draw_player
	JMP key
end:	RTS
.endproc


.export losescreen
.proc losescreen
	LDX #$00
copy:	LDA game_over,X
	BEQ endl
	CLC
	ADC #$60
	STA timerstr,X
	INX
	JMP copy
endl:	JSR win_or_lose

	LDA #$22
	STA PPUADDR
	LDA #$2B
	STA PPUADDR
	LDY #$D4
	STY PPUDATA
	INY
	STY PPUDATA
	STY PPUDATA
	STY PPUDATA
	STY PPUDATA
	STY PPUDATA
	INY
	STY PPUDATA
	LDA #$22
	STA PPUADDR
	LDA #$11
	STA PPUADDR
	LDA #$E4
	STA PPUDATA

	LDA #$00
	STA camx
	LDA #$1E
	STA PPUMASK
	LDX #$40
cd:	JSR wait_vblank
	DEX
	BNE cd

key:	JSR wait_vblank
	JSR readjoy
	LDA prevbuttons
	EOR #$FF
	AND #(BTN_A | BTN_B | BTN_START)
	BIT buttons
	BEQ key
	RTS
.endproc

.proc handle_cheat
	LDA #BTN_UP
	BIT cheat
	BEQ end
	LDA #BTN_DOWN
	BIT cheat + 1
	BEQ end
	LDA #BTN_RIGHT
	BIT cheat + 2
	BEQ end
	JSR wait_vblank
	BIT PPUSTATUS
	LDA #$3F
	STA PPUADDR
	LDA #$13
	STA PPUADDR
	LDA #$25
	STA PPUDATA
end:	LDA #$00
	STA cheatpos
	RTS
.endproc


.segment "RODATA"
logomark:
.asciiz "Pineberry"
.asciiz "Fox"
title_word:
.asciiz "SOMNIORUM"
press_start:
.asciiz "Press Start"
game_over:
.asciiz "Game Over"


.segment "BSS"
timerstr: .res 9
.align 16
cheat: .res 16
cheatpos: .res 1
