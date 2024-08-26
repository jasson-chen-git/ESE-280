;***************************************************************************
;*
;* Title:			enable_pullups.asm
;* Author:			Jason Chen
;* Version:			1
;* Last updated:	10/24/2022
;* Target:			AVR128DB48
;*
;* DESCRIPTION
;*			Design Task 1:
;*			Enable internal pull up resistors in for PORTC using
;*			PORTC_PINnCTRL registers and memory reference instructions.
;*
;* VERSION HISTORY
;* 1.0 Original version
;***************************************************************************

start:
    ldi r16, 0x00
	out VPORTC_DIR, r16				; VPORTC - all pins configured as input
	ldi XH, HIGH(PORTC_PIN0CTRL)	; X points to PORTC_PIN0CTRL
	ldi XL, LOW(PORTC_PIN0CTRL)
	ldi r17, 8						; loop control variable, 8 step counter

pullups:
	ld r16, X			; load value of PORTC_PINnCTRL
	ori r16, 0x08		; enable pullups
	st X+, r16			; store results
	dec r17				; decrement lcv
	brne pullups