org 0000h
use16
format binary
jmp main
include "./include/const.inc"
include "./include/kernel.inc"
programs_count dw 0000h
cursor_x dw 0000h
cursor_y dw 0000h
char_num dw 0000h
program_num dw 0000h
char_addr dw 0000h
user_cursor dw 0000h
cleaned_cursor_pos dw 0000h
user_c_c dw 0000h
lba dw 00h
s db 00h
c db 00h
h db 00h
shutdown_n db "shutdown"
reboot_n db "reboot  "
;=======================================
main:
xor si,si

; обнуляем ячейки данных, бо старые данные могут на новые накладываться
mov word[programs_count],00h
mov word[program_num],00h
mov word[user_cursor],00h

search_ft:
push RAM_ST/10h
pop es
cmp si,1feh
je add_sys_app
mov bx,word[es:si]
cmp bx,ST_FLAG_ROOT
je read_ft
add si,02h
jmp search_ft

read_ft:
push si
mov ax,si
mov bx,02h
xor dx,dx
div bx
mov si,ax
mov word[lba],si
push RAM_FT/10h
push 00h
push word[lba]
call __read_sect
xor si,si
push RAM_FT/10h
pop es
search_app:
mov ah,[es:si+08h]
cmp ah,'a'
jne next_file
mov ah,[es:si+09h]
cmp ah,'p'
jne next_file
mov ah,[es:si+0ah]
cmp ah,'p'
jne next_file
jmp add_app

next_file:
add si,10h
cmp si,200h
je next_ft
jmp search_app

next_ft:
pop si
add si,02h
jmp search_ft

add_app:
cmp word[programs_count],0b6h
je add_sys_app
push si
push cs
pop ds
mov di,programs
mov ax,0ah
mov bx,word[programs_count]
mul bx
add di,ax
inc word[programs_count]
mov cx,08h
loop1:
mov al,byte[es:si]
mov byte[ds:di],al
dec cx
inc si
inc di
cmp cx,0000h
je add_app_back
jmp loop1
add_app_back:
add si,04h
mov ax,word[es:si]
mov word[ds:di],ax
pop si
jmp next_file
;=========================
add_sys_app:
push cs
pop es
mov si,reboot_n
push cs
pop ds
mov di,programs
mov ax,0ah
mov bx,word[programs_count]
mul bx
add di,ax
inc word[programs_count]
mov cx,08h
loop3:
mov al,byte[es:si]
mov byte[ds:di],al
dec cx
inc si
inc di
cmp cx,0000h
je add_next_sys_app
jmp loop3

add_next_sys_app:
push cs
pop es
mov si,shutdown_n
push cs
pop ds
mov di,programs
mov ax,0ah
mov bx,word[programs_count]
mul bx
add di,ax
inc word[programs_count]
mov cx,08h

loop4:
mov al,byte[es:si]
mov byte[ds:di],al
dec cx
inc si
inc di
cmp cx,0000h
je print_programs
jmp loop4
;==========================
print_programs:
call __clear_screen

next_program:
inc word[program_num]
mov word[char_num],0000h
mov ax,word[program_num]
dec ax
mov bx,0ah
mul bx
mov word[char_addr],ax
mov ax,programs
add word[char_addr],ax
mov ax,word[program_num]
mov bx,17h
xor dx,dx
div bx
cmp dx,00h
jne np_1
mov dx,17h
dec ax
np_1:
mov word[cursor_y],dx
mov bx,0ah
mul bx
add ax,02h
mov word[cursor_x],ax
mov ax,word[programs_count]
inc ax
cmp word[program_num],ax
je clear_cursor
jmp print_char

print_char:
push word[cursor_y]
push word[cursor_x]
push cs
pop es
mov si,word[char_addr]
xor ax,ax
mov al,byte[es:si]
push COLOR_BLACK_B+COLOR_WHITE_T
push ax
call __print_char
inc word[char_num]
cmp word[char_num],0008h
je next_program
inc word[char_addr]
inc word[cursor_x]
jmp print_char
;=======================================
clear_cursor:
mov ax,word[cleaned_cursor_pos]
inc ax
mov bx,17h
xor dx,dx
div bx
cmp dx,00h
jne cc_1
mov dx,17h
dec ax
cc_1:
mov word[cursor_y],dx
mov bx,0ah
mul bx
inc ax
mov word[cursor_x],ax
push word[cursor_y]
push word[cursor_x]
push COLOR_BLACK_B+COLOR_WHITE_T
mov ax,word[cleaned_cursor_pos]
cmp word[user_cursor],ax
jne push_clear_cursor
push '>'
jmp cont_print_cursor
push_clear_cursor:
push ' '
cont_print_cursor:
call __print_char

inc word[cleaned_cursor_pos]
mov ax,word[programs_count]
inc ax
cmp word[cleaned_cursor_pos],ax
je read_user

jmp clear_cursor


;======================================================

read_user:
mov word[cleaned_cursor_pos],00h
call __read_key
cmp ah,KB_ENTER
je run_program
cmp ah,KB_UP
je up_user_cursor
cmp ah,KB_DOWN
je down_user_cursor
cmp ah,KB_RIGHT
je right_user_cursor
cmp ah,KB_LEFT
je left_user_cursor
jmp read_user

run_program:
mov ax,word[programs_count]
dec ax
cmp word[user_cursor],ax
je shutdown
dec ax
cmp word[user_cursor],ax
je reboot
push cs
pop es
mov si,programs
mov ax,000ah
mov cx,word[user_cursor]
mul cx
add si,ax
add si,08h
push word[si]
call __run_program

shutdown:
call __shutdown

reboot:
call __reboot

up_user_cursor:
cmp word[user_cursor],0000h
jne up_user_cursor_1
jmp clear_cursor
up_user_cursor_1:
dec word[user_cursor]
jmp clear_cursor

right_user_cursor:
cmp word[programs_count],17h
jb clear_cursor
mov ax,word[programs_count]
sub ax,17h
cmp word[user_cursor],ax
jna right_user_cursor_1
jmp clear_cursor
right_user_cursor_1:
mov ax,word[user_cursor]
inc ax
mov bx,17h
xor dx,dx
div bx
cmp dx,00h
jne ruc_1
mov dx,17h
ruc_1:
mov word[user_c_c],dx
mov ax,word[programs_count]
mov bx,17h
xor dx,dx
div bx
cmp dx,00h
jne ruc_2
mov dx,17h
ruc_2:
cmp dx,word[user_c_c]
jb clear_cursor
add word[user_cursor],17h
jmp clear_cursor

left_user_cursor:
cmp word[user_cursor],0017h
jnb left_user_cursor_1
jmp clear_cursor
left_user_cursor_1:
sub word[user_cursor],17h
jmp clear_cursor

down_user_cursor:
mov ax,word[programs_count]
dec ax
cmp word[user_cursor],ax
jne down_user_cursor_1
jmp clear_cursor
down_user_cursor_1:
inc word[user_cursor]
jmp clear_cursor

times (1024-($-$$)) db 00h
programs:
