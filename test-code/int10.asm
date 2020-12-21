    global    _start

            section   .text
_start:     
;	set video mode
	jmp	loop0
	db	'23'
	mov	ax, 0x0002
	int	0x10
loop0:
;	write 'A' 16 times at current cursor.
        mov     ah, 0x0e                ; int 10h, write char.
	mov 	al, 'F'                 ; char 2 display.
        int     0x10

;	copy to 0:8000 the first sector.

	mov	ah, 0x42		; bios 13h extended read service code.
	mov	dl, 0x80		; drive No.

;	DS:SI - pointer to DAP (disk access packet).

	mov	si,  0
	mov	ds, si
	lea	si, [DAP]
	int 	0x13			; issue the command.
	jnc	ok_1
	mov	al, '!'
	mov	ah, 0x9	
	int 	0x10
ok_1:

;	print few lines from 7c00.

	mov	ax, 0x000
	mov	ds, ax
	sub	si, si			; ds:si = 0x7c00.
	add	esi, 0x8000
	mov	cx, 0x10		; one line 16 chars to print.
loop1:
	mov 	al, [esi]	        ; char to write
        mov     ah, 0x0e                ; int 10h, write char.
	and	al, 0xf0		; leave only 1st nibble
	shr	al, 4			; set 1st nibble on the 2nd nibble position.
	add	al, 0x30
	cmp	al, 0x3a		; [0-9]
	jl 	loop1_2
	add	al, 0x07		; [A-Z]
loop1_2:
        int     0x10

	mov 	ax, [esi]	        ;  char to write
        mov     ah, 0x0e                ; int 10h, write char.
	and	al, 0x0f		; leave only 2nd nibble
	add	al, 0x30
	cmp	al, 0x3a		; [0-9]
	jl 	loop1_2a
	add	al, 0x07		; [A-Z]
loop1_2a:
        int     0x10

	mov	ah, 0x0e
	mov	al, ' '
	int 	0x10

	inc	esi
	loopne 	loop1

        mov     ah, 0x0e                ; int 10h, write char.
	mov 	al, '1'                 ; char 2 display.
        int     0x10

	jmp	$
	mov	ax, 0x8000
	push 	ax
	ret

;	DAP packet for bios int 13h (ah=0x42)
	align	16
	db	'DAP.text'
DAP_text:
	align	16
	db 	0x10			; size of this data struct.
	db 	0x00			; unused.
	dw	0x01			; No. of sectors to read.
	dw	0x8000			; target segment.
	dw	0x0000			; target offset.
	dd	0x0			; not sure this needs to be inspected using ext2 on hdd not fdd.


        section   .data
;	DAP packet for bios int 13h (ah=0x42)
	align	16
	db	'DAP'
DAP:
	align	16
	db 	0x10			; size of this data struct.
	db 	0x00			; unused.
	dw	0x01			; No. of sectors to read.
	dw	0x8000			; target segment.
	dw	0x0000			; target offset.
	dd	0x0			; not sure this needs to be inspected using ext2 on hdd not fdd.

