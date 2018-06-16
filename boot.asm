format binary
use16
include "./include/const.inc"
include "./include/kernel.inc"
org 7c00h

jmp main

fs_name db "rfs"
heads db DISK_HEADS_DISK
cyls db DISK_CYLS_DISK
secs db DISK_SECS_DISK
secs_to_st db 01h ;сколько секторов для таблицы секторов

main:
cli
mov ax,RAM_STACK
mov ss,ax
mov sp,0ffffh
sti

mov word[lba],0001h
mov word[ars],RAM_ST
call read_sec

xor si,si

search_ft:
push RAM_ST/10h
pop es
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
mov word[ars],RAM_FT
call read_sec
xor si,si
push RAM_FT/10h
pop es
search_kernel:
mov ah,[es:si]
cmp ah,'k'
jne next_file
mov ah,[es:si+01h]
cmp ah,'e'
jne next_file
mov ah,[es:si+02h]
cmp ah,'r'
jne next_file
mov ah,[es:si+03h]
cmp ah,'n'
jne next_file
mov ah,[es:si+04h]
cmp ah,'e'
jne next_file
mov ah,[es:si+05h]
cmp ah,'l'
jne next_file
mov ah,[es:si+08h]
cmp ah,'s'
jne next_file
mov ah,[es:si+09h]
cmp ah,'y'
jne next_file
mov ah,[es:si+0ah]
cmp ah,'s'
jne next_file
mov dx,word[es:si+0ch]
jmp load_kernel
next_file:
add si,10h
cmp si,200h
je nf_kernel
jmp search_kernel

nf_kernel:
pop si
add si,02h
jmp search_ft

load_kernel:
push RAM_ST/10h
pop es
mov word[lba],dx
mov word[ars],RAM_KERNEL
call read_sec
load_next_kernel_sect:
mov si,word[lba]
mov ax,si
mov bx,02h
mul bx
mov si,ax
cmp word[es:si],ST_FLAG_EOF
je start_load_launch
mov dx,word[es:si]
mov word[lba],dx
add word[ars],200h
call read_sec
jmp load_next_kernel_sect

;-----------------------------------------------------------------------------------
start_load_launch:

call __exit_program

read_sec:
push ax
push bx
push cx
push dx
push es

mov ax,word[lba]
mov bh,DISK_SECS_DISK
div bh
inc ah
mov byte[s],ah

mov ax,word[lba]
xor bx,bx
mov bl,byte[s]
dec bx
sub ax,bx
xor bx,bx
mov bl,DISK_SECS_DISK
div bl 
xor ah,ah
mov bl,DISK_HEADS_DISK
div bl
mov byte[h],ah

xor bx,bx
mov bl,byte[s]
dec bx
mov al,byte[h]
mov cl,DISK_SECS_DISK
mul cl
add bx,ax
mov ax,word[lba]
sub ax,bx
mov bx,ax
mov al,DISK_HEADS_DISK
mov cl,DISK_SECS_DISK
mul cl
mov cx,ax
mov ax,bx
div cl
mov byte[c],al

mov cl,byte[s]
mov ch,byte[c]
mov dh,byte[h]
push 00
pop es
mov bx,word[ars]
mov dl,DISK_NUM_DISK
mov al,01h
mov ah,02h
int 13h

pop es
pop dx
pop cx
pop bx
pop ax
ret

lba dw 00h
s db 00h
c db 00h
h db 00h
ars dw 0000h

times (510-($-$$)) db 00h
db 55h,0aah