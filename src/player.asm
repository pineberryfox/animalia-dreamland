.include "constants.inc"

.importzp cdust, dustd, dustx, dusty, dustv

.segment "CODE"
	;; inputs:
	;; * X: player spawn x coord
	;; * Y: player spawn y coord
.export init_player
.proc init_player
	STX player_x
	STY player_y
	LDA #$01
	STA player_tile
	STA player_dir
	LDA #$00
	STA cdust
	STA player_state
	STA player_vx
	STA player_vx + 1
	STA player_vy
	STA player_vy + 1
	STA player_subx
	STA player_suby
	STA player_overy
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

	LDA player_base
	AND #$40
	LSR A
	LSR A
	LSR A
	ORA player_dir ; palette 0 or 1, no flippage
	EOR #$01
	CLC
	ROR A
	ROR A
	ROR A
	STA PLAYER_OAM + $02
	STA PLAYER_OAM + $06
	STA PLAYER_OAM + $0A
	STA PLAYER_OAM + $0E
	AND #$40
	BNE leftface
	LDA player_tile
	CLC
	ADC player_base
	STA PLAYER_OAM + $01
	CLC
	ADC #$01
	STA PLAYER_OAM + $05
	CLC
	ADC #$0F
	STA PLAYER_OAM + $09
	CLC
	ADC #$01
	STA PLAYER_OAM + $0D
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
	STA PLAYER_OAM + $05
	CLC
	ADC #$01
	STA PLAYER_OAM + $01
	CLC
	ADC #$0F
	STA PLAYER_OAM + $0D
	CLC
	ADC #$01
	STA PLAYER_OAM + $09

placed: ;; remember the camera is offset; account for that here
	LDA player_y
	ORA player_overy
	STA PLAYER_OAM + $00
	STA PLAYER_OAM + $04
	CLC
	LDA player_y
	ADC #$08
	ORA player_overy
	STA PLAYER_OAM + $08
	STA PLAYER_OAM + $0C
	LDA player_x
	STA PLAYER_OAM + $07
	STA PLAYER_OAM + $0F
	SEC
	SBC #$08
	STA PLAYER_OAM + $03
	STA PLAYER_OAM + $0B

	; restore registers
	PLA
	PLP
	RTS
.endproc

.importzp sfx_to_play
.importzp sfx_playing
.export update_player
.proc update_player
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA

	DEC dustcd
	BPL nodcd
	INC dustcd
nodcd:	DEC jbuff
	BPL norj
	INC jbuff
norj:	DEC coyote
	BPL norc
	INC coyote
norc:

	LDA player_state
	CMP #$02
	BNE state_not_jump
	BIT player_vy + 1
	BPL state_falling
	LDA #$02
	STA player_tile
	JMP end_update_frame
state_falling:
	LDA #$06
	STA player_tile
	JMP end_update_frame
state_not_jump:
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

	LDA prevbuttons
	EOR #$FF
	AND #(BTN_A | BTN_B)
	BIT buttons
	BEQ nojbutton
	LDA #$04
	STA jbuff ; buffer a jump for a few frames
nojbutton:


	LDA #$02
	STA player_state ; jumping if nothing overrides

	;; start vertical movement
	LDA #$0F
	STA vterm
	LDA #(BTN_A | BTN_B)
	BIT buttons
	BEQ nojhold
	LDA player_base
	CMP #$10
	BCC only1g
	LDA #$01
	STA vterm
	JMP only1g
nojhold:CLC
	LDA player_vy
	ADC grav
	STA player_vy
	LDA player_vy + 1
	ADC #$00
	STA player_vy + 1
	CLC
	LDA player_vy
	ADC grav
	STA player_vy
	LDA player_vy + 1
	ADC #$00
	STA player_vy + 1
only1g: CLC
	LDA player_vy
	ADC grav
	STA player_vy
	LDA player_vy + 1
	ADC #$00
	STA player_vy + 1

	;; jumping?
	LDY player_base
	LDA jbuff
	BEQ nojump
	LDA coyote
	BNE jumping
	CPY #$10
	BCC nojump ; don't jump if a hamster
	BIT player_vy + 1
	BMI nojump ; don't jump if a bird and going up
jumping:
	LDA coyote
	BNE hamj
	CPY #$10
	BCS birdj
hamj:   LDA jumpforce
	STA player_vy
	LDA jumpforce + 1
	STA player_vy + 1
	JMP endj
birdj:  LDA jumpforce
	CLC
	ADC player_vy
	STA player_vy
	LDA jumpforce + 1
	ADC player_vy + 1
	STA player_vy + 1
endj:   LDA sfx_playing
	BNE nojumpsfx
	LDA #$03
	LDX coyote
	BEQ play
	AND #$01
play:	STA sfx_to_play
nojumpsfx:
	LDA #$00
	STA jbuff
	STA coyote
nojump:


	;; cap out at terminal velocity
	LDA player_vy + 1
	CMP vterm
	BMI next
	LDA #$00
	STA player_vy
	LDA vterm
	STA player_vy + 1
	LDA vterm
	CMP #$04
	BCS next
	LDA #$04
	STA player_tile
next:	CLC
	LDA player_suby
	ADC player_vy
	STA player_suby
	LDA player_y
	ADC player_vy + 1
	STA player_y
	LDA player_vy + 1
	BMI vyup
	LDA player_overy
	ADC #$00
	JMP vydone
vyup:	LDA player_overy
	ADC #$FF
vydone: STA player_overy

	LDA player_base
	CMP #$10
	BCC chkycoll
	LDA player_overy
	BPL chkycoll
	LDA player_y
	CMP #$08
	BCC chkycoll
	LDA #$08
	STA player_y
	LDA #$00
	STA player_suby
	STA player_overy
	STA player_vy
	STA player_vy + 1
chkycoll:
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
	SEC
	SBC #$08
	AND #$F0
	CLC
	ADC #$08
	STA player_y
	LDA player_vy + 1
	CMP #$0E
	BMI nodust
	LDA player_x
	LDY #$00
	JSR mkdust
nodust:	LDA #$00
	STA player_suby
	STA player_vy
	STA player_vy + 1
	LDA #$01
	STA player_state
	LDA #$06
	STA coyote ; ground happened, give coyote time
	JMP endCollV
collU:  ;; Going up
	LDA player_x
	SEC
	SBC #$08
	TAX
	LDY player_y
	JSR collide
	BNE ucolld
	LDA player_x
	CLC
	ADC #$07
	TAX
	LDY player_y
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

	;; if not grounded, use air friction
	LDA fric
	LDX coyote
	BNE setef
	LDA airfric
setef:  STA efric

	;; start horizontal movement
	LDA #BTN_LEFT
	BIT buttons
	BEQ noleft
	LDA #$00
	STA player_dir

	SEC
	LDA player_vx
	BIT player_vx + 1
	BMI lsubxs
	SBC efric
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
	;; maybe dust
	LDA dustcd
	BNE noldust
	LDA coyote
	BEQ noldust
	LDA player_vx + 1
	CMP #$01
	BMI noldust
	LDA player_x
	CLC
	ADC #$0C
	BCC doldust
	LDA #$FC
doldust:
	LDY #$10
	JSR mkdust
	LDA #$02
	STA dustcd
noldust:

	JMP endhrz
noleft: LDA #BTN_RIGHT
	BIT buttons
	BEQ norght
	LDA #$01
	STA player_dir

	CLC
	LDA player_vx
	BIT player_vx + 1
	BPL raddxs
	ADC efric
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
	;; maybe dust
	LDA dustcd
	BNE nordust
	LDA coyote
	BEQ nordust
	LDA player_vx + 1
	CMP #$FF
	BPL nordust
	LDA player_x
	SEC
	SBC #$10
	BCS dordust
	LDA #$00
dordust:
	CLC
	ADC #$04
	LDY #$20
	JSR mkdust
	LDA #$02
	STA dustcd
nordust:

	JMP endhrz
norght:
	LDA player_state
	CMP #$02
	BEQ nongnd
	LDA #$00
	STA player_state
	STA player_tile
nongnd: LDA efric
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
	STA player_subx
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
	LDY player_y
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
	LDY player_y
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


	;; A is xcoord, it is overwritten, other regs are unchanged
.proc mkdust
	STX temp
	LDX cdust
	STA dustx,X
	TYA
	STA dustd,X
	LDA player_y
	STA dusty,X
	LDA #MAX_DUST
	STA dustv,X
	INX
	TXA
	AND #$0F
	STA cdust
	LDA sfx_playing
	BNE end
	LDA #$03
	STA sfx_to_play
end:	LDX temp
	RTS
.endproc


.segment "RODATA"
.export maxt
maxt:
.byte $04

.segment "ZEROPAGE"
coyote: .res 1
jbuff: .res 1
vterm: .res 1
player_subx: .res 1
player_suby: .res 1
player_vx: .res 2
player_vy: .res 2
jumpforce: .res 2
fric: .res 1
airfric: .res 1
efric: .res 1
grav: .res 1
.exportzp airfric, fric, grav, jumpforce
.exportzp player_vx, player_vy
.importzp prevbuttons

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_tile: .res 1
player_base: .res 1
player_dir: .res 1
player_state: .res 1
player_overy: .res 1
temp: .res 1
timer: .res 1
dustcd: .res 1
.importzp buttons
.exportzp player_base, player_dir, player_tile
.exportzp player_x, player_y, player_overy
