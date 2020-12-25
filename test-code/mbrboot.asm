    global    _start

            section   .text
_start:     
;	set video mode
	jmp	loop0
	db	'24'
	mov	ax, 0x0002
	int	0x10
loop0:
;	write 'A' 16 times at current cursor.
        mov     ah, 0x0e                ; int 10h, write char.
	mov 	al, 'F'                 ; char 2 display.
        int     0x10

; 	inode of boot.bin is 12. Load  256 from 323 * 4096 + 11 * 256 onto 0x7e00-0x800 (up to 512 bytes)
;	from offset 0x18, check and load blocks. onto 0x8000-0x14000, or up to 12 blocks (12 * 4096).
;	as of 12.24.2020:
;	stat boot.bin block shows: (0-3): 1024-1027; (4-5): 1536-1537, (6-8): 2048-2050, (9): 1028
;	
;	copy to 0:7e000 the first sector.

	mov	ah, 0x42		; bios 13h extended read service code.
	mov	dl, 0x80		; drive No.

;	DS:SI - pointer to DAP (disk access packet).

	mov	si,  0x7c0
	mov	ds, si	
	lea	si, [DAP_text]		; [DS:SI]=7c0:DAP_TEXT
	int 	0x13			; issue the command.
	jnc	ok_1
	mov	al, '!'
	mov	ah, 0x9	
	int 	0x10
ok_1:

;	print few lines from 0000:7e00

	mov	ax, 0x000
	mov	ds, ax
	sub	si, si			; ds:si = 0x7e00.
	add	esi, 0x7e00		; inode 10, copied to 7e00.
	add	esi, 256 		; inode 11, offset into.
	add	esi, 0x20		; adv. another 16 bytes onto inode 11. offset 8 should print block number.
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

;	load data blocks onto 8000.


	mov 	cx, 12 ; Initialize counter, load only max direct blocks which is 12 by ext2 standard.
	sub	di, di			; [DI] = initialize counter, reverse of CX, rising counter.

dataBlockLoadLoop:	
	mov	si,  0x7e0
	mov	ds, si	
	mov	si, 0x100		; [DS:SI] 11th inode.
	add	si, 0x28		; [DS:SI] = offset into 1st data block number in inode.
	add	si, di			; [DS:SI] = walk to [di]'th data block in inode struct.
	shl	di, 2			; [DI] = multiple counter by 4 since, 4 bytes a time when walking through block No. in inode.
	mov	ax, [si]		; [AX]= should have first block No.
	and	eax, 0xffff		; [EAX] = first Block No.
	sub	si, 0x28		; offset onto inode in 7e0.

	mov	si, 0x7c0
	mov	ds, si			
	lea	si, [DAP_text]		; [DS:SI]=pointer to DAP.
	add	si, 2			; [DS:SI]=pointer to No. of sectors in dap packet.
	mov	[si], word 8		; load 8 sectors or one block at a time.

;	Update  dap field's destination address. This is incremented by DI(counter) * 4096(blocksize) + 8000.

	add	si, 2			; [DS:SI]=pointer to target offset of seg:off combination
	push	di			; save counter block based.
	shr	di, 2			; [DI] = counter is 1 increment at a time.
	shl	di, 12			; [DI] = multiply counter by block size.
	add	di, 0x8000		; [DI] = offset by target address.
	mov	[si], di		; set target offset to 0x8000 + block No * blockSize in [DI]
	pop	di			; [DI] = restore, DI, block offset based counter within inode.

;	ax=block NO. to load. Translate  it into sector.

	add	si, 4			; offset into sector number to load from field within dap packet.
	shl	eax, 12			; [EAX]	 = block number converted into byte offset.
	add	eax, 0x100000		; [EAX] = compensate for beginning of primary partition offset.
	shr	eax, 9			; [EAX] = sector No. convert from byte offset.
	mov	[si], eax		; update sector.

	mov	ah, 0x42		; bios 13h extended read service code.
	mov	dl, 0x80		; drive No.

	mov	si,  0x7c0
	mov	ds, si	
	lea	si, [DAP_text]		; [DS:SI]=7c0:DAP_TEXT

	int 	0x13			; issue the command.
	jmp	$

	loopne	dataBlockLoadLoop
	jmp	$

        mov     ah, 0x0e                ; int 10h, write char.
	mov 	al, '1'                 ; char 2 display.
        int     0x10
	jmp	$

;	DAP packet for bios int 13h (ah=0x42)
	align	16
	db	'DAP.text'
	align	16
DAP_text:
	db 	0x10			; size of this data struct.
	db 	0x00			; unused.
;	offset 2. When loading blocks, it should be 8. (blk size / sector size) = 4096 / 512.
	dw	0x01			; No. of sectors to read.
;	offset 4.
	dw	0x7e00			; target offset.
	dw	0x0000			; target segment.
;	offset 8.
	; (2048 sector(start of primary partition) + 323(inode offset) * 4096 (blocksz) + 12(inodeNo.) + 256 (inode size)) / 512 (sector size)
	dd	0x121d 			; ( (2048 * 512 sector(start of primary partition) + 323(inode offset) * 4096 (blocksz) + 10(inodeNo.) + 256 (inode size) )/ sector size 512
	dd	0x0			; sector 0 hi?.

        section   .data
;	DAP packet for bios int 13h (ah=0x42)
	align	16
	db	'DAP'
DAP:
	align	16
	db 	0x10			; size of this data struct.
	db 	0x00			; unused.
	dw	0x02			; No. of sectors to read.
	dw	0x8000			; offset.
	dw	0x0000			; segment.
	dw	0x0000			; target offset.
	dd	0x022181		; sector 0 lo?.
	dd	0x0			; sector 0 hi?.

