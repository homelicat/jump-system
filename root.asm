use16
format binary
db "kernel  ","sys",00h,03h,00h,00h,00h
db "desktop ","sys",00h,05h,00h,00h,00h
db "hello   ","app",00h,07h,00h,00h,00h
db "rekun   ","app",00h,0ah,00h,00h,00h
db "penpad  ","app",00h,0ch,00h,00h,00h
db "smile   ","rap",00h,0eh,00h,00h,00h
db "bone    ","rap",00h,10h,00h,00h,00h
db "about   ","txt",00h,12h,00h,00h,00h
db "joke    ","txt",00h,13h,00h,00h,00h
db "fileman ","app",00h,14h,00h,00h,00h
db "test    ","app",00h,16h,00h,00h,00h

times (512-($-$$)) db 00h
