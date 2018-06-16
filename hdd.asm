use16
format binary
file "boot.bin"
file "st.bin"
file "root.bin"
file "./files/kernel.bin"
file "./files/desktop.bin"
file "./files/hello.bin"
file "./files/rekun.bin"
file "./files/penpad.bin"
file "./files/smile.bin"
file "./files/bone.bin"
file "./files/about.bin"
file "./files/joke.bin"
file "./files/fileman.bin"
file "./files/test.bin"
times (16384-($-$$)) db 00h
