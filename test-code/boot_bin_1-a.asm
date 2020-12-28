;   https://cs.lmu.edu/~ray/notes/nasmtutorial/
extern      functionC
extern      functionC2int
extern      functionC2long
    global    putchar1
    global    main

            section   .text
_start1:     
main:
	sub	ax, ax
	mov	ds, ax
        mov     al, '@'
        mov     ah, 0xe
        int     0x10
	jmp	$
	call	functionC
	mov	ax, 0x100
	call	functionC2int

; a function "declaration" in assembly

putchar1:
	sub	bx, bx
	jmp	$
otherFunction: 

            section   	.data
