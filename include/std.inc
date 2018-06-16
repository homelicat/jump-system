; Библиотека
; Автор: Hmundik
;
; Функции: 
;
; преобразует число(!1) в строку м(ret)
; std_word_to_str:
;
; проверяет(ret) строку м(!1) б(!2) на число
; std_cmp_str_num
;
; преобразует строку м(!1) б(!2) в число(ret)
; std_str_to_word
;
; выводит на экран строку по адресу м(!1) б(!2) цветом(!3) на x(!4) и y(!5)
; std_print_string
;
; копирует строку из адреса м(!1) б(!2) в адрес м(!3) б(!4)
; std_cp_string
;
; сравнивает(ret) строки м(!1) б(!2) м(!3) б(!4)
; std_cmp_string
;
; считает кол-во символов(ret) в строке по адресу м(!1) б(!2)
; std_count_char_string
;
; считывает строку с клавиатуры в адрес м(!1) б(!2) по курсору x(!3) и y(!4) цветом (!5) размером без учета нуля (!6)
; std_read_str

use16
include "./include/kernel.inc"
include "./include/const.inc"

;считывает строку с клавиатуры в адрес м(!1) б(!2) по курсору x(!3) и y(!4) цветом (!5) размером без учета нуля (!6)
std_read_str:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.m],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(2-1))]
mov word[cs:.b],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(3-1))]
mov word[cs:.x],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(4-1))]
mov word[cs:.y],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(5-1))]
mov word[cs:.c],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(6-1))]
mov word[cs:.i],ax

.loop1:
call __read_key

cmp ah,KB_ENTER
je .return

cmp ah,KB_BACKSPACE
je .back

cmp ah,KB_SPACE
je .space

push word[cs:.b]
pop es
mov si,word[cs:.m]
mov byte[es:si],al

push word[cs:.y]
push word[cs:.x]
push word[cs:.c]
mov ah,00h
push ax
call __print_char
inc word[cs:.n]
inc word[cs:.m]
inc word[cs:.x]
mov bx,word[cs:.i]
cmp word[cs:.n],bx
je .return
jmp .loop1

.back:
cmp word[cs:.n],0
je .loop1
dec word[cs:.n]
dec word[cs:.m]
dec word[cs:.x]
push word[cs:.b]
pop es
mov si,word[cs:.m]
mov byte[es:si],00

push word[cs:.y]
push word[cs:.x]
push word[cs:.c]
push ' '
call __print_char
jmp .loop1

.space:
push word[cs:.b]
pop es
mov si,word[cs:.m]
mov byte[es:si],' '

push word[cs:.y]
push word[cs:.x]
push word[cs:.c]
push ' '
call __print_char
inc word[cs:.n]
inc word[cs:.m]
inc word[cs:.x]
mov bx,word[cs:.i]
cmp word[cs:.n],bx
je .return
jmp .loop1

.return:
push word[cs:.b]
pop es
mov si,word[cs:.m]
mov byte[es:si],00
popa
ret 12

.m dw 00h
.b dw 00h
.x dw 00h
.y dw 00h
.n dw 00h
.c dw 00h
.i dw 00h

;преобразует число(!1) в строку м(ret)
std_word_to_str:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.num],ax

push cs
push .str
push cs
push .prot
call std_cp_string

push cs
pop es
mov si,.str
.loop1:
xor dx,dx
mov ax,word[cs:.num]
mov bx,word[cs:.diver]
div bx
add ax,30h
mov word[cs:.num],dx
mov byte[es:si],al
inc si
inc word[cs:.count]
cmp word[cs:.count],05h
je .return
mov ax,word[cs:.diver]
mov bx,0ah
xor dx,dx
div bx
mov word[cs:.diver],ax
jmp .loop1

.return:
popa
mov ax,.str
ret 2

.str rb 06h
.prot db '00000',00h
.num dw 0000h
.count dw 0000h
.diver dw 2710h


;===================================================================


;проверяет(ret) строку м(!1) б(!2) на число
std_cmp_str_num:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.mad],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(2-1))]
mov word[cs:.bad],ax

push cs
push .str
push cs
push .prot
call std_cp_string

push word[cs:.bad]
push word[cs:.mad]
call std_count_char_string

cmp ax,06
ja .return_false

mov bx,06h
sub bx,ax

mov ax,.str
add ax,bx
push cs
push ax
push word[cs:.bad]
push word[cs:.mad]
call std_cp_string

xor ax,ax
push cs
pop es
mov si,.str
dec si
.loop1:
inc ax
inc si
cmp ax,06h
je .return_true
cmp byte[es:si],30h
jb .return_false
cmp byte[es:si],39h
ja .return_false
jmp .loop1

.return_false:
popa
mov ax,FALSE
ret 4

.return_true:
popa
mov ax,TRUE
ret 4


.bad dw 0000h
.mad dw 0000h
.str rb 06h
.prot db '00000',00h

;преобразует строку м(!1) б(!2) в число(ret)
std_str_to_word:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.mad],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(2-1))]
mov word[cs:.bad],ax

push word[cs:.bad]
push word[cs:.mad]
call std_cmp_str_num

cmp ax,FALSE
je .return

push cs
push .str
push cs
push .prot
call std_cp_string

push word[cs:.bad]
push word[cs:.mad]
call std_count_char_string

mov bx,06h
sub bx,ax

mov ax,.str
add ax,bx
push cs
push ax
push word[cs:.bad]
push word[cs:.mad]
call std_cp_string

push cs
pop es
mov si,.str
.loop1:
xor ax,ax
mov al,byte[es:si]
sub al,30h
mov bx,word[cs:.diver]
mul bx
cmp dx,00
jne .return
add word[cs:.num],ax
mov ax,word[cs:.diver]
xor dx,dx
mov bx,0ah
div bx
mov word[cs:.diver],ax
inc word[cs:.count]
cmp word[cs:.count],05h
inc si
je .return
jmp .loop1

.return:
popa
mov ax,word[cs:.num]
ret 4

.bad dw 0000h
.mad dw 0000h
.str rb 06h
.prot db '00000',00h
.num dw 0000h
.count dw 0000h
.diver dw 2710h

;выводит на экран строку по адресу м(!1) б(!2) цветом(!3) на x(!4) и y(!5)
std_print_string:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.mad],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(2-1))]
mov word[cs:.bad],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(3-1))]
mov word[cs:.color],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(4-1))]
mov word[cs:.x],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(5-1))]
mov word[cs:.y],ax

mov si,word[cs:.mad]
mov ax,word[cs:.x]
.next_char:
push word[cs:.bad]
pop es
cmp byte[es:si],00
je .return
push word[cs:.y]
push ax
push word[cs:.color]
push word[es:si]
call __print_char
inc si
inc ax
jmp .next_char

.return:
popa
ret 10

.bad dw 0000h
.mad dw 0000h
.color dw 0000h
.x dw 0000h
.y dw 0000h

;копирует строку из адреса м(!1) б(!2) в адрес м(!3) б(!4)
std_cp_string:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.imad],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(2-1))]
mov word[cs:.ibad],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(3-1))]
mov word[cs:.omad],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(4-1))]
mov word[cs:.obad],ax

push word[cs:.ibad]
push word[cs:.imad]
call std_count_char_string

push word[cs:.ibad]
pop ds
push word[cs:.obad]
pop es
mov si,word[cs:.imad]
mov di,word[cs:.omad]
cld 
mov cx,ax
repe movsb

.return:
popa
ret 8

.imad dw 0000h
.ibad dw 0000h
.omad dw 0000h
.obad dw 0000h

;сравнивает(ret) строки м(!1) б(!2) м(!3) б(!4)
std_cmp_string:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.amad],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(2-1))]
mov word[cs:.abad],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(3-1))]
mov word[cs:.bmad],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(4-1))]
mov word[cs:.bbad],ax

push word[cs:.abad]
push word[cs:.amad]
call std_count_char_string

mov bx,ax

push word[cs:.bbad]
push word[cs:.bmad]
call std_count_char_string

cmp ax,bx
je .cont
jne .return_false

.cont:
push word[cs:.abad]
pop es
push word[cs:.bbad]
pop ds

mov di,word[cs:.amad]
mov si,word[cs:.bmad]

cld
mov cx,ax
repe cmpsb
je .return_true

.return_false:
popa
mov ax,FALSE
ret 8

.return_true:
popa
mov ax,TRUE
ret 8

.amad dw 0000h
.abad dw 0000h
.bmad dw 0000h
.bbad dw 0000h

;считает кол-во символов(ret) в строке по адресу м(!1) б(!2)
std_count_char_string:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.mad],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(2-1))]
mov word[cs:.bad],ax

push word[cs:.bad]
pop es
mov si,word[cs:.mad]
mov word[cs:.count],0000h
.next_char:
cmp byte[es:si],00
je .return
inc si
inc word[cs:.count]
jne .next_char

.return:
popa
mov ax,word[cs:.count]
inc ax
ret 4

.mad dw 0000h
.bad dw 0000h
.count dw 0000h