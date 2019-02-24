;Sieve of Eratosthenes

;Filling the stack
;rax = Max number, adding numbers unlit rax = 0

;Removing nonprime numbers
;rax = number from stack, not 0
;rcx = 8, for changing stack position
;rsi = counter for rsp value changing
;rbx = copy of rax, for multiplication
;r8 = points to original rbp
;r9 = points to original rsp

;Printing the stack
;rax = value to print, popped from stack
;rcx = memory address for the string
;rdi = divider, value is 10
;rdx = remainder of div, needs to be xord
;rbx = str length counter, starts at 1
;rsp, rbp = stack pointers that end the printing proces when cmp is 0

STDOUT equ 1
SYS_WRITE equ 1
SYS_EXIT equ 60

MAX equ 200 ;Max number for stack here

section .data
  newLine: db 0xA, 0xD ;For printing numbers on different lines

section .bss
  digitSpace: resb 100 ;Numbers are strored here as a string

section .text
  global _start

_start:
  mov rax, MAX ;Max number
  mov rbp, rsp
  mov r8, rbp
  jmp _fillStack

_fillStack: ;Add numbers from MAX -> 1 into stack
  push rax
  dec rax
  cmp rax, 0
  jnz _fillStack
  ;Stack filled
  jmp _initNumberRemoval

_initNumberRemoval:
  mov rcx, 8
  mov rsi, 0
  mov rbp, rsp
  pop rax ;Remove one from stack, it is not a prime number
  mov r9, rsp
  jmp _removeNumbers

_removeNumbers:
  add rbp, rcx ;Get next number in stack
  mov rsp, rbp
  mov rax, [rsp] ;Number to rax
  cmp rax, 0 ;Is current number 0?
  jz _removeNumbers ;If true, get next number
  mov rbx, rax

  mul rax
  cmp rax, MAX ;Is the number² bigger than MAX?
  jg _initPrinting ;If true, all numbers have been found, start printing
  jmp _mulPointer

_mulPointer: ;Start from number = rax * rax, e.g. 9
  dec rax
  add rsp, rcx ;Add 8
  cmp rax, rbx
  jnz _mulPointer ;rsp now points to number rax * rax

  mov dword [rsp], 0 ;rsp value to 0
  mul rax
  xor rsi, rsi ;Zero rsi
  jmp _movePointer

_movePointer: ;Add 8 to rsp until we are at the value we want to remove
  add rsp, rcx
  inc rsi ;Counter
  cmp rsi, rbx
  jnz _movePointer

  add rax, rbx
  cmp rax, MAX ;Check if rax + rbx is more than MAX
  jg _removeNumbers ;If true return to _removeNumbers

  mov dword [rsp], 0 ;Zero found nonprime number
  xor rsi, rsi
  jmp _movePointer

_initPrinting: ;Set register values for printing
  mov rcx, digitSpace
  mov rbp, r8 ;To original position i.e. 2
  mov rsp, r9
  xor rdx, rdx ;Zero rdx so we get remainder
  mov rbx, 1 ;Set print len to 1
  pop rax ;Get first value i.e. 2
  jmp _stackToStr

_stackToStr: ;Turn value from the stack into a string one character at a time
  ;Value must be in rax
  mov rdi, 10
  div rdi
  mov [rcx], rdx
  add byte[rcx], '0' ;integer into ASCII
  xor rdx, rdx
  cmp rax, 0 ;Integer converted to string?
  jz _printLoop
  inc rbx ;Increase string length
  inc rcx ;Next memory position
  jmp _stackToStr

_printLoop: ;Prints the values in reversed order in relation to division
  ;20/10 -> 0, 2/10 -> 2, reverses that
  call _printRCX
  dec rcx
  dec rbx
  cmp rbx, 0
  jz _printRestart ;Restart printing process
  jmp _printLoop

_printRCX: ;Print rcx, syscall changes rcx value so return it from rsi
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, rcx
  mov rdx, 1
  syscall
  mov rcx, rsi
  ret

_printRestart:
  ;Line change first
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, newLine
  mov rdx, 3
  syscall

  ;Reset needen values for next round of printing
  mov rcx, digitSpace
  mov rbx, 1
  xor rdx, rdx
  jmp _isNextZero

_isNextZero: ;Get non zero values from stack to print
  pop rax
  cmp rax, 0
  je _isNextZero
  cmp rsp, rbp ;Stop printing?
  jle _stackToStr
  jmp _exit

_exit: ;End program
  mov rax, SYS_EXIT
  mov rdi, 0  ;error code
  syscall
