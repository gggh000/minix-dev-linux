;   https://cs.lmu.edu/~ray/notes/nasmtutorial/
extern      functionC
extern      functionC2int
extern      functionC2long

    global    _start

            section   .text
_start:     
	sub	ax, ax
	mov	ds, ax
	jmp	$
	call	functionC
	mov	ax, 0x100
	call	functionC2int

; a function "declaration" in assembly

otherFunction: 

            section   	.data
