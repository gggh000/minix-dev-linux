; -----------------------------------------------------------------------------
; A 64-bit function that returns the maximum value of its three 64-bit integer
; arguments.  The function has signature:
;
;   int64_t maxofthree(int64_t x, int64_t y, int64_t z)
;
; Note that the parameters have already been passed in rdi, rsi, and rdx.  We
; just have to return the value in rax.
; -----------------------------------------------------------------------------

        global  maxofthree
        section .text
maxofthree:
	mov	ah, 0xe
	mov	al, '$'
	int	0x10	
	jmp 	$
        mov     ax, di                ; result (rax) initially holds x
        cmp     ax, si                ; is x less than y?
        cmovl   ax, si                ; if so, set result to y
        cmp     ax, dx                ; is max(x,y) less than z?
        cmovl   ax, dx                ; if so, set result to z
	
        ret                           ; the max will be in rax
