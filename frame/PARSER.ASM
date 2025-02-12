parseConsole	proc
		
		mov di, 82h ; start of command line args
		
		; === GET WIDTH === ;
		call skipSpaces
		call getNumber

		cmp al, 78d
		ja printError

		mov [BORDER_WIDTH], byte ptr al

		; === GET HEIGHT === ;
		call skipSpaces 
		call getNumber	

		cmp al, 22d
		ja printError

		mov [BORDER_HEIGHT], byte ptr al

		; === GET STYLE === ;
		call skipSpaces
		call getNumber

		mov [BORDER_STYLE], byte ptr al

		; === GET PERS STYLE === ;
		call skipSpaces ; go to first symbol
		xor ax, ax
		mov ax, di
		mov TEXT_POSITION, byte ptr al
		
		; ---------------------- ;
		push di
		xor cx, cx
		
		@@next:
		call skipSpaces		 ; go to next line
		call textLength	 	 ; count len(text)
		cmp  al, BORDER_WIDTH
		jae printError

		inc cl			 ; increment lines count
		
		mov ax, di		 ; position in cmd
		mov bx, 80h	
		sub ax, 128d
		cmp al, byte ptr [bx]
		jae @@end_loop

		jmp @@next
		@@end_loop:
			pop di
			mov LINE_COUNT, cl
			cmp cl, BORDER_HEIGHT
			ja printError

		ret
		        endp

wordLength	proc
		
		@@startLoop:
			cmp byte ptr [di], ' '
			je @@endLoop
			
			inc di
			
			jmp @@startLoop
		
		@@endLoop:

		ret
		    endp

textLength	proc
		
		mov ax, di
		@@next:
			cmp byte ptr [di], '$'
			je @@end_loop
			
			inc di
			cmp di, 255d
			jae printError
		
		jmp @@next
		@@end_loop:
			push di
			
			sub di, ax
			mov ax, di ; return value
			
			pop di
			
			inc di     ; go to next symbol

		ret
		    endp


getNumber	proc
		
		mov bx, di	; save start pos in bx
		call wordLength ; set di in the end of number
		
		sub di, bx
		mov cx, di
		
		mov di, bx	; set di in the start of number

		; -------------------------------------------- ;
		cmp cx, 3d	; check len of number
		jae printError
		
		cmp cx, 0d	; check len of number
		jbe PrintError
		
		xor ax, ax

		cmp cx, 2d
		jne @@addLastPart
		
		mov al, byte ptr [di] ; get first number code
		sub al, '0'	      ; get first number value from code
		mov ah, 10d	      ; mul first num to 10 and save in ah
		mul ah
		mov ah, al

		inc di		      ; go to next number
		
		@@addLastPart:
			mov al, byte ptr [di] ; get next number code
			sub al, '0'	      ; get next number value from code
			
			add al, ah	      ; add first number with second
			
			inc di		      ; go to the next number

		ret
		    endp

skipSpaces	proc

		
		@@next:
		cmp byte ptr[di], ' '

		jne @@end
			inc di
		jmp @@next

		@@end:
		
		ret
		    endp
