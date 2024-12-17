dataseg segment
    endl db 13, 10, '$'
dataseg ends

stkseg segment

stkseg ends

codeseg segment
    assume cs:codeseg, ds:dataseg, ss:stkseg
start:

    mov ax, dataseg
    mov ds, ax

    mov cx, 15
    mov dl, 10H

out_loop:
    mov bx, cx
    mov cx, 16
in_loop:
    mov ah, 02h
    int 21h
    inc dl

    mov si, dx
    mov dl, 0
    mov ah, 02h
    int 21h
    mov dx, si

    loop in_loop

    mov cx, bx

    mov si, dx

    mov dx, offset endl
    mov ah, 09h
    int 21h

    mov dx, si

    loop out_loop

    mov ah, 4cH
    int 21h
codeseg ends
end start
