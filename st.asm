include "./include/const.inc"

dw ST_FLAG_RES   ;0000 boot.bin
dw ST_FLAG_RES   ;0001 st.bin
dw ST_FLAG_ROOT  ;0002 root.bin
dw 0004h         ;0003 kernel.bin
dw ST_FLAG_EOF   ;0004
dw 0006h         ;0005 desktop.bin
dw ST_FLAG_EOF   ;0006 
dw 0008h         ;0007 hello.bin
dw 0009h         ;0008 
dw ST_FLAG_EOF   ;0009
dw 000bh         ;000a rekun.bin
dw ST_FLAG_EOF   ;000b
dw 000dh         ;000c penpad.bin
dw ST_FLAG_EOF   ;000d
dw 000fh	 ;000e smile.bin
dw ST_FLAG_EOF   ;000f 
dw 0011h         ;0010 bone.bin
dw ST_FLAG_EOF   ;0011
dw ST_FLAG_EOF   ;0012 about.bin
dw ST_FLAG_EOF   ;0013 joke.bin
dw 00015h        ;0014 fileman.bin 
dw ST_FLAG_EOF   ;0015
dw 00017h        ;0016 test.bin
dw 00018h        ;0017 
dw ST_FLAG_EOF   ;0018
times ((512-($-$$))/2) dw ST_FLAG_FREE
