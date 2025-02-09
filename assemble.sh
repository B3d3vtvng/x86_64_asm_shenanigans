#Only works on macOS

nasm -f macho64 -o "$1.o" "$1.asm" || exit 1
clang -Wl,-w -o "$1.out" "$1.o" -arch x86_64 -e _start || exit 1
arch -x86_64 ./$1.out
echo "\n\n[Process terminated with exit code $?]"

exit 0