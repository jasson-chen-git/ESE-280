;
; intr_driven_bit_toggle.asm
;
; Created: 
; Author : kshort
;


.equ PERIOD_EXAMPLE_VALUE = 390 ; Put correct number in for 40.0Hz

reset:
	jmp start

.org TCA0_OVF_vect
	jmp toggle_pin_ISR

start:
	;configure ports
    sbi VPORTE_DIR, 1	;make PE1 and output

	;configure TCA0
	ldi r16, TCA_SINGLE_WGMODE_NORMAL_gc	;WGMODE normal
	sts TCA0_SINGLE_CTRLB, r16

	ldi r16, TCA_SINGLE_OVF_bm		;enable overflow interrupt
	sts TCA0_SINGLE_INTCTRL, r16

	;load period low byte then high byte
	ldi r16, LOW(PERIOD_EXAMPLE_VALUE)		;set the period
	sts TCA0_SINGLE_PER, r16
	ldi r16, HIGH(PERIOD_EXAMPLE_VALUE)
	sts TCA0_SINGLE_PER + 1, r16

	;set clock and start timer
	ldi r16, TCA_SINGLE_CLKSEL_DIV256_gc | TCA_SINGLE_ENABLE_bm
	sts TCA0_SINGLE_CTRLA, r16

	sei			;enable global interrupts

main_loop:
	nop			;no tasks performed by loop
	rjmp main_loop


toggle_pin_ISR:
	push r16			;save register
	in r16, CPU_SREG
	push r16
	push r17

	ldi r17, 0b00000010	;toggle PE1
	in r16, VPORTE_OUT
	eor r16, r17
	out VPORTE_OUT, r16

	ldi r16, TCA_SINGLE_OVF_bm	;clear OVF flag
	sts TCA0_SINGLE_INTFLAGS, r16

	pop r17				;restore registers
	pop r16
	out CPU_SREG, r16
	pop r16

	reti