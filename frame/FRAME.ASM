.model tiny
.386
.code 
org 100h
locals @@

WBACK_BFRONT equ 70h
BBACK_WFRONT equ 07h

Start:
jmp main                ; jump to the main function

; The main function
main                proc

    mov bx, 0b800h          ; Puts to es offset to a vmem adress
    mov es, bx

    call parseConsole             ; Parse data from command line

    @@mainLoop:

    call clearDisplay              ; clearDisplay monitor

    call drawFrame      ; Display border

    call checkInput        ; Check input(pressed keys)

    call clearDisplay              ; clearDisplay monitor

    jmp @@mainLoop

;---------------------------------------------------------------
exitProgramm:
    mov ax, 4c00h           ; Terminate programm
    int 21h 
                    endp

; Function that clean monitor
; Destroy           AH, DX
clearDisplay               proc
    mov ah, 09h
    mov dx, offset CLEAN_MONITOR
    int 21h

    ret
                    endp
;---------------------------------------------------------------
include data.asm
;---------------------------------------------------------------
include input.asm
;---------------------------------------------------------------
include error.asm
;---------------------------------------------------------------
include parser.asm
;---------------------------------------------------------------

; Write text line to display
; Entry             AH - color atribute
;                   SI - offset of memory
;                   DI - pointer to string
; Assumes           ES = 0b800h
; Destr             SI, CX, DI, AX
printString        proc
    mov cl, [di]       ; get count of symbols        
    inc di
    push ax
    
    sub si, cx

    mov ax, si         ; check aligment of symbols
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

; Write 3 special symbols
; Entry             AH - background color atribute
;                   DI - special line position
;                   CX - count of central symbols
;                   BX - offset of memory
; Assumes           ES = 0b800h
; Destr             AL, DI, CX
printLine          proc
    mov al, byte ptr [di]               ; write first symbol
    mov es:[bx], ax
    add bx, 2d
    inc di

    mov al, byte ptr [di]               ; Write second N symbols of line
    @@next:
        mov es:[bx], ax
        add bx, 2d
    loop @@next
    inc di

    mov al, byte ptr [di]               ; write first symbol
    mov es:[bx], ax
    add bx, 2d
    inc di

    ret
                    endp

; Shift to the next line function
; Entry             BX - memory adress
; Destr             BX, AX
; Return            BX position of the next line
shiftToNextLine  proc
    xor ax, ax
    mov al, BORDER_WIDTH
    sub bx, ax
    sub bx, ax
    sub bx, 4d
    add bx, 160d
    ret
                    endp

; Write border in the midle on the monitor
; Entry             CX - width of the border
;                   AH - height of the border
; Assumes           ES = 0b800h
; Destr             CX, AX, BX, SI, DI, DX
drawFrame       proc
    xor cx, cx
    mov cl, BORDER_HEIGHT       ; get border height

    mov ax, 25d                 ; 25 - border height
    sub ax, cx

    shr ax, 1                   ; ax/2
    mov bx, 160d                

    mul bx                      ; ax * 160

    mov bx, ax                  ; get start position

;------------------------------------------------------
;get position by OX
    xor cx, cx
    mov cl, BORDER_WIDTH        ; get border width in cl

    mov ax, 80d                 ; 80 - BORDER_WIDTH
    sub ax, cx
;--------------------------------
    push bx                     ; save bx

    mov bx, ax                  ; this part for aligment by even numbers adress
    and bx, 1
    add ax, bx

    pop bx                      ; repair bx
;--------------------------------
    add bx, ax
    sub bx, 2d

    mov si, bx          ; get center of border
    xor ax, ax
    mov al, BORDER_WIDTH
    add si, ax

;------------------------------------------------

    call selectMode                    ; set border style

    mov ah, WBACK_BFRONT      ; Write first line
    call printLine
    push di

    mov di, offset TABLE_NAME           ; write border name
    call printString
    pop di

    mov dl, BORDER_HEIGHT               ; write border body

    xor cx, cx
    mov cl, TEXT_POSITION
    mov si, cx

    @@next:
        dec dl

        call shiftToNextLine
        mov cl, BORDER_WIDTH

;-------------------------------------------------------------
        mov ah, BORDER_HEIGHT           ; Select line color
        sub ah, dl
        cmp ah, CURRENT_LINE
        je setCurrentColor
        mov ah, WBACK_BFRONT
        returnToLoop:
;-------------------------------------------------------------

        call printLine

        mov al, BORDER_HEIGHT           ; get current line number
        sub al, dl

        cmp al, LINE_COUNT              ; current line > LINE_COUNT
        ja @@skipTextLine

        @@skipNext:                    ; skip spaces before string
        cmp [si], byte ptr ' '
        jne @@skipEnd
            inc si
        jmp @@skipNext
        @@skipEnd:

        push bx                         ; Save bx

        xor cx, cx
        mov cl, BORDER_WIDTH            ; get write position
        sub bx, cx
        sub bx, cx

        call printTextLineIntoBox

        pop bx                          ; Repair bx
        @@skipTextLine:

        sub di, 3d

    cmp dl, 0
    jne @@next

    call shiftToNextLine
    add di, 3d
                                     
    mov ah, WBACK_BFRONT      ; write last line
    mov cl, BORDER_WIDTH
    call printLine

    ret
                    endp

; Function set Black background and white text
; Destroy           AH
setCurrentColor:  
    mov ah, BBACK_WFRONT
    jmp returnToLoop


; Select border mode by code //TODO: a[i]
; Destroy           AH
; Return            DI - the position of the first symbol of selected border
selectMode         proc
    mov ah, [BORDER_MODE]

    cmp ah, 1d
        je @FIRST_MODE
    cmp ah, 2d
        je @SECOND_MODE
    cmp ah, 3d
        je @THIRD_MODE
    cmp ah, 4d
	je @FOURTH_MODE


    mov di, offset FIRST_BORDER
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

; Write text from input
; Entry             BX - position
; Asumes            ES = 0b800h
; Destroy           SI, BX
printTextLineIntoBox proc

    @@next:
    cmp [si], byte ptr '$'               ; Check line terminator
    je @@endLoop

    mov al, byte ptr [si]
    mov es:[bx], ax

    add bx, 2d
    inc si

    jmp @@next

    @@endLoop:

    inc si                      ; go to next symbol after $
    
    ret
                    endp

end Start