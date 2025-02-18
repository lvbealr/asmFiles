.model tiny
.386
.code 
org 100h
locals @@

; ################################################################## ;

Start:	jmp main ; jump to main function

; ================================================================== ;
; Describe:	main function
; Entry:	None
; Exit:		
; Destroy:	
; ================================================================== ;

main		proc

	mov bx, 0b800h		; put VIDEOMEM offset to ES
	mov es, bx	

	call parseConsole	; parse parameters from command-line

	@@mainLoop:

	call clearDisplay       ; clear monitor display
	call drawFrame		; draw frame on display
	call checkInput		; check user is keystroking
	call clearDisplay       ; clear monitor display

	jmp @@mainLoop

; ------------------------------------------------------------------ ;
exitProgramm:
	mov ax, 4c00h		; terminate programm (21H 4cH)
	int 21h 			

       		endp		; (end of main)


; ______ INCLUDE ______ ;
include data.asm	;
include error.asm	;
include parser.asm	;
include input.asm	;
; _____________________ ;


; ===================================================================== ;
; Describe:	Clear monitor display (fill out by CLEAN_MONITOR str)	;
; Entry:	(assumed) CLEAN_MONITOR - string 			;
; Exit:		None							;
; Destroy:	AX, DX							;
; ===================================================================== ;

clearDisplay	proc

	mov ah, 09h			; 21H 09H - Display Text
	mov dx, offset CLEAN_MONITOR	; DX = &CLEAN_MONITOR
	int 21h				; SYSCALL 21H

	ret
		endp

; ===================================================== ;
; Describe:	Print text line to display		;
; Entry:	AH - color attribute			;
;		SI - offset of memory			;
;		DI - pointer to string			;
;		(assumed) ES = 0b800h - VIDEOMEM offset	;
; Exit:		None					;
; Destroy:	AX, CX, DI				;
; ===================================================== ;

printString	proc
	mov cl, [di]	; CL = *DI

	inc di		; increment pos in string
	push ax		; save AX
	
	sub si, cx	; SI -= CX

	mov ax, si      ; AX = SI
	and ax, 1	; AX &= 1 (check mod 2)
	add si, ax	; SI += AX (complete to even number)
	
	add si, 2d	; SI += 2

	pop ax		; restore AX

	@@next:			; write symbol into VIDEOMEM
        mov al, byte ptr [di]	; AL = *DI
        mov es:[si], ax		; ES:[SI] = AX (write symbol)
        add si, 2d		; SI += 2 (shift)

        inc di			; increment pos in string
	loop @@next		; repeat

	ret
		endp

; ===================================================== ;
; Describe:	Print border or internal line		;
; Entry:	AH - background color attribute		;
;		DI - position in line			;
;		CX - count of internal symbols		;
;		BX - offset of memory			;
;		(assumed) ES = 0b800h - VIDEOMEM offset	;
; Exit:		None					;
; Destroy:						;
; ===================================================== ;

printLine	proc
	mov al, byte ptr [di]	; AL = *DI

	mov es:[bx], ax		; ES:[BX] = AX (write first symbol)
	add bx, 2d		; BX += 2 (shift)
	inc di			; increment pos in string

	mov al, byte ptr [di]	; AL = *DI

	@@next:			; write internal symbols

        mov es:[bx], ax		; ES:[BX] = AX (write symbol)
        add bx, 2d		; BX += 2 (shift)

	loop @@next

	inc di			; increment pos in string

	mov al, byte ptr [di]   ; AL = *DI
	mov es:[bx], ax		; ES:[BX] = AX (write last symbol)
	add bx, 2d		; BX += 2 (shift)

	inc di			; increment pos in string

	ret
		endp


; ============================================= ;
; Describe:	Shift to the next line function	;
; Entry:	BX - memory adress		;
; Exit:		BX - position of the next line	;
; Destroy:	AX				;
; ============================================= ;

shiftToNextLine	proc

	xor ax, ax		; AX = 0
	mov al, BORDER_WIDTH	; AL = BORDER_WIDTH

	sub bx, ax		; BX -= BORDER_WIDTH
	sub bx, ax		; BX -= BORDER_WIDTH
	sub bx, 4d		; BX -= 4
	add bx, 160d		; BX += 160 (maxWidth * 2)

	ret
		endp

; ===================================================== ;
; Describe:	Draw frame in the middle of the display	;
; Entry:	CX - border width			;
;		AH - border height			;
;		(assumed) ES = 0b800h - VIDEOMEM offset	;
; Exit:		None					;
; Destroy:	AX, BX, CX, DX, SI			;
; ===================================================== ;

drawFrame	proc
	xor cx, cx		; CX = 0
	mov cl, BORDER_HEIGHT   ; CL = BORDER_HEIGHT

	mov ax, 25d             ; AX = 25
				; (maxHeight) - BORDER_HEIGHT
	sub ax, cx		; AX -= CX

	shr ax, 1		; AX /= 2
	mov bx, 160d		; BX += 160 (maxWidth * 2)

	mul bx                  ; AX *= 160

	mov bx, ax              ; BX = AX (get start position)

; ___________________ GET POSITION BY OX __________________ ;
	xor cx, cx		; CX = 0
	mov cl, BORDER_WIDTH    ; CL = BORDER_WIDTH

	mov ax, 80d             ; AX = maxWidth - BORDER_WIDTH
	sub ax, cx		; AX -= CX
; --------------------------------------------------------- ;
	push bx		; save BX

	mov bx, ax 	; this part for aligment by
			; even numbers address

	and bx, 1	; BX &= 1
	add ax, bx	; AX += BX

	pop bx          ; restore bx
; --------------------------------------------------------- ;
	add bx, ax		; BX += AX
	sub bx, 2d		; BX -= 2

	mov si, bx      	; SI -= BX (get center of frame)

	xor ax, ax		; AX = 0
	mov al, BORDER_WIDTH	; AL = BORDER_WIDTH
	add si, ax		; SI += AX

; ______________________ SELECT MODE ______________________ ;
	call selectMode			; select style of border

	mov ah, WBACK_BFRONT		; set attribute
	call printLine			; print upper line

	push di				; save DI

	mov di, offset TABLE_NAME	; DI = &TABLE_NAME

	call printString		; print header (TABLE_NAME)

	pop di				; restore DI

	mov dl, BORDER_HEIGHT		; DL = BORDER_HEIGHT
; ---------------------------------------------------------- ;
	xor cx, cx		; CX = 0
	mov cl, TEXT_POSITION	; CL = TEXT_POSITION
	mov si, cx		; SI = CX

	@@next:			; print next line
        dec dl			; decrease line number

        call shiftToNextLine	; shift to next line
        mov cl, BORDER_WIDTH	; CL = BORDER_WIDTH

    ; ---------------------------------------------------------- ;
        mov ah, BORDER_HEIGHT	; AH = BORDER_HEIGHT
        sub ah, dl		; AH -= DL (AH -= lineNumber)

        cmp ah, CURRENT_LINE	; if AH == CURRENT_LINE
        je setCurrentColor	; set current color

        mov ah, WBACK_BFRONT	; AH = WBACK_BFRONT
        returnToLoop:
    ; ---------------------------------------------------------- ;
        call printLine		; print line

        mov al, BORDER_HEIGHT	; AL = BORDER_HEIGHT
        sub al, dl		; AL -= DL (AL -= lineNumber)

        cmp al, LINE_COUNT	; if AL > LINE_COUNT
                    ; (currLine > LINE_COUNT)
        ja @@skipTextLine	; skip text line

        @@skipNext:		; skip spaces before string
        cmp [si], byte ptr ' '	; if *si != ' '
        jne @@skipEnd		; go to skipEnd
            inc si

        jmp @@skipNext		; repeat

        @@skipEnd:

        push bx			; save BX

        xor cx, cx		; CX = 0
        mov cl, BORDER_WIDTH	; CL = BORDER_WIDTH
        sub bx, cx		; BX -= CX
        sub bx, cx		; (get pos to write)

        call printTextLineIntoBox ; print text into box

        pop bx			; restore BX

        @@skipTextLine:

        sub di, 3d		; DI -= 3

	cmp dl, 0		; if DL != 0
	jne @@next		; go to next

	call shiftToNextLine	; shift to next line
	add di, 3d		; DI += 3
   
	mov ah, WBACK_BFRONT	; AH = WBACK_BFRONT
	mov cl, BORDER_WIDTH	; CL = BORDER_WIDTH

	call printLine		; print line

	ret
		endp

; ============================================= ;
; Describe:	Set background and text color	;
; Entry:	None				;
; Exit:		AH - symbol attribute		;
; Destroy:	None				;
; ============================================= ;

setCurrentColor:
	mov ah, BBACK_WFRONT	; AH = BBACK_WRONT (TODO)

	jmp returnToLoop

; ============================================================= ;
; Describe:	Select border mode by code			;
; Entry:	AH						;
; Exit:		DI - pos of first symbol of selected border	;
; Destroy:	AH						;
; ============================================================= ;

selectMode	proc
	mov ah, [BORDER_MODE]		; AH = *BORDER_MODE
	
	cmp ah, 0d			; user preset
	je @USER_MODE

	cmp ah, 1d			; 1st preset
	je @FIRST_MODE

	cmp ah, 2d			; 2nd preset
	je @SECOND_MODE
		
	cmp ah, 3d			; 3d preset
	je @THIRD_MODE

	cmp ah, 4d			; 4th preset
	je @FOURTH_MODE

	mov di, offset USER_BORDER	; default preset
	ret

	@USER_MODE:
	mov di, offset USER_BORDER
	ret

	@FIRST_MODE:
	mov di, offset FIRST_BORDER
	ret

	@SECOND_MODE:
	mov di, offset SECOND_BORDER
	ret

	@THIRD_MODE:
	mov di, offset THIRD_BORDER
	ret

	@FOURTH_MODE:
	mov di, offset FOURTH_BORDER
	ret

		endp

; ===================================== ;
; Describe:	Print text into box	;
; Entry:	BX - position to write	;
;		(assumed) ES = 0b800h	;
;		SI - pos in string	;
; Exit:		None			;
; Destroy:	None			;
; ===================================== ;

printTextLineIntoBox	proc
    push cx si
    mov cx, si

    @@scanNext:
        cmp [si], byte ptr '$'
        je @@endScan
        inc si
        jmp @@scanNext
    @@endScan:

    sub cx, si
    neg cx

    push ax

    mov al, BORDER_WIDTH
    add al, BORDER_WIDTH
    sub al, 2
    sub al, cl
    sub al, cl
    shr al, 1

    mov ch, ah
    mov ah, 0
    add bx, ax
    mov ax, bx
    and al, 1
    mov ah, 0
    sub bx, ax

    pop ax si cx

	@@next:			; check line terminator
	cmp [si], byte ptr '$'	; if *si == '$'
	je @@endLoop		; it's end of line

	mov al, byte ptr [si]	; AL = *SI
	mov es:[bx], ax		; ES:[BX] = AX (write symbol)

	add bx, 2d		; BX += 2

	inc si			; increment pos in string

	jmp @@next		; repeat

	@@endLoop:

	inc si			; skip terminator '$'

	ret
			endp

; ################################################################## ;

end 		Start