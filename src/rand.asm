.segment "CODE"
.export rand
.proc rand
	INC entropy
	LDA entropy + 1
	EOR entropy + 3
	EOR entropy
	STA entropy + 1
	LDA entropy + 2
	CLC
	ADC entropy + 1
	STA entropy + 2
	LSR A
	CLC
	ADC entropy + 3
	EOR entropy + 1
	STA entropy + 3
	RTS
.endproc

	;; three bytes, in A, X, and Y
.export srand
.proc srand
	STA entropy + 1
	STX entropy + 2
	STY entropy + 3
	LDA #$00
	STA entropy
	JSR rand
	RTS
.endproc

.segment "ZEROPAGE"
entropy: .res 4
