;***************************************************************************
;*
;* Title:			display_hex_digit_at_pos
;* Author:			Jason Chen
;* Version:			2
;* Last updated:	10/13/2022 18:47:00
;* Target:			AVR128DB48
;*
;* DESCRIPTION
;*	Task 3
;*	Unconditionally reads a hexadecimal digit from DIP switches
;*	and displays to the right most digit on a 4-digit 7-segment display
;*
;* VERSION HISTORY
;* 1.0 Original version
;***************************************************************************

start:
	ldi r16, 0xFF		; load r16 with all 1s
	out VPORTD_DIR, r16 ; VPORTD - all pins configured as outputs
	out VPORTA_DIR, r16 ; VPORTA - all pins configured as outputs
	ldi r16, 0x00		; load r16 with all 0s
	out VPORTC_DIR, r16 ; VPORTC - all pins configured as inputs
	cbi VPORTE_DIR, 0	; set direction for PE0 as input
	sbi VPORTE_DIR, 1	; set direction for PE1 as output
	ldi r21, 0xFF
	mov r22, r21
	mov r23, r21
	mov r24, r21		; set r21 - r24 to all 1s, all segments are initially OFF

main_loop:
	sbi VPORTE_OUT, 1	; unclear DFF
	rcall turn_off_all
	ldi r19, 0xEF		; load r19 with 1110 1111

digit_4_blink:			; display hex at digit 4 / pos 0 ON (rightmost)
	out VPORTD_OUT, r24
	out VPORTA_OUT, r19
	rcall var_delay
	rcall turn_off_all

digit_3_blink:
	lsl r19				; r19 is now 1101 1110, digit 3 / pos 1 will turn ON
	out VPORTD_OUT, r23
	out VPORTA_OUT, r19
	rcall var_delay
	rcall turn_off_all

digit_2_blink:
	lsl r19				; r19 is now 1011 1100, digit 2 / pos 2 will turn ON
	out VPORTD_OUT, 22
	out VPORTA_OUT, r19
	rcall var_delay
	rcall turn_off_all

digit_1_blink:
	lsl r19				; digit 1 / pos 3 will turn ON (leftmost)
	out VPORTD_OUT, 21
	out VPORTA_OUT, r19
	rcall var_delay
	rcall turn_off_all

check_if_1:				; wait for the Q from the DFF
	sbis VPORTE_IN, 0
	rjmp main_loop
	cbi VPORTE_OUT, 1	; clear DFF

update_digits:
	in r17, VPORTC_IN	; read switches
	rcall reverse_bits
	mov r17, r18
	rcall hex_to_7seg
	andi r17, 0xC0		; mask for assigning digit
	cpi r17, 0xC0
	breq update_digit_1	; update digit 1 / pos 3 with new hex
	cpi r17, 0x80
	breq update_digit_2
	cpi r17, 0x40
	breq update_digit_3

update_digit_4:			; update digit 4 / pos 0 (default)
	mov r24, r18
	rjmp main_loop

update_digit_1:
	mov r21, r18
	rjmp main_loop

update_digit_2:
	mov r22, r18
	rjmp main_loop

update_digit_3:
	mov r23, r18
	rjmp main_loop

;***************************************************************************
;* 
;* "turn_off_all" - Turn OFF All Segments and Digit's Transistors
;*
;* Description:	Delays a variable time that is adjusted by need basis.
;*
;* Author:			Jason Chen
;* Version:			1
;* Last updated:	10/18/2022
;* Target:			AVR128DB48
;* Number of words:			4
;* Number of cycles:		1
;* Low registers modified:	n/a
;* High registers modified:	r16
;*
;* Parameters:	r16 - set all 1s
;*
;* Returns:		r16 - set all 1s
;*
;* Notes:
;*
;***************************************************************************

turn_off_all:
	ldi r16, 0xFF
	out VPORTD_OUT, r16	; turn all segments OFF
	out VPORTA_OUT, r16	; turn all transistors/digits OFF
	ret

;***************************************************************************
;* 
;* "var_delay" - Variable Delay
;*
;* Description:	Delays r16 * 1ms (approx.) 
;*
;* Author:			Jason Chen
;* Version:			1
;* Last updated:	10/13/2022
;* Target:			AVR128DB48
;* Number of words:			7
;* Number of cycles:		r16 * r17
;* Low registers modified:	n/a
;* High registers modified:	r16, r17
;*
;* Parameters:	r16 - outer loop counter
;*				r17 - inner loop counter
;* Returns:		r16 and r17 set to all 0s
;*
;* Notes:
;*
;***************************************************************************

var_delay:
	ldi r16, 0x01
	outer_loop:
		ldi r17, 133
	inner_loop:
		dec r17
		brne inner_loop
		dec r16
		brne outer_loop
	ret

;***************************************************************************
;* 
;* "reverse_bits" - Reverse bits
;*
;* Description:	Reverse the order of bits register 17, which reads the input
;*				switches, into register 18.
;*
;* Author:			Jason Chen
;* Version:			1
;* Last updated:	10/13/2022
;* Target:			AVR128DB48
;* Number of words:
;* Number of cycles:		8
;* Low registers modified:	n/a
;* High registers modified:	r16, r18
;*
;* Parameters:	r17 - switch input to be read and reversed
;*				r16 - 8 step counter
;* Returns:		r18 - reversed bits
;*
;* Notes:
;*
;***************************************************************************

reverse_bits:			; reverses bits from r17 into r18
	ldi r18, 0x00
	ldi r16, 0x08		; 8 step counter
	bits_loop:
		lsl r17
		ror r18
		dec r16
		cpi r16, 0x00
		brne bits_loop
	ret

;***************************************************************************
;* 
;* "hex_to_7seg" - Hexadecimal to Seven Segment Conversion
;*
;* Description: Converts a right justified hexadecimal digit to the seven
;* segment pattern required to display it. Pattern is right justified a
;* through g. Pattern uses 0s to turn segments on ON.
;*
;* Author:			Ken Short
;* Version:			0.1						
;* Last updated:	10/03/2022
;* Target:			AVR128DB48
;* Number of words:			1
;* Number of cycles:		1
;* Low registers modified:	n/a
;* High registers modified:	r16, r18
;*
;* Parameters:	r18 - hex digit to be converted
;* Returns:		r18 - seven segment pattern. 0 turns segment ON
;*
;* Notes: 
;*
;***************************************************************************

hex_to_7seg:
	ldi ZH, HIGH(hextable * 2)	; set Z to point to start of table
	ldi ZL, LOW(hextable * 2)
	ldi r16, $00				; add offset to Z pointer
	andi r18, 0x0F				; mask for low nibble
	add ZL, r18
	adc ZH, r16
	lpm r18, Z					; load byte from table pointed to by Z
	ret

	; Table of segment values to display digits 0 - F
	; !!! seven values must be added
hextable: .db $01, $4F, $12, $06, $4C, $24, $20, $0F, $00, $04, $08, $60, $31, $42, $30, $38	; dp a b c d e f g
;hextable: .db $40, $79, $24, $30, $19, $12, $02, $78, $00, $10, $08, $03, $46, $21, $06, $0E	; dp g f e d c b a 