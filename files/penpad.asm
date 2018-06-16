org 0000h
format binary
use16
jmp main
include "./include/const.inc"
include "./include/kernel.inc"
next_c dw 00h
files_count dw 0000h
cursor_x dw 0000h
cursor_y dw 0000h
char_num dw 0000h
files_num dw 0000h
char_addr dw 0000h
user_cursor dw 0000h
cleaned_cursor_pos dw 0000h
user_c_c dw 0000h
lba dw 00h
s db 00h
c db 00h
h db 00h
sad dw 0000h
exit_n db "exit    "
;=======================================
main:
mov word[cs:files_count],0000h
mov word[cs:files_num],0000h
mov word[cs:next_c],0000h
xor si,si

search_ft:
push RAM_ST/10h
pop es
cmp si,1feh
je add_exit
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
mov word[cs:lba],si
push RAM_FT/10h
push 00h
push word[cs:lba]
call __read_sect
xor si,si
push RAM_FT/10h
pop es
search_files:
mov ah,[es:si+08h]
cmp ah,'t'
jne next_file
mov ah,[es:si+09h]
cmp ah,'x'
jne next_file
mov ah,[es:si+0ah]
cmp ah,'t'
jne next_file
jmp add_files

next_file:
add si,10h
cmp si,200h
je next_ft
jmp search_files

next_ft:
pop si
add si,02h
jmp search_ft

add_files:
cmp word[cs:files_count],0b7h
je add_exit
push si
push cs
pop ds
mov di,files
mov ax,0ah
mov bx,word[cs:files_count]
mul bx
add di,ax
inc word[cs:files_count]
mov cx,08h
loop1:
mov al,byte[es:si]
mov byte[ds:di],al
dec cx
inc si
inc di
cmp cx,0000h
je add_files_back
jmp loop1
add_files_back:
add si,04h
mov ax,word[es:si]
mov word[ds:di],ax
pop si
jmp next_file
;=========================
add_exit:
push cs
pop es
mov si,exit_n
push cs
pop ds
mov di,files
mov ax,0ah
mov bx,word[cs:files_count]
mul bx
add di,ax
inc word[cs:files_count]
mov cx,08h
loop3:
mov al,byte[es:si]
mov byte[ds:di],al
dec cx
inc si
inc di
cmp cx,0000h
je print_files
jmp loop3

;==========================
print_files:
call __clear_screen

next_files:
inc word[cs:files_num]
mov word[cs:char_num],0000h
mov ax,word[cs:files_num]
dec ax
mov bx,0ah
mul bx
mov word[cs:char_addr],ax
mov ax,files
add word[cs:char_addr],ax
mov ax,word[cs:files_num]
mov bx,17h
xor dx,dx
div bx
cmp dx,00h
jne np_1
mov dx,17h
dec ax
np_1:
mov word[cs:cursor_y],dx
mov bx,0ah
mul bx
add ax,02h
mov word[cs:cursor_x],ax
mov ax,word[cs:files_count]
inc ax
cmp word[cs:files_num],ax
je clear_cursor
jmp print_char

print_char:
push word[cs:cursor_y]
push word[cs:cursor_x]
push cs
pop es
mov si,word[cs:char_addr]
xor ax,ax
mov al,byte[es:si]
push COLOR_BLACK_B+COLOR_WHITE_T
push ax
call __print_char
inc word[cs:char_num]
cmp word[cs:char_num],0008h
je next_files
inc word[cs:char_addr]
inc word[cs:cursor_x]
jmp print_char
;=======================================
clear_cursor:
mov ax,word[cs:cleaned_cursor_pos]
inc ax
mov bx,17h
xor dx,dx
div bx
cmp dx,00h
jne cc_1
mov dx,17h
dec ax
cc_1:
mov word[cs:cursor_y],dx
mov bx,0ah
mul bx
inc ax
mov word[cs:cursor_x],ax
push word[cs:cursor_y]
push word[cs:cursor_x]
push COLOR_BLACK_B+COLOR_WHITE_T
mov ax,word[cs:cleaned_cursor_pos]
cmp word[cs:user_cursor],ax
jne push_clear_cursor
push '>'
jmp cont_print_cursor
push_clear_cursor:
push ' '
cont_print_cursor:
call __print_char

inc word[cs:cleaned_cursor_pos]
mov ax,word[cs:files_count]
inc ax
cmp word[cs:cleaned_cursor_pos],ax
je read_user

jmp clear_cursor


;======================================================

read_user:
mov word[cs:cleaned_cursor_pos],00h
call __read_key
cmp ah,KB_ENTER
je run_files
cmp ah,KB_UP
je up_user_cursor
cmp ah,KB_DOWN
je down_user_cursor
cmp ah,KB_RIGHT
je right_user_cursor
cmp ah,KB_LEFT
je left_user_cursor
jmp read_user

run_files:
mov ax,word[cs:files_count]
dec ax
cmp word[cs:user_cursor],ax
je exit
push cs
pop es
mov si,files
mov ax,000ah
mov cx,word[cs:user_cursor]
mul cx
add si,ax
add si,08h
mov ax,word[si]
mov word[cs:lba],ax
jmp load_file

exit:
call __exit_program


up_user_cursor:
cmp word[cs:user_cursor],0000h
jne up_user_cursor_1
jmp clear_cursor
up_user_cursor_1:
dec word[cs:user_cursor]
jmp clear_cursor

right_user_cursor:
cmp word[cs:files_count],17h
jb clear_cursor
mov ax,word[cs:files_count]
sub ax,17h
cmp word[cs:user_cursor],ax
jna right_user_cursor_1
jmp clear_cursor
right_user_cursor_1:
mov ax,word[cs:user_cursor]
inc ax
mov bx,17h
xor dx,dx
div bx
cmp dx,00h
jne ruc_1
mov dx,17h
ruc_1:
mov word[cs:user_c_c],dx
mov ax,word[cs:files_count]
mov bx,17h
xor dx,dx
div bx
cmp dx,00h
jne ruc_2
mov dx,17h
ruc_2:
cmp dx,word[cs:user_c_c]
jb clear_cursor
add word[cs:user_cursor],17h
jmp clear_cursor

left_user_cursor:
cmp word[cs:user_cursor],0017h
jnb left_user_cursor_1
jmp clear_cursor
left_user_cursor_1:
sub word[user_cursor],17h
jmp clear_cursor

down_user_cursor:
mov ax,word[cs:files_count]
dec ax
cmp word[cs:user_cursor],ax
jne down_user_cursor_1
jmp clear_cursor
down_user_cursor_1:
inc word[cs:user_cursor]
jmp clear_cursor

;====================================================

load_file:
	push RAM_APP/10h
	push files
  push word[cs:lba]
mov word[cs:sad],files
call __read_sect

	load_next_files_sect:
	push RAM_ST/10h
	pop es
	mov ax,word[cs:lba]
	mov bx,02h
	mul bx
	mov si,ax
	cmp word[es:si],ST_FLAG_EOF
	je print_file
	mov dx,word[es:si]
	mov word[cs:lba],dx
	add word[cs:sad],RAM_SECT
	push RAM_APP/10h
	push word[cs:sad]
	push word[cs:lba]
	call __read_sect
	jmp load_next_files_sect

print_file:
mov word[cs:next_c],0000h
call __clear_screen

next_char:
mov ax,word[cs:next_c]
mov bx,50h
xor dx,dx
div bx
push ax
push dx
push COLOR_BLACK_B+COLOR_WHITE_T
push 00h
pop es
mov si,RAM_APP+files
add si,word[cs:next_c]
xor ax,ax
mov al,byte[es:si]
cmp al,00h
je _end
push ax
call __print_char
inc word[cs:next_c]
jmp next_char

_end:
call __read_key

jmp main

times (1024-($-$$)) db 00h
files:
