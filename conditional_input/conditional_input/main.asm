;
; conditional_input.asm
;
; Created:	9/26/2022 11:28:26 PM
; Author:	Jason Chen
; ID:		112515450
;
; Description:	PC7 - PC0 reads switch inputs when PE0 is 1, which reads from the
;				output from the DFF, and displays to the bargraph LED. PE1 clears
;				the DFF. 

start:
    ldi r16, 0xFF		; load r16 with all 1s
	out VPORTD_DIR, r16	; VPORTD - all pins configured as outputs
	ldi r16, 0x00		; load r16 with all 0s
	out VPORTC_DIR, r16	; VPORTC - all pins configured as inputs
	cbi VPORTE_DIR, 0	; set direction for PE0 as input
	sbi VPORTE_DIR, 1	; set direction for PE1 as output
	cbi VPORTE_DIR, 2	; set direction for PE2 as input

again:
	sbi VPORTE_OUT, 1	; set PE1 to 1 to "unclear" the DFF
	ldi r16, 100		; set r18 for ~10 ms delay for debouncing 
	sbic VPORTE_IN, 0	; skip if PE0 is 0
	rjmp again

; Wait for the pushbutton to send clock signal to DFF and output to PE00
wait_for_push:
	sbis VPORTE_IN, 0	; skip if PE0 is 1
	rjmp wait_for_push

output:
	in r16, VPORTC_IN	; load switch positions to r16
	com r16				; complement r16 due to pull-up configuration
	out VPORTD_OUT, r16	; output r16 to bargraph LEDs
	rcall var_delay

wait_for_release:
	sbic VPORTE_IN, 2	; skip if PE2 is 0
	rjmp wait_for_release
	rcall var_delay		; to eliminate bounce after release
	sbic VPORTE_IN, 2	; skip if PE2 is 0
	rjmp wait_for_release	; check for stable signal
	cbi VPORTE_OUT, 1	; clear the DFF
	rjmp again

; Delay r18 * 0.100475 ms
var_delay:
	outer_loop:
		ldi r17, 133
	inner_loop:
		dec r17
		brne inner_loop
		dec r18
		brne outer_loop
	ret					; return to caller

