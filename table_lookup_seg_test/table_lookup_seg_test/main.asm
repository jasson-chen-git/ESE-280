;***************************************************************************
;*
;* Title:			table_lookup_seg_test
;* Author:			Jason Chen
;* Version:			2
;* Last updated:	10/12/2022 12:02:00
;* Target:			AVR128DB48
;*
;* DESCRIPTION
;*	Task 2
;*	Unconditionally reads a hexadecimal digit from DIP switches
;*	and displays to the right most digit on a 4-digit 7-segment display
;*
;* VERSION HISTORY
;* 1.0 Original version
;***************************************************************************4

ldi r16, 0x88

sts PORTC_PIN0CTRL, r16
sts PORTC_PIN1CTRL, r16
sts PORTC_PIN2CTRL, r16
sts PORTC_PIN3CTRL, r16

start:
	ldi r16, 0xFF		; load r16 with all 1s
	out VPORTD_DIR, r16 ; VPORTD - all pins configured as outputs
	out VPORTA_DIR, r16 ; VPORTA - all pins configured as outputs
	ldi r16, 0x00		; load r16 with all 0s
	out VPORTC_DIR, r16 ; VPORTC - all pins configured as inputs
	cbi VPORTE_DIR, 0	; set direction for PE0 as input
	sbi VPORTE_DIR, 1	; set direction for PE1 as output
	ldi r16, 0xEF
	out VPORTA_OUT, r16
	;cbi VPORTA_OUT, 4	; set PA4 to output 0, turns rightmost digit ON

main_loop:
	in r17, VPORTC_IN	; read in switches
	rcall reverse_bits
	rcall hex_to_7seg
	out VPORTD_OUT, r18 ; output to 7-seg display
	rjmp main_loop

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
;* Parameters:	r17 - switch input
;*
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
;* Parameters: r18: hex digit to be converted
;* Returns: r18: seven segment pattern. 0 turns segment ON
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
hextable: .db $01, $4F, $12, $06, $4C, $24, $20, $0F, $00, $04, $08, $60, $31, $42, $30, $38