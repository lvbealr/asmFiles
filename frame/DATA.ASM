.data
	FIRST_BORDER  	db 0c9h, 0cdh, 0bbh, 0bah, 0b0h, 0bah, 0c8h, 0cdh, 0bch, '$'
	SECOND_BORDER	db "/-\| |\-/", '$'	
	THIRD_BORDER	db "+-+| |+-+", '$'
	FOURTH_BORDER	db 03h, 5fh, 03h, 03h, 00h, 03h, 03h, 2dh, 03h
	TABLE_NAME	db 6d,"@ded32"

	WBACK_BFRONT	db 02d
	BBACK_WFRONT	db 02d

	USER_BORDER 	db 9 dup('~'), '$'
	BORDER_WIDTH  	db 10d
	BORDER_HEIGHT 	db 10d
	BORDER_MODE   	db 01d
	TEXT_POSITION	db 00d
	CURRENT_LINE  	db 01d
	LINE_COUNT   	db 00d

	ERROR_MESSAGE 	db "Error!", '$'
	CLEAN_MONITOR 	db 80*24 dup(' '), '$'
.code