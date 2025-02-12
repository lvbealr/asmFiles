parseConsole	proc	

		mov di, 82h 
		
		call skipSpaces
		call parseNumber

		cmp al, 78d

		ja printErrorMessage

		mov [BORDER_WIDTH], byte ptr al
		
		call skipSpaces
		call parseNumber

		cmp al, 22d

		ja printErrorMessage

		mov [BORDER_HEIGHT], byte ptr al
		
		call skipSpaces
		call parseNumber

		mov [BORDER_MODE], byte ptr al

		call skipSpaces
		
		xor ax, ax
		mov ax, di

		mov TEXT_POSITION, byte ptr al
		
		push di
		xor cx, cx

		@@next:
		call skipSpaces
		call textLength
		
		cmp al, BORDER_WIDTH
		jae printErrorMessage

		inc cl

		mov ax, di
		mov bx, 80h
		
		sub ax, 128d
	
		cmp al, byte ptr [bx]
		jae @@endLoop

		jmp @@next

		@@endLoop:
		pop di

		mov LINE_COUNT, cl
		
		cmp cl, BORDER_HEIGHT
		ja printErrorMessage

		ret
		endp

wordLength	proc

		@@startCounterLoop:
		cmp byte ptr [di], ' '
		je @@endCounterLoop

		inc di
		
		jmp @@startCounterLoop

		@@endCounterLoop:

		ret
		endp

textLength	proc

		mov ax, di
		
		@@next:
		cmp byte ptr [di], '$'
		je @@endLoop

		inc di
	
		cmp di, 255d
		jae printErrorMessage

		jmp @@next
		@@endLoop:

		push di
		
		sub di, ax
		mov ax, di

		pop di
		inc di

		ret
		endp

parseNumber	proc
		
		mov bx, di

		call wordLength

		sub di, bx
		mov cx, di
		mov di, bx

		cmp cx, 3d
		jae printErrorMessage

		cmp cx, 0d
		je  printErrorMessage

		xor ax, ax

		cmp cx, 2d
		jne @@addLastPart

		mov al, byte ptr [di]
		sub al, '0'
		
		mov ah, 10d
		mul ah
		mov ah, al

		inc di
		
		@@addLastPart:
		mov al, byte ptr [di]
		sub al, '0'
		add al, ah
		
		inc di
		
		ret
		endp

skipSpaces	proc

		@@next:
		cmp byte ptr [di], ' '
		jne @@end

		inc di

		jmp @@next
		@@end:

		ret
		endp