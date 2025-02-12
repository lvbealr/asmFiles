checkInput	proc
		
		mov ah, 01h
		int 21h
		cmp al, 'q'

		je exitProgramm

		cmp al, 50h
		je incCurrentLine

		cmp al, 48h
		je decCurrentLine

		ret

		incCurrentLine:
			mov al, CURRENT_LINE

			cmp al, BORDER_HEIGHT + 1
			je @@return
			
			inc al

			mov CURRENT_LINE, al

			ret

		decCurrentLine:
			mov al, CURRENT_LINE
			
			cmp al, 2d
			je @@return
			
			dec al
			
			mov CURRENT_LINE, al

			@@return:
				ret

		endp