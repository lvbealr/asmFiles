.data
FIRST_BORDER    db 0c9h, 0cdh, 0bbh, 0bah, 0b0h, 0bah, 0c8h, 0cdh, 0bch, '$'
SECOND_BORDER   db "/-\I I\-/", '$'
THIRD_BORDER    db "+-+I I+-+", '$'
DEFAULT_MESSAGE db "Hello, World!", '$' 
BORDER_WIDTH    db 10d
BORDER_HEIGHT   db 10d
BORDER_STYLE    db 01d
TEXT_POSITION   db 00d
CURRENT_LINE    db 01d
LINE_COUNT	db 00d
ERROR_MESSAGE   db "ERROR", 0dh, 0ah, '$'
BACKGROUND 	db 80*24 dup(' '), '$' 
.code