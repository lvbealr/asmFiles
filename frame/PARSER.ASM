; =====================================================================	;
; Describe:	Parsing parameters from command-line (PSP x0082h)	;
; Entry:	None							;
; Exit:		None							;
; Destroy:	AX, BX, DI						;
; =====================================================================	;

parseConsole	proc	

		mov di, 82h		; PSP address x0082h - cmd starts
		
		; ############################################# ;
		; ______________ GET BORDER WIDTH _____________ ;
		; ############################################# ;

		call skipSpaces		; skip spaces
		call parseNumber	; parse number from cmd
					; put WIDTH to AL

		cmp al, 78d		; if AL > 78
					; (check if width is valid)
		ja printErrorMessage	; print error message

		mov [BORDER_WIDTH], byte ptr al ; *BORDER_WIDTH = AL
		
		; ############################################# ;
		; ______________ GET BORDER HEIGHT ____________ ;
		; ############################################# ;

		call skipSpaces		; skip spaces
		call parseNumber	; parse number from cmd
					; put HEIGHT to AL

		cmp al, 22d		; if AL > 22
					; (check if height is valid)
		ja printErrorMessage	; print error message

		mov [BORDER_HEIGHT], byte ptr al ; *BORDER_HEIGHT = AL
		
		; ############################################# ;
		; ________________ GET COLORS _________________ ;
		; ############################################# ;

		call skipSpaces
		call parseNumber

		mov [WBACK_BFRONT], byte ptr al
		
		call skipSpaces
		call parseNumber

		mov [BBACK_WFRONT], byte ptr al
		
		; ---------------------------- ;
			
		; ############################################# ;
		; _______________ GET STYLE CODE ______________ ;
		; ############################################# ;

		call skipSpaces		; skip spaces
		call parseNumber	; parse number from cmd
					; put CODE to AL

		mov [BORDER_MODE], byte ptr al ; *BORDER_MODE = AL  
		
		; ############################################# ;
		; __________________ GET STYLE ________________ ;
		; ############################################# ;

		cmp [BORDER_MODE], 0
		jne @@break

		@@getStyle:
			call skipSpaces		; skip spaces
			push cx si di
			mov cx, 9
			lea si, [di]
			lea di, USER_BORDER
			push ds es
			mov ax, cs
			mov es, ax
			rep movsb
			pop es ds
			pop di si cx
			add di, 9

		@@break:

		; ############################################# ;
		; _________________ GET MESSAGE _______________ ;
		; ############################################# ;

		call skipSpaces		; skip spaces, go to first symbol
		
		xor ax, ax		; AX = 0
		mov ax, di		; AX = DI

		mov TEXT_POSITION, byte ptr al ; TEXT_POSITION = AL
		
		push di			; save DI
		xor cx, cx		; CX = 0

		@@next:			; go to next line
		call skipSpaces		; skip spaces
		call textLength		; get string length
					; put LENGTH to AL
		
		cmp al, BORDER_WIDTH	; if AL >= BORDER_WIDTH
					; (check if msg length is valid)
		jae printErrorMessage	; print error message

		inc cl			; increment count of lines

		mov ax, di		; AX = DX  ; check pos in cmd 
					; (now DI at start of message)
		mov bx, 80h		; BX = 80h
		
		sub ax, 80h		; AX -= 128 (cmd psp offset: 81-FF, size: 127b)
	
		cmp al, byte ptr [bx]	; if AL >= *BX
					; (check pos in PSP)
		jae @@endLoop		; break

		jmp @@next		; get next argument (message also mb)

		@@endLoop:		
		pop di			; restore DI

		mov LINE_COUNT, cl	; LINE_COUNT = CL
		
		cmp cl, BORDER_HEIGHT	; if CL > BORDER_HEIGHT
					; (check lines number)
		ja printErrorMessage	; print error message

		ret
		endp

; ===================================================================== ;
; Describe:	Calculate length of 'non-empty word' in command-line	;
; Entry:	(assumed) DI - start position				;
; Exit:		(assumed) DI - end   position (first ' ' after word)	;
; Destroy:	None							;
; ===================================================================== ;

wordLength	proc

		@@startCounterLoop:	; do while *di != ' '
		cmp byte ptr [di], ' '	
		je @@endCounterLoop

		inc di			; increment pos in cmd

		jmp @@startCounterLoop	; repeat

		@@endCounterLoop:	; return

		ret
		endp
; ============================================================= ;
; Describe: 	Calculates length of message in command-line	;
; Entry:	(assumed) DI - start position			;
; Exit:		DI - end of message, AX - count of symbols	;
; Destroy:	None						;
; ============================================================= ;

textLength	proc

		mov ax, di		; AX = DI
		
		@@next:			; do while *di != '$'
		cmp byte ptr [di], '$'
		je @@endLoop

		inc di			; increment pos in cmd
	
		cmp di, 255d		; if DI >= 255
		jae printErrorMessage	; check if end of PSP isn't reached

		jmp @@next		; repeat

		@@endLoop:

		push di			; save DI
		
		sub di, ax		; DI -= AX (end pos - start pos + 1)
		mov ax, di		; AX = DI  

		pop di			; restore DI
		inc di			; DI++ (go to next symbol after msg)

		ret
		endp

; ============================================= ;
; Describe:	Get decimal number from a cmd	;
; Entry:	(assumed) DI - start position	;
; Exit:		AL - the number			;
; Destroy:	CX, BX				;
; ============================================= ;

parseNumber	proc
		
		mov bx, di		; BX = DI

		call wordLength		; put END POSITION to DI

		sub di, bx		; DI -= BX (end pos - start pos + 1)
		mov cx, di		; CX = DI (CX - count of digits)
		mov di, bx		; DI = BX

		cmp cx, 3d		; if CX >= 3
					; (check count of digits)
		jae printErrorMessage	; print error message

		cmp cx, 0d		; if CX == 0
					; (check count of digits)
		je  printErrorMessage	; print error message

		xor ax, ax		; AX = 0

		cmp cx, 2d		; if CX != 2
					; (check count of digits)
		jne @@addLastPart	; get last part of number

		mov al, byte ptr [di]	; AL = *DI
		sub al, '0'		; AL -= '0' (AL = digit value like 0?)
		
		mov ah, 10d		; AX = 0A0x
		mul ah			; AX = AL * AH = 0? * 0A
		mov ah, al		; AH = AL
					; now AX = [NUMBER] [NUMBER] (hex)
					; 	   ^^^^^^^^ ^^^^^^^^
					;             AH       AL

		inc di			; increment pos in cmd
		
		@@addLastPart:		
		mov al, byte ptr [di]	; AL = *DI
		sub al, '0'		; AL = digit value like 0?
		add al, ah		; AL += AH
		
		inc di			; increment pos in cmd
		
		ret
		endp

; ===================================================================== ;
; Describe: 	Skip spaces in command-line				;
; Entry:	(assumed) DI - start position (whitespace symbol)	;
; Exit:		(assumed) DI - end   position (non-whitespace symbol)	;
; Destroy:	None							;
; ===================================================================== ;

skipSpaces	proc

		@@next:			; check if next symbol
					; is non-whitespace
		cmp byte ptr [di], ' '	; if *di != ' '
		jne @@end		; break

		inc di			; increment pos in cmd

		jmp @@next		; repeat

		@@end:

		ret
		endp