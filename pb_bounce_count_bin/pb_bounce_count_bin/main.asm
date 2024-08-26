;
; pb_bounce_count_bin.asm
;
; Created:	9/26/2022 2:34:36 PM
; Author:	Jason Chen
; ID:		112515450
;
; Description:	Count the number of negative edges. The counter is reset at startup
;				and whenever the counter reaches 0xFF. Can be done by decrementing
;				and outputting r16 instead of complementing.

start:
	ldi r16, 0xFF		; load r16 with all 1s
	out VPORTD_DIR, r16	; VPORTD - all pins configured as outputs
	cbi VPORTE_DIR, 0	; set direction for PE0 as input

;	1 -> 0 transition requires the switch to first be released
main_loop:
	cpi r16, 0xFF		; check if counter reached 255	
	breq clear_count	; branch if counter is reached
	sbis VPORTE_IN, 0	; skip if PE0 is 1, switch is open
	rjmp main_loop		; loop until PE0 is 1

wait_for_zero:
	sbic VPORTE_IN, 0	; skip if PE0 is 0, switch is closed
	rjmp wait_for_zero	; loop and wait for transition 1 -> 0
	 
inc_count:				
	inc r16				; increment r16 by 1
	rjmp output			; jump to output

clear_count:
	ldi r16, 0x00		; clear r16 to all 0s

output:	
	mov r17, r16		; copy r16 into r17
	com r17				; complement r17 due to bargraph LED configuration
	out VPORTD_OUT, r17	; output to LEDs.
	rjmp main_loop