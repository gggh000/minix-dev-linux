    global    _start

            section   .text
_start:     
;	set video mode
	mov	ax, 0x0002
	int	0x10

;	write 'A' 16 times at current cursor.
        mov     ah, 0x0e                ; int 10h, write char.
	mov 	al, 'G'                 ; char 2 display.
        int     0x10
        mov     ah, 0x0e                ; int 10h, write char.
	mov 	al, '4'                 ; char 2 display.
        int     0x10

	jmp	$	
	mov	ah, 0x42		; bios 13h extended read service code.
	mov	dl, 0x81		; drive No.

;	DS:SI - pointer to DAP (disk access packet).

	mov	ax, 0x7c00
	mov	ds, ax
	lea	si, [DAP]

	int 	0x13			; issue the command.

;	print few lines from there.

	mov	ax, 0x000
	mov	ds, ax
	sub	si, si			; ds:si = 0x8000.
	add	esi, 0x8000
	mov	cx, 0x10		; one line 16 chars to print.
	sub	esi, esi
loop1:
	mov 	ax, [esi]	        ;  char to write
        mov     ah, 0x0e                ; int 10h, write char.
	add	al, 0x30
	cmp	al, 0x3a		; [0-9]
	jl 	loop1_2
	add	al, 0x07		; [A-Z]
loop1_2:
        int     0x10
	inc	esi
	loopne 	loop1
	
        mov     ah, 0x0e                ; int 10h, write char.
	mov 	al, '1'                 ; char 2 display.
        int     0x10

	jmp	$
	mov	ax, 0x8000
	push 	ax
	ret

DAP:
;	DAP packet for bios int 13h (ah=0x42)
	db 	0x10			; size of this data struct.
	db 	0x00			; unused.
	dw	0x02			; No. of sectors to read.
	dd	0x00008000		; segment:offset of target location in memory
	dd	0x0			; not sure this needs to be inspected using ext2 on hdd not fdd.

        section   .data
