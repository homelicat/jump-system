;Константы для программирования
TRUE equ 0001h
FALSE equ 0ffffh
NULL equ 0000h

;Константы для функций
FUN_RET equ 2
FUN_RETF equ 4
FUN_PUSH equ 8*2
FUN_PAR equ 2

;Константы адресов
RAM_APP equ 0d00h
RAM_STACK equ 9000h
RAM_KERNEL equ 0500h
RAM_ST equ 0900h
RAM_FT equ 0b00h
RAM_SECT equ 200h
RAM_VIDEO equ 0b8000h

; Константы файловой системы
ST_FLAG_NULL equ 0f0h
ST_FLAG_FREE equ 0f1h
ST_FLAG_RES equ 0f2h
ST_FLAG_EOF equ 0f3h
ST_FLAG_FT equ 0f4h
ST_FLAG_ROOT equ 0f5h

; Дисковые константы
DISK_HEADS_DISK equ 0fh
DISK_CYLS_DISK equ 00h
DISK_SECS_DISK equ 3fh
DISK_NUM_DISK equ 80h

; Константы клавиатуры
KB_ESC equ 01h
KB_ENTER equ 1ch
KB_UP equ 48h
KB_DOWN equ 50h
KB_LEFT equ 4bh
KB_RIGHT equ 4dh
KB_DELETE equ 53h
KB_BACKSPACE equ 0eh
KB_SPACE equ 39h
KB_TAB equ 0fh

; Константы цветов консоли

COLOR_BLACK_T equ 00h
COLOR_BLUE_T equ 01h
COLOR_GREEN_T equ 02h
COLOR_CYAN_T equ 03h
COLOR_RED_T equ 04h
COLOR_MAGENTA_T equ 05h
COLOR_ORANGE_T equ 06h
COLOR_LGREY_T equ 07h
COLOR_DGREY_T equ 08h
COLOR_LBLUE_T equ 09h
COLOR_LGREEN_T equ 0ah
COLOR_LCYAN_T equ 0bh
COLOR_LREAD_T equ 0ch
COLOR_LMAGENTA_T equ 0dh
COLOR_YELLOW_T equ 0eh
COLOR_WHITE_T equ 0fh
COLOR_BLACK_B equ 00h
COLOR_BLUE_B equ 010h
COLOR_GREEN_B equ 020h
COLOR_CYAN_B equ 030h
COLOR_RED_B equ 040h
COLOR_MAGENTA_B equ 050h
COLOR_ORANGE_B equ 060h
COLOR_LGREY_B equ 070h
COLOR_DGREY_B equ 080h
COLOR_LBLUE_B equ 090h
COLOR_LGREEN_B equ 0a0h
COLOR_LCYAN_B equ 0b0h
COLOR_LREAD_B equ 0c0h
COLOR_LMAGENTA_B equ 0d0h
COLOR_YELLOW_B equ 0e0h
COLOR_WHITE_B equ 0f0h
