;Asks the user for their name
;Max length for name is 16 characters

section .data
  text1: db "What is your name? ", 0
  text2: db "Hello, " ,0

section .bss
  name: resb 16 ;Reserve 16 bytes for the name

section .text
  global _start

_start: ;Subroutine calls
  push text1 ;Pass text1 as function parameter
  call _printText

  call _getName ;Get user input

  push text2
  call _printText

  push name
  call _printText
  call _exit

_printText: ;Params: String and length
  mov rax, 1 ;sys_write
  mov rdi, 1 ;stdout
  mov rsi, [rsp + 8] ;message address
  mov rbx, rsi ;Param for len
  call _len
  syscall
  xor rdx, rdx ;Make rdx zero
  ret

_len: ;Get the length of a String in register rbx, store to rdx
  inc rdx
  inc rbx
  cmp byte [rbx], 0
  jnz _len
  ret

_getName:
  mov rax, 0 ;sys_read
  mov rdi, 0 ;stdin
  mov rsi, name ;string to save to
  mov rdx, 16
  syscall
  xor rdx, rdx
  ret

_exit:
  mov rax, 60 ;sys_exit
  mov rdi, 0  ;error code
  syscall