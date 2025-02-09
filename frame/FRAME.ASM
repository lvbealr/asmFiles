.model tiny
.code
org 100h

Start:		mov ch, 40h			
		mov cl, 10h		
						
		call findCenter
		call drawFrame

		mov ax, 4c00h
		int 21h

; ============================================= ;
; Find the (x, y) coordinates of frame's center ;
; Entry: 	CL = height, CH = length        ;
; Exit:   	DX = frame start offset		;
; Destroy List: AX				;
; ============================================= ;

findCenter	proc
		
		mov ax, 0019h
		sub al, cl
		shr ax, 1
		mov dh, al

		mov ax, 0050h
		sub al, ch
		mov dl, al
		
		dec dh
		mov al, 00A0h
		mul dh
		mov dh, 0h
		add dx, ax

		ret
		endp

; ================================================== ;
; Draw frame on the screen                           ;
; Entry:        DX = frame start offset, CL = height ;
; Exit:		None                                 ;
; Destroy List: BX, ES, SI, CL			     ;
; ================================================== ;

drawFrame 	proc
		mov bx, 0b800h
		mov es, bx
		
		mov bx, dx
		mov si, offset FRAME_STYLE
		
		push bx
		call drawLine
		
		inc si
		dec cl

		internalLines:
			pop bx
			add bx, 00A0h
			push bx
			call drawLine
			
			sub si, 2h
			dec cl
			
			cmp cl, 1h
			jne internalLines

		add si, 3h
		pop bx
		add bx, 00A0h
		call drawLine

		ret
		endp

; ============================================= ;
; Draw one line on the screen                   ;
; Entry:        SI = current char addr,  	;
;	        ES = VMEM start addr		;
; Exit:         None				;
; Destroy List: BX, DX, SI			;
; ============================================= ;

drawLine	proc
		
		push cx
		mov dl, byte ptr [si]
		mov dh, 75h
		mov es:[bx], dx
		
		dec ch
		add bx, 2
		
		inc si
		mov dl, byte ptr [si]

		mainLine:
			mov es:[bx], dx
			
			dec ch
			add bx, 2
			
			cmp ch, 1h
			jne mainLine

		inc si
		mov dl, byte ptr [si]
		mov es:[bx], dx
		
		pop cx
		
		ret
		endp

FRAME_STYLE 	db 03h, 03h, 03h, 03h, 0b0h, 03h, 03h, 03h, 03h ; hearts

STRING          db "Sweet February 14th", 0dh, 0ah, \
		   "Valentine's Day!",    0dh, 0ah, '$'

end		Start