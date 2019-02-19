;String to Integer

STDIN equ 1
STDOUT equ 0

SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60

section .data
  num: db "574", 0

section .text
  global _start

_start:
  call _toInt
  call _exit

_toInt: ;Result of convertion stored in rax
  mov rbx, 10 ;Multiply by 10
  xor rax, rax ;Result goes here
  xor rcx, rcx
  mov rdi, num ;Number to rdi
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

_end: ;End string conversion
  ret

_exit:
  mov rax, SYS_EXIT ;sys_exit
  mov rdi, 0  ;error code
  syscall