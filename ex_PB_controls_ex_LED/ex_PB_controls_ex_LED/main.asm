;PA7 reads external switch and PD7 drives external LED
start:
	sbi VPORTD_DIR, 7	;set direction of PD7 as output
	sbi VPORTD_OUT, 7	;set output value to 1
	cbi VPORTA_DIR, 7	;set direction of PA7 to input

;Read switch position to control LED
loop:
	sbis VPORTA_IN, 7	;skip next isntruction if PA7 is 1
	cbi VPORTD_OUT, 7	;clear output PD7 to 0, turn LED ON
	sbic VPORTA_IN, 7	;skip next instruciton if PA7 is 0
	sbi VPORTD_OUT, 7	;set output PD7 to 1, turn LED OFF
    rjmp loop			;jump back to loop
