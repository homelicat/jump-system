format binary
use16
org 0000h
mov sp,0ffffh
jmp main

string1 db "Nihao   ","exe"

include "./include/kernel.inc"
include "./include/const.inc"
include "./include/iofiles.inc"
main:

call __clear_screen

push cs
push string1
call iofiles_write_file_note

push cs
push string1
call iofiles_search_file_note

push ax
push 0fffh
call word iofiles_write_file_adr

jmp $

call __read_key

call __exit_program


times (1536-($-$$)) db 00h
