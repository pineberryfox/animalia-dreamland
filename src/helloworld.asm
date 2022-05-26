.include "constants.inc"
.include "header.inc"
.include "fontmap.inc"

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

mainloop:
	JSR titlescreen
	JSR threelevel
	JMP won
	CPY #$00
	BNE won
lost:	; womp womp
	JMP mainloop
won:	JSR winscreen
	JMP mainloop
.endproc

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


.import prevbuttons
.proc titlescreen
	JSR clear2000
	JSR wait_vblank
	LDA #$00
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
tlt:	LDA titleword,Y
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
tlb:	LDA titleword,Y
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
st:	LDA pressstart,Y
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
	AND #(BTN_A | BTN_B | BTN_START)
	BIT buttons
	BEQ getkey
	LDX srandr
	LDY #$00
	JSR srand
	JSR wait_vblank
	JSR clear2000
	JSR wait_vblank
	RTS
.endproc

.proc fill_timerstr
	;; fill timerstr from timer,
	;; we'll be using the division vars as temps later
	LDA #$BA
	LDX #$09
dashy:	STA timerstr,X
	DEX
	BNE dashy
	LDA #100
	CMP timer + 2
	BNE mins
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

.import fake_level_for_end
.importzp player_base, player_dir, player_tile, player_x, player_y
.import player_vx, player_vy
.proc winscreen
	JSR fill_timerstr
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
	JSR draw_player

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
	AND #(BTN_A | BTN_B | BTN_START)
	EOR #$FF
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
.proc maingame
	LDA #$00
	STA frame
	JSR draw_player
	JSR draw_crystals
	JSR readjoy
	JSR update_player
	JSR crystal_get
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
	LDA #100
	INC timer + 2
	CMP timer + 2
	BMI fin
	STA timer + 2
fin:	JMP maingame
end:	RTS
.endproc

	;; which level? the contents of A
.import last_level, levels
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
.byte $21, $0C, $30, $27

logomark:
.asciiz "Pineberry"
.asciiz "Fox"
titleword:
.asciiz "SOMNIORUM"
pressstart:
.asciiz "Press Start"

.import lv1
.import lv2
.import lv3

.segment "BSS"
camx: .res 1
deltat: .res 1
deltay: .res 1
remainder: .res 2
dividend: .res 2
temp: ; shared with divisor
divisor: .res 1
srandr: .res 1
timerstr: .res 9
.export camx, temp
.import airfric, fric, grav, jumpforce

.segment "ZEROPAGE"
ready: .res 1
frame: .res 1
timer: .res 3
.exportzp ready
.importzp buttons, level, player_base
