    global    _start

            section   .text
_start:     
;	set video mode
	mov	ax, 0x0002
	int	0x10

; 	set cursor
;	mov 	ah, 0x2  		; set cursor function.
;	sub 	bh, bh			; select page.
;	mov 	dl, 10			; row 10.
;	sub	dh, dh			; col 0.
;	int 	0x10			; call

;	write 'A' 16 times at current cursor.
        mov     ah, 0x0e                ; int 10h, write char.
	mov 	al, '#'                 ; char 2 display.
        int     0x10
        mov     ah, 0x0e                ; int 10h, write char.
	mov 	al, '$'                 ; char 2 display.
        int     0x10
	jmp     $

        section   .data
