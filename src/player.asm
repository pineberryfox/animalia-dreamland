.include "constants.inc"

	;; inputs:
	;; * X: player spawn x coord
	;; * Y: player spawn y coord
.export init_player
.proc init_player
	STX player_x
	STY player_y
	LDA #$08
	STA player_base
	LDA #$01
	STA player_tile
	STA player_dir
	LDA #$00
	STA player_state
	STA player_vx
	STA player_vx + 1
	STA player_vy
	STA player_vy + 1
	STA player_subx
	STA player_suby
	STA jbuff
	STA coyote
	LDA maxt
	STA timer
	RTS
.endproc

.import collide
.export draw_player
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

placed: ;; remember the camera is offset; account for that here
	LDA player_y
	STA $0200
	STA $0204
	CLC
	ADC #$08
	STA $0208
	STA $020C
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

.export update_player
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

	;; start vertical movement
	CLC
	LDA player_vy
	ADC #$20
	STA player_vy
	LDA player_vy + 1
	ADC #$00
	STA player_vy + 1
	CMP #$10
	BCC next
	LDA #$FF
	STA player_vy
	LDA #$0F
	STA player_vy + 1
next:	CLC
	LDA player_suby
	ADC player_vy
	STA player_suby
	LDA player_y
	ADC player_vy + 1
	STA player_y

	;; check y-collisions
	BIT player_vy + 1
	BMI collU
	;; going down
	LDA player_x
	SEC
	SBC #$08
	TAX
	LDA player_y
	CLC
	ADC #$08
	TAY
	JSR collide
	BNE dcolld
	LDA player_x
	CLC
	ADC #$07
	TAX
	LDA player_y
	CLC
	ADC #$08
	TAY
	JSR collide
	BNE dcolld
	JMP endCollV
dcolld: LDA player_y
	AND #$F0
	CLC
	ADC #$08
	STA player_y
	LDA #$00
	STA player_suby
	STA player_vy
	STA player_vy + 1
	JMP endCollV
collU:  ;; Going up
	LDA player_x
	SEC
	SBC #$08
	TAX
	LDA player_y
	SEC
	SBC #$06
	TAY
	JSR collide
	BNE ucolld
	LDA player_x
	CLC
	ADC #$07
	TAX
	LDA player_y
	SEC
	SBC #$06
	TAY
	JSR collide
	BNE ucolld
	JMP endCollV
ucolld: LDA player_y
	CLC
	ADC #$0F
	AND #$F0
	STA player_y
	LDA #$00
	STA player_suby
	STA player_vy
	STA player_vy + 1
endCollV:

	;; start horizontal movement
	LDA #BTN_LEFT
	BIT buttons
	BEQ noleft
	LDA #$01
	STA player_state
	LDA #$00
	STA player_dir

	SEC
	LDA player_vx
	BIT player_vx + 1
	BMI lsubxs
	SBC fric
	STA player_vx
	JMP lefted
lsubxs: SBC #XSPEED
	STA player_vx
lefted: LDA player_vx + 1
	SBC #$00
	STA player_vx + 1
	CMP #$FD
	BNE lset
	LDA #$00
	STA player_vx
	LDA #$FE
	STA player_vx + 1
lset:
	JMP endhrz
noleft: LDA #BTN_RIGHT
	BIT buttons
	BEQ norght
	LDA #$01
	STA player_state
	STA player_dir

	CLC
	LDA player_vx
	BIT player_vx + 1
	BPL raddxs
	ADC fric
	STA player_vx
	JMP rghted
raddxs: ADC #XSPEED
	STA player_vx
rghted: LDA player_vx + 1
	ADC #$00
	STA player_vx + 1
	CMP #$02
	BNE rset
	LDA #$00
	STA player_vx
rset:
	JMP endhrz
norght:
	LDA #$00
	STA player_state
	STA player_tile
	LDA fric
	LSR A
	STA temp
	BIT player_vx + 1
	BMI negvx
	SEC
	LDA player_vx
	SBC temp
	STA player_vx
	LDA player_vx + 1
	SBC #$00
	STA player_vx + 1
	BIT player_vx + 1
	BPL endslow
	JMP vxToZero
negvx:  CLC
	LDA player_vx
	ADC temp
	STA player_vx
	LDA player_vx + 1
	ADC #$00
	STA player_vx + 1
	BIT player_vx + 1
	BMI endslow
vxToZero:
	LDA #$00
	STA player_vx
	STA player_vx + 1
endslow:

endhrz: CLC
	LDA player_subx
	ADC player_vx
	STA player_subx
	LDA player_x
	ADC player_vx + 1
	STA player_x
	LDA player_x
	CMP #$F8
	BCC noredge
	LDA #$F8
	STA player_x
	JMP vxTo0
noredge:CMP #$08
	BCS noxshunt
	LDA #$08
	STA player_x
vxTo0:	LDA #$00
	STA player_vx
	STA player_vx + 1
noxshunt:

	;; check x-collisions
	BIT player_vx + 1
	BMI collL
	;; going right
	LDA player_x
	CLC
	ADC #$08
	TAX
	LDA player_y
	CLC
	ADC #$07
	TAY
	JSR collide
	BNE rcolld
	LDA player_x
	CLC
	ADC #$08
	TAX
	LDA player_y
	SEC
	SBC #$04
	TAY
	JSR collide
	BNE rcolld
	JMP endCollH
rcolld: LDA player_x
	AND #$F8
	STA player_x
	LDA #$00
	STA player_subx
	STA player_vx
	STA player_vx + 1
	JMP endCollH
collL:  ;; Going left
	LDA player_x
	SEC
	SBC #$09
	TAX
	LDA player_y
	CLC
	ADC #$07
	TAY
	JSR collide
	BNE lcolld
	LDA player_x
	SEC
	SBC #$09
	TAX
	LDA player_y
	SEC
	SBC #$04
	TAY
	JSR collide
	BNE lcolld
	JMP endCollH
lcolld: LDA player_x
	CLC
	ADC #$07
	AND #$F8
	STA player_x
	LDA #$00
	STA player_subx
	STA player_vx
	STA player_vx + 1
endCollH:

exit_subr:
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	RTS
.endproc

.segment "RODATA"
.export maxt
maxt:
.byte $04

.segment "BSS"
coyote: .res 1
jbuff: .res 1
player_subx: .res 1
player_suby: .res 1
player_vx: .res 2
player_vy: .res 2
fric: .res 1
.export fric

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_tile: .res 1
player_base: .res 1
player_dir: .res 1
player_state: .res 1
temp: .res 1
timer: .res 1
.importzp buttons