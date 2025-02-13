; ============================================= ;
; Describe:	Tracking if user is keystroking	;
; Entry:	None				;
; Exit:		None				;
; Destroy:	AX				;
; ============================================= ;

checkInput	proc
		
		mov ah, 01h		; 21H 01H - Keyboard Input [AL]
		int 21h			; SYSCALL 21H
		cmp al, 'q'		; if AL == 'q'

		je exitProgramm		; exit

		cmp al, 50h		; if AL == 50h		||
		je incCurrentLine	; move to next line	\/

		cmp al, 48h		; if AL == 48h		/\
		je decCurrentLine	; move to previous line ||

		ret

		incCurrentLine:
			mov al, CURRENT_LINE

			cmp al, BORDER_HEIGHT
			je @@return
			
			inc al

			mov CURRENT_LINE, al

			ret

		decCurrentLine:
			mov al, CURRENT_LINE
			
			cmp al, 1d
			je @@return
			
			dec al
			
			mov CURRENT_LINE, al

			@@return:
				ret

		endp