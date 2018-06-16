use16
include "./include/kernel.inc"
include "./include/const.inc"

;записывает файловую запись (адрес (!1)) в файловую запись (!2) (отсчет от единицы)
iofiles_write_file_adr:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RETF]
mov word[cs:.data],ax
jmp $
mov ax,[bp+FUN_PUSH+FUN_RETF+(FUN_PAR*(2-1))]
mov word[cs:.adr],ax

mov ax,[cs:.adr]
dec ax
mov bx,10h
xor dx,dx
mul bx
mov si,ax
add si,0bh
push RAM_FT/10h
pop es
mov ax,word[cs:.data]
mov word[es:si],ax
popa
retf 4

.data dw 0000h
.adr dw 0000h

;считывает таблицу секторов по адресу(!1)
iofiles_read_st:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.adr],ax

push RAM_ST
push 00h
push word[cs:.adr]
call __read_sect

.return:
popa
ret 2

.adr dw 00h

;считывает таблицу файлов по адресу(!1)
iofiles_read_ft:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.adr],ax

push RAM_FT
push 00h
push word[cs:.adr]
call __read_sect

.return:
popa
ret 2

.adr dw 00h

;записывает таблицу секторов по адресу(!1)
iofiles_write_st:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.adr],ax

push RAM_ST
push 00h
push word[cs:.adr]
call __write_sect

.return:
popa
ret 2

.adr dw 00h

;записывает таблицу файлов по адресу(!1)
iofiles_write_ft:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.adr],ax

push RAM_FT
push 00h
push word[cs:.adr]
call __write_sect

.return:
popa
ret 2

.adr dw 00h



;считывает файл по адресу(!1) в адрес б(!2)
iofiles_read_file:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.file_adr],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(2-1))]
mov word[cs:.ars],ax

push word[cs:.ars]
push word[cs:.file_adr]
call __read_sect

.next_sect:
push RAM_ST/10h
pop es
mov si,word[cs:.file_adr]
mov ax,si
mov bx,02h
mul bx
mov si,ax
cmp word[es:si],ST_FLAG_EOF
je .return
mov dx,word[es:si]
mov word[cs:.file_adr],dx
add word[cs:.ars],RAM_SECT
push word[cs:.ars]
push word[cs:.file_adr]
call __read_sect
jmp .next_sect

.return:
popa
ret 4

.file_adr dw 00h
.ars dw 00h

;==================================
;ищет файл по имени м(!1) и б(!2), возвращает номер (от единицы) файловой записи, если не находит возвращает NULL
iofiles_search_file_note:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.m],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(2-1))]
mov word[cs:.b],ax

xor si,si

push word[cs:.b]
pop es
push RAM_FT/10h
pop ds

.search_f:
cld
mov dx,si
mov di,word[cs:.m]
mov cx,0bh
repe cmpsb
je .return
jne .next_file

.next_file:
mov ax,si
mov bx,10h
xor dx,dx
div bx
mov cx,10h
sub cx,dx
add si,cx
cmp si,200h
je .return_not
jmp .search_f

.return:
mov ax,dx
mov bx,10h
xor dx,dx
div bx
mov word[cs:.ret],ax
popa
mov ax,word[cs:.ret]
inc ax

ret 4

.return_not:
popa
mov ax,NULL
ret 4

.m dw 00h
.b dw 00h
.lba dw 00h
.ars dw 00h
.ret dw 00h

;=====================================================
;записывает файловую запись (имя и расширение в формате 8:3 в строке м(!1) и б(!2)) в файловую таблицу
iofiles_write_file_note:
pusha
mov bp,sp
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(1-1))]
mov word[cs:.m],ax
mov ax,[bp+FUN_PUSH+FUN_RET+(FUN_PAR*(2-1))]
mov word[cs:.b],ax

push RAM_FT/10h
pop es
mov si,00h
.search_free_file_note:
cmp byte[es:si],00h
je .write
add si,10h
cmp si,200h
je .return_null
jmp .search_free_file_note

.write:
push word[cs:.b]
pop ds
mov di,word[cs:.m]
mov cx,11
.loop1:
mov al,byte[ds:di]
mov byte[es:si],al
dec cx
inc si
inc di
cmp cx,00h
je .write_nulls
jmp .loop1

.write_nulls:
mov cx,5
.loop2:
mov byte[ds:di],00h
dec cx
inc si
inc di
cmp cx,00h
je .return_true
jmp .loop2

.return_null:
popa
mov ax,NULL
ret 4

.return_true:
popa
mov ax,TRUE
ret 4

.m dw 0000h
.b dw 0000h


