;***************************************************************************
;* Title:			read_DHT11.asm
;* Author:			Jason Chen
;* Version:			1
;* Last updated:	11/21/2022
;* Target:			AVR128DB48
;*
;* DESCRIPTION
;*		Design Task 2:
;*			This program sends a start signal by taking the DATA line down
;*			for 18ms and then releasing it for 20us. Then the DHT11 will 
;*			take hold of the line and send a response signal before sending
;*			data bits to the MCU.
;*
;* VERSION HISTORY
;* 1.0 Original version
;***************************************************************************

start:				; Configure I/O ports
	ldi r16, 0xFF
	out VPORTD_DIR, r16
	ldi r16, 0xF0
	out VPORTA_DIR, r16
	ldi r16, 0x00
	out VPORTC_DIR, r16
	cbi VPORTE_DIR, 0

main_loop:
	rcall send_start
	rcall wait_for_response_signal
	rcall read_DHT11
	rjmp main_loop

read_DHT11:
	in r16, VPORTB_IN
	andi r16, 0x01
	ret

wait_for_0:
	rcall read_DHT11
	cpi r16, 0x00
	brne wait_for_0
	ret

wait_for_1:
	rcall read_DHT11
	cpi r16, 0x01
	brne wait_for_1
	ret

wait_for_response_signal:
	rcall wait_for_0
	rcall delay_80us
	rcall wait_for_1
	rcall delay_80us
	ret

read_DHT11_data_bit:	; records bit in bit 0 of r16
	rcall wait_for_0
	rcall delay_20us
	rcall wait_for_1
	rcall delay_30us
	rcall read_DHT11			; record logic level of DATA line as input
	ret



;***************************************************************************
;* "send_start" - Send start signal
;* Author:			Jason Chen
;* Description:
;*		Makes DATA line 0 for 18ms then a 1 for 20us (or 40us).
;***************************************************************************

send_start:
	rcall write_0_to_DHT11
	rcall delay_18ms
	rcall write_1_to_DHT11
	rcall delay_20us
	/*rcall delay_20us*/
	ret

write_0_to_DHT11:
	cbi VPORTB_DIR, 0
	ret

write_1_to_DHT11:
	sbi VPORTB_DIR, 0
	ret

;***************************************************************************
;* "delay_18ms" "delay_50us" "delay_20us" - Delay
;* Author:			Jason Chen
;* Description:
;*		Delay 18ms : 72000 clock cycles accounting for 2 clocks from rcall
;*		Delay 50us : 200 clock cycles accounting for 2 clocks from rcall
;*		Delay 20us : 40 clock cycles accounting for 2 clocks from rcall
;***************************************************************************

delay_18ms:			; 72000 clocks total (2 from rcall)
	push r16				; 1 clock
	push r17				; 1 clock
	ldi r16, 106			; 1 clock (m)
	outer_18ms:				; (4 + N)m - 1 = 71867 clocks
		ldi r17, 225			; 1 clock (n)
		inner_18ms:				; 3n - 1 = 674 clocks (N)
			dec r17					; 1 clock
			brne inner_18ms			; 1/2 clocks
		dec r16					; 1 clock
		brne outer_18ms			; 2/1 clocks
		rcall delay_30us	; 120 clocks
	pop r17					; 2 clocks
	pop r16					; 2 clocks
	ret						; 4 clocks

delay_80us:			; 320 clocks total (2 from rcall)
	push r16				; 1 clock
	ldi r16, 103			; 1 clock (n)
	loop_80us:				; 3n - 1 = 308 clocks
		dec r16					; 1 clock
		brne loop_20us			; 2/1 clocks
	nop	nop					; 2 clock
	pop r16					; 2 clocks
	ret						; 4 clocks

delay_50us:			; 200 clocks total (2 from rcall)
	push r16				; 1 clock
	ldi r16, 63				; 1 clock (n)
	loop_50us:				; 3n - 1 = 188 clocks
		dec r16					; 1 clock
		brne loop_50us			; 2/1 clocks
	nop	nop					; 2 clock
	pop r16					; 2 clocks
	ret						; 4 clocks

delay_30us:			; 80 clocks total (2 from rcall)
	push r16				; 1 clock
	ldi r16, 34				; 1 clock (n)
	loop_30us:				; 3n - 1 = 110 clocks
		dec r16					; 1 clock
		brne loop_20us			; 2/1 clocks
	pop r16					; 2 clocks
	ret						; 4 clocks

delay_20us:			; 80 clocks total (2 from rcall)
	push r16				; 1 clock
	ldi r16, 23				; 1 clock (n)
	loop_20us:				; 3n - 1 = 68 clocks
		dec r16					; 1 clock
		brne loop_20us			; 2/1 clocks
	nop	nop					; 2 clock
	pop r16					; 2 clocks
	ret						; 4 clocks