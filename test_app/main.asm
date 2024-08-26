;
; test_app.asm
;
; Created: 11/9/2022 10:29:08 PM
; Author : Jason
;

start:
; Configure I/O ports
	ldi r16, 0xFF
	out VPORTD_DIR, r16			; VPORTD - all pins configured as output
	ldi r16, 0xF0
	out VPORTA_DIR, r16			; PA4 - PA7 configured as output (gate of pnp transistor)
	ldi r16, 0x00
	out VPORTC_DIR, r16			; VPORTC - all pins configured as input
	cbi VPORTE_DIR, 0			; PE0 configured as input

; Enable pullup resistors and inven for PORTC
	ldi r16, 0x88				; inven = bit 7, pullup_enable = bit 3 (1000 1000)
	sts PORTC_PINCONFIG, r16	; write PINCONFIG
	ldi r17, 0xFF				; specify which PINnCTRL registers to update (all)
	sts PORTC_PINCTRLUPD, r17	; update specified PINnCTRL registers simultaneously

main_loop:
	ldi r16, 0x00
	out VPORTA_OUT, r16
	out VPORTD_OUT, r16
	rjmp main_loop