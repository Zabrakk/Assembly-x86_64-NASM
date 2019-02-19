;Assembly FizzBuzz

STDIN equ 0
STDOUT equ 1

SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60

section .data
  text: db "Enter a number ", 0 ;Null terminator
  textLen: equ $ - text

  fizz: db "Fizz", 0xA;, 0xD ;New line
  buzz: db "Buzz", 0xA;, 0xD
  fizzLen: equ 5
  fizzbuzz: db "FizzBuzz", 0xA
  fizzbuzzLen: equ 9

section .bss
  number: resb 255

section .text
  global _start

_start:
  mov rsi, text ;Param for _printText
  mov rcx, textLen ;Length
  call _printText

  call _getNum ;User input has to be converted to integer
  mov rdi, number ;Users number to rdi
  mov byte[rsi + rax - 1], 0 ;Replace \n with 0 from end of the string
  call _toInt

  mov rbx, rax
  ;Text lengths to stack
  mov rdx, fizzbuzzLen
  push rdx
  mov rdx, fizzLen
  push rdx
  xor rdx, rdx ;Zero rdx so we can get the remainder of the division there

  call _getResult

  call _exit

_getResult: ;Determine what to print
  mov rsi, fizzbuzz
  mov rcx, [rsp + 16]
  mov rdi, 15
  div rdi
  cmp rdx, 0
  je _printText
  mov rax, rbx
  xor rdx, rdx
  mov rcx, [rsp + 8]
  mov rsi, buzz
  mov rdi, 5
  div rdi
  cmp rdx, 0
  je _printText
  mov rax, rbx
  xor rdx, rdx
  mov rsi, fizz
  mov rdi, 3
  div rdi
  cmp rdx, 0
  je _printText
  ret

_toInt: ;Result of convertion stored in rax
  mov rbx, 10 ;Multiply by 10
  xor rax, rax ;Result goes here
  xor rcx, rcx
  call _loop
  ret

_loop:
  mov cl, byte[rdi] ;Get one character from the number string, 8bits/1byte
  inc rdi ;Next char
  cmp cl, 0 ;End of string?
  je _end
  sub cl, '0' ;Sub 48
  mul rbx ;Multiply rax by 10
  add rax, rcx
  jmp _loop

_end: ;End of string convertion
  ret

_printText: ;Text in rsi, rcx value got from stack in _getResult
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rdx, rcx
  syscall
  ret

_getNum: ;Get number from user
  mov rax, SYS_READ
  mov rdi, STDIN
  mov rsi, number ;string to save to
  mov rdx, 255
  syscall
  ret

_exit:
  mov rax, SYS_EXIT
  mov rdi, 0  ;error code
  syscall