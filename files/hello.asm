format binary
use16
org 0000h
mov sp,0ffffh
jmp main
include "./include/kernel.inc"
include "./include/const.inc"
include "./include/std.inc"
msg db 'Hello world!',00h
main:
call __clear_screen

push 0
push 0
push COLOR_BLACK_B+COLOR_WHITE_T
push RAM_APP/10h
push msg
call std_print_string

call __read_key

call __exit_program


times (1536-($-$$)) db 00h
