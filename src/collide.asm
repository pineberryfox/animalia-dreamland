.include "constants.inc"

.segment "CODE"

	;; inputs:
	;; * X: x-coordinate to check
	;; * Y: y-coordinate to check
	;; neither is necessarily preserved
	;; output: $00 (no collision) or $FF (collision) in A
	;; (also in Z flag)
.export collide
.proc collide
	LDA player_overy
	BPL real
	LDY #$00
real:
	;; y /= 16; y *= 2;
	TYA
	LSR A
	LSR A
	LSR A
	AND #$FE
	TAY
	;; x /= 16;
	;; if (x >= 8) ++y;
	;; x &= 7;
	TXA
	LSR A
	LSR A
	LSR A
	LSR A
	CMP #$08
	BMI noinc
	INY
noinc:	AND #$07
	TAX

	LDA (level),Y
	;; set the appropriate bit
	LDA #$00
	SEC
alp:	ROR A
	DEX
	BPL alp
	;; get it
	AND (level),Y
	BEQ end
	LDA #$FF
end:	RTS
.endproc
.importzp level
.importzp player_overy
