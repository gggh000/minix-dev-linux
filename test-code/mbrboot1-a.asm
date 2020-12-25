;   https://cs.lmu.edu/~ray/notes/nasmtutorial/
extern      functionC
extern      functionC2int
extern      functionC2long

    global    _start

            section   .text
_start:     
            mov edi,7                       ; pass a function parameter
            call otherFunction              ; run the function below, until it does "ret"
            add eax,1                       ; modify returned value

	    mov     rax, 1                  ; system call for write
            mov     rdi, 1                  ; file handle 1 is stdout
            mov     rsi, message            ; address of string to output
            mov     rdx, 20                 ; number of bytes
            syscall                         ; invoke operating system to do the write

            push    rbp       
            mov     rbp, rsp
            push    100h
            push    200h
            ;mov    rdi, 11442233h     
	
	    push    lab1
            jmp     functionC2int           ; call function c
lab1:
            pop     rbp
            add     rsp, 8h

            mov     rax, 60                 ; system call for exit
            xor     rdi, rdi                ; exit code 0
            syscall                         ; invoke operating system to exit

; a function "declaration" in assembly

otherFunction: 
            mov     eax, edi ; return our function's only argument
	    mov     rax, 1                  ; system call for write
            mov     rdi, 1                  ; file handle 1 is stdout
            mov     rsi, message1           ; address of string to output
            mov     rdx, 22                 ; number of bytes
            syscall                         ; invoke operating system to do the write
            ret

            section   	.data
message:    db        	" ---Hello, World--- ", 10    ; note the newline at the end
message1:   db 		" --- otherFunction--- ", 10 

