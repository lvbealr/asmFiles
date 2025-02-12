printError:	mov ah, 09h
		mov dx, offset ERROR_MESSAGE
		int 21h

		jmp exitProgram