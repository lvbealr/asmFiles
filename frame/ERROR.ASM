; ============================================================= ;
; Describe:	Print error message on display (21H 09H)	;
; Entry:	None						;
; Exit:		None						;
; Destroy:	AH, DX						;
; ============================================================= ;

printErrorMessage:
	mov ah, 09h			; 21H 09H - Display text
	mov dx, offset ERROR_MESSAGE	; dx = &ERROR_MESSAGE
	int 21h				; SYSCALL 21H

	jmp exitProgramm		; jump to exitProgramm