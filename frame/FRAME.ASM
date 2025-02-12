.model tiny
.386
.code
org 100h
locals @@

WBCK_BFRONT equ 70h
BBCK_WFRONT equ 07h 

; ////////////////////////////////////////////////// ;

Start:	jmp main
		
main	proc

		mov bx, 0b800h    ; VIDEOMEM
		mov es, bx

		call parseConsole ; get params from console
		
		@@mainLoop:
			call clearDisplay ; clear display before show
			call drawFrame    ; display frame on the screen
			call clearDisplay ; clear display after show
		jmp @@mainLoop
	
exitProgram:	mov ax, 4c00h
				int 21h
		
		endp

; ================================================== ;
; .................................................. ;
; ================================================== ;

clearDisplay 	proc
	
				mov ax, 0900h
				mov dx, offset BACKGROUND

				int 21h		

				ret
				endp

; ================================================== ; 
include DATA.ASM
include ERROR.ASM
include PARSER.ASM
; ================================================== ;

printString	proc
		
			mov cl, [di] ; get count of symbols
			inc di
			push ax

			sub si, cx

			mov ax, si   ; check alignment of symbols
			and ax, 1
			add si, ax

			add si, 2d

			pop ax

			@@next:
				mov al, byte ptr [di]
				mov es:[si], ax
				add si, 2d
				inc di

			loop @@next

			ret
			endp

; ================================================== ;
; .................................................. ;
; ================================================== ;

printLine	proc
		
			mov al, byte ptr [di] ; write first symbol
			mov es:[bx], ax
			add bx, 2d
			inc di

			mov al, byte ptr [di] ; write second N symbols of line
			@@next:
				mov es:[bx], ax
				add bx, 2d
			loop @@next

			inc di

			mov al, byte ptr [di] ; write last sym
			mov es:[bx], ax
			add bx, 2d
			inc di

			ret
			endp
		
; ================================================== ;
; .................................................. ;
; ================================================== ;

shiftToNextLine	proc
		
				xor ax, ax
				mov al, BORDER_WIDTH
				sub bx, ax
				sub bx, ax
				sub bx, 4d
				add bx, 160d

				ret
				endp

; ================================================== ;
; .................................................. ;
; ================================================== ;

drawFrame	proc
	
		xor cx, cx
		mov cl, BORDER_HEIGHT ; get border height

		mov ax, 25d	      ; 25 - border height
		sub ax, cx

		shr ax, 1	      ; ax / 2
		mov bx, 160d

		mul bx		      ; ax * 160

		mov bx, ax	      ; get start pos
		; --------------------------------------- ;
		; get pos by oX
		xor cx, cx
		mov cl, BORDER_WIDTH
		
		mov ax, 80d
		sub ax, cx
		; --------------------------------------- ;
		push bx

		mov bx, ax
		and bx, 1	; alignment by even addresses
		add ax, bx

		pop bx
		; --------------------------------------- ;
		add bx, ax
		sub bx, 2d
		
		mov si, bx	; get center
		xor ax, ax
		mov al, BORDER_WIDTH
		add si, ax
		; --------------------------------------- ;
		call selectStyle
		
		mov ah, WBCK_BFRONT ; write first line
		call printLine
		push di

		;mov di, offset DEFAULT_MESSAGE
		;call printString
		pop di

		mov dl, BORDER_HEIGHT
		
		xor cx, cx
		mov cl, TEXT_POSITION
		mov si, cx

		@@next:
			dec dl

			call shiftToNextLine
			mov cl, BORDER_WIDTH
		; -------------------------------------- ;
			mov ah, BORDER_HEIGHT
			sub ah, dl
			cmp ah, CURRENT_LINE
			je setCurrentColor
			mov ah, WBCK_BFRONT
		
			RETURN_TO_LOOP:
		; -------------------------------------- ;
			call printLine
			
			mov al, BORDER_HEIGHT ; get curr line number
			sub al, dl
			
			cmp al, LINE_COUNT    ; currLine > LINE_COUNT
			ja @@skipTextLine

			@@skipNext:	      ; skip spaces before string
				cmp [si], byte ptr ' '
				jne @@skipEnd
					inc si
				jmp @@skipNext
			
			@@skipEnd:
				push bx
				
				xor cx, cx
				mov cl, BORDER_WIDTH ; get print pos
				sub bx, cx
				sub bx, cx
			
				call printTextLineIntoBox

				pop bx
				@@skipTextLine:

				sub di, 3d

		
		cmp dl, 0
		jne @@next

		call shiftToNextLine
		add di, 3d
		
		mov ah, WBCK_BFRONT; print last line
		mov cl, BORDER_WIDTH
		call printLine

		ret
			endp
			
; ================================================== ;
; .................................................. ;
; ================================================== ;

setCurrentColor:	mov ah, BBCK_WFRONT
					jmp RETURN_TO_LOOP

; ================================================== ;
; .................................................. ;
; ================================================== ;

selectStyle	proc
		
		mov ah, [BORDER_STYLE]
		
		cmp ah, 1d
			je @FIRST_STYLE
		cmp ah, 2d
			je @SECOND_STYLE
		cmp ah, 3d
			je @THIRD_STYLE

		mov di, offset FIRST_BORDER
		ret

		@FIRST_STYLE:
			mov di, offset FIRST_BORDER
			ret
		@SECOND_STYLE:
			mov di, offset SECOND_BORDER
			ret
		@THIRD_STYLE:
			mov di, offset THIRD_BORDER
			ret
		
			endp

; ================================================== ;
; .................................................. ;
; ================================================== ;

printTextLineIntoBox	proc
		
			@@next:
				cmp [si], byte ptr '$'
				je @@endLoop

				mov al, byte ptr [si]
				mov es:[bx], ax
				
				add bx, 2d
				inc si
			
			jmp @@next

			@@endLoop:
			
			inc si	; go to next symbol after '$'
		
			ret
						endp


end		Start

; ////////////////////////////////////////////////// ;