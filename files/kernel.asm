org 0000h
format binary
use16
include "./include/kernel.inc"
include "./include/const.inc"


; выключает компьютер
shutdown:
  mov ah,53h
  mov al,07h
  mov bx,0001h
  mov cx,0003h
  int 15h

; перезагружает компьютер
reboot:
  jmp 0ffffh:0000h

; выводит символ(!1) на экран, заданным цветом(!2), по x(!3) и y(!4)
print_char:
  pusha
  mov bp,sp
  mov ax,word[bp+FUN_PUSH+FUN_RETF]
  mov bl,al
  mov ax,word[bp+FUN_PUSH+FUN_RETF+FUN_PAR]
  mov bh,al

  mov ax,word[bp+24] ;x
  mov cx,ax
  mov ax,word[bp+26] ;y
  mov dx,50h
  mul dx
  add ax,cx
  mov dx,02h
  mul dx
  push RAM_VIDEO/10h
  pop es
  mov si,ax
  mov ax,bx
  mov word[es:si],ax
  popa
  retf 8

;очищает экран
clear_screen:
pusha
	xor si,si
	push RAM_VIDEO/10h
	pop es
  .loop1:
	mov word[es:si],00h
	inc si
	cmp si,0fa0h
	jne .loop1
popa
  retf

;читает символ клавиатуры, возвращает сканкод и ascii
read_key:
  mov ah,00h
  int 16h
  retf

;считывает сектор по lba(!1) в адрес м(!2) и б(!3)
read_sect:
pusha
mov bp,sp
mov ax,word[bp+FUN_PUSH+FUN_RETF]
mov word[cs:.lba],ax
mov ax,word[bp+FUN_PUSH+FUN_RETF+FUN_PAR]
mov word[cs:.sad],ax
mov ax,word[bp+FUN_PUSH+FUN_RETF+(FUN_PAR*2)]
mov word[cs:.bad],ax

mov ax,word[cs:.lba]
mov bh,DISK_SECS_DISK
div bh
inc ah
mov byte[cs:.s],ah

mov ax,word[cs:.lba]
xor bx,bx
mov bl,byte[cs:.s]
dec bx
sub ax,bx
xor bx,bx
mov bl,DISK_SECS_DISK
div bl 
xor ah,ah
mov bl,DISK_HEADS_DISK
div bl
mov byte[cs:.h],ah

xor bx,bx
mov bl,byte[cs:.s]
dec bx
mov al,byte[cs:.h]
mov cl,DISK_SECS_DISK
mul cl
add bx,ax
mov ax,word[cs:.lba]
sub ax,bx
mov bx,ax
mov al,DISK_HEADS_DISK
mov cl,DISK_SECS_DISK
mul cl
mov cx,ax
mov ax,bx
div cl
mov byte[cs:.c],al

mov cl,byte[cs:.s]
mov ch,byte[cs:.c]
mov dh,byte[cs:.h]
push word[cs:.bad]
pop es
mov bx,word[cs:.sad]
mov dl,DISK_NUM_DISK
mov al,01h
mov ah,02h
int 13h
popa
retf 4

.lba dd 00h
.s db 00h
.c db 00h
.h db 00h
.sad dw 0000h
.bad dw 0000h


;записывает сектор по lba(!1) из адреса м(!2) и б(!3)
write_sect:
pusha
mov bp,sp
mov ax,word[bp+FUN_PUSH+FUN_RETF]
mov word[cs:.lba],ax
mov ax,word[bp+FUN_PUSH+FUN_RETF+FUN_PAR]
mov word[cs:.sad],ax
mov ax,word[bp+FUN_PUSH+FUN_RETF+(FUN_PAR*2)]
mov word[cs:.bad],ax

mov ax,word[cs:.lba]
mov bh,DISK_SECS_DISK
div bh
inc ah
mov byte[cs:.s],ah

mov ax,word[cs:.lba] 
xor bx,bx
mov bl,byte[cs:.s]
dec bx
sub ax,bx
xor bx,bx
mov bl,DISK_SECS_DISK
div bl 
xor ah,ah
mov bl,DISK_HEADS_DISK
div bl
mov byte[cs:.h],ah

xor bx,bx
mov bl,byte[cs:.s]
dec bx
mov al,byte[cs:.h]
mov cl,DISK_SECS_DISK
mul cl
add bx,ax
mov ax,word[cs:.lba]
sub ax,bx
mov bx,ax
mov al,DISK_HEADS_DISK
mov cl,DISK_SECS_DISK
mul cl
mov cx,ax
mov ax,bx
div cl
mov byte[cs:.c],al

mov cl,byte[cs:.s]
mov ch,byte[cs:.c]
mov dh,byte[cs:.h]
push word[cs:.bad]
pop es
mov bx,word[cs:.sad]
mov dl,DISK_NUM_DISK
mov al,01h
mov ah,03h
int 13h
popa
retf 4

.lba dd 00h
.s db 00h
.c db 00h
.h db 00h
.sad dw 0000h
.bad dw 0000h

run_program:
mov word[cs:.bad],RAM_APP/10h
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RETF]
  mov word[cs:.program_adr],ax

  push RAM_APP/10h
  push 00h
  push word[cs:.program_adr]
  call __read_sect

  .load_next_program_sect:
  push RAM_ST/10h
  pop es
  mov si,word[cs:.program_adr]
  mov ax,si
  mov bx,02h
  mul bx
  mov si,ax
  cmp word[es:si],ST_FLAG_EOF
  je .jmp_program
  mov dx,word[es:si]
  mov word[cs:.program_adr],dx
  add word[cs:.bad],RAM_SECT/10h
  push word[cs:.bad]
  push 00h
  push word[cs:.program_adr]
  call __read_sect
  jmp .load_next_program_sect

  .jmp_program:
  jmp RAM_APP/10h:0000h
	
.program_adr dw 0000h
.bad dw 0000h

exit_program:
xor si,si
  search_ft_1:
  push RAM_ST/10h
  pop es
  mov bx,[es:si]
  cmp bx,ST_FLAG_ROOT
  je read_ft_1
  add si,02h
  jmp search_ft_1

  read_ft_1:
  push si
  mov ax,si
  mov bx,02h
  xor dx,dx
  div bx
  mov si,ax
  push RAM_FT/10h
  push 00h
  push si
  call __read_sect
  xor si,si
  push RAM_FT/10h
  pop es
  search_launch:
  mov ah,[es:si]
  cmp ah,'d'
  jne next_file_1
  mov ah,[es:si+01h]
  cmp ah,'e'
  jne next_file_1
  mov ah,[es:si+02h]
  cmp ah,'s'
  jne next_file_1
  mov ah,[es:si+03h]
  cmp ah,'k'
  jne next_file_1
  mov ah,[es:si+04h]
  cmp ah,'t'
  jne next_file_1
  mov ah,[es:si+05h]
  cmp ah,'o'
  jne next_file_1
  mov ah,[es:si+06h]
  cmp ah,'p'
  jne next_file_1
  mov ah,[es:si+07h] 
  cmp ah,' '
  jne next_file_1
  mov ah,[es:si+08h]
  cmp ah,'s'
  jne next_file_1
  mov ah,[es:si+09h]
  cmp ah,'y'
  jne next_file_1
  mov ah,[es:si+0ah]
  cmp ah,'s'
  jne next_file_1
  mov dx,word[es:si+0ch]
  push dx
  call __run_program
  next_file_1:
  add si,10h
  cmp si,200h
  je nf_launch
  jmp search_launch
  
  nf_launch:
  pop si
  add si,02h
  jmp search_ft_1


times (896-($-$$)) db 00h

jmp shutdown
jmp reboot
jmp print_char
jmp clear_screen
jmp read_key
jmp read_sect
jmp write_sect
jmp run_program
jmp exit_program

times (1024-($-$$)) db 00h