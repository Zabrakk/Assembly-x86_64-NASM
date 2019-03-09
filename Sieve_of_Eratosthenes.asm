;Sieve of Eratosthenes

;Filling the stack
;rax = Max number, adding numbers unlit rax = 0

;Removing nonprime numbers
;rax = number from stack, not 0
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

MAX equ 2000 ;Max number for stack here

section .data
  newLine: db 0xA, 0xD ;For printing numbers on different lines

section .bss
  digitSpace: resb 100 ;Numbers are strored here as a string

section .text
  global _start

_start:
  mov rax, MAX ;Max number to rax
  mov rbp, rsp ;Stack pointer to base
  mov r8, rbp
  jmp _fillStack

_fillStack: ;Add numbers from MAX -> 2 into stack
  cmp rax, 1 ;Don't add 1 to stack
  jz _initNumberRemoval
  push rax
  dec rax
  jmp _fillStack

_initNumberRemoval:
  mov rsi, 0 ;Counter
  mov r9, rsp ;Store the location for top of stack in r9
  jmp _getNum

_getNum:
  mov rax, [rsp + 8*rsi] ;Calculate stack offset based on rsi
  inc rsi ;Getting the next value in stack
  cmp rax, 0
  jz _getNum ;Get next number, this one has beed zeroed

  mov rbx, rax ;Store original rax into rbx for add operation
  mul rax
  cmp rax, MAX ;Is currect number² greater than MAX
  jg _initPrinting ;To print
  sub rax, 2 ;To get the correct value we have to subtract 2 from rax

_removeLoop:
  cmp rax, MAX
  jg _getNum
  mov DWORD [rsp + 8*rax], 0 ;Zero the number equal to rax in stack
  add rax, rbx
  jmp _removeLoop

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
