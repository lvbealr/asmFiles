.model tiny
.code
org 100h

Start:	mov ax, 0900h		 ; 	sysCall
		mov dx, offset String;	dx = &String
		int 21h				 ;	21st cell in IDT
		
		mov ax, 4c00h        ;	DOS Func 4ch = exit(al)
		int 21h				 ;

.data
String:	db "MEOW MEOW, feed me I'm hungry Vanya", 0dh, 0ah, '$'

.code
end 	Start
