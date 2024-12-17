dataseg segment
    str1 db 101, ?, 101 dup('$')
    endl db 13, 10, '$'
    cnt_lc dw 0
    cnt_uc dw 0
    cnt_num dw 0
dataseg ends



stkseg segment

stkseg ends



codeseg segment

    assume cs:codeseg, ds:dataseg, ss:stkseg

start:

    mov ax, dataseg
    mov ds, ax


; input str1
    mov   dx, offset str1
    mov   ah, 0ah
    int   21h


; get length and initialize
    mov ax, offset str1
    add ax, 1
    mov ch, 0
    mov bx, ax
    mov cl, [bx]
    add bx, 1


enum_str:
    cmp byte ptr [bx], 122
    jle le122
    jmp skip
le122:
    cmp byte ptr [bx], 96
    jle le96
                        ; lowercase
    add cnt_lc, 1 
    jmp skip
le96:
    cmp byte ptr [bx], 90
    jle le90
    jmp skip
le90:
    cmp byte ptr [bx], 64
    jle le64
                        ; uppercase
    add cnt_uc, 1
    jmp skip
le64:
    cmp byte ptr [bx], 57
    jle le57
    jmp skip
le57:
    cmp byte ptr [bx], 47
    jle le47
                        ; number
    add cnt_num, 1
    jmp skip
le47:
    jmp skip
skip:
    add bx, 1
    loop enum_str

    

; output lowercase

    mov cx, 0
cnt_lc_nxt_digit:
    mov bx, 10
    mov ax, cnt_lc
    mov dx, 0
    div bx
    mov cnt_lc, ax
    add dl, 48
    push dx
    add cx, 1
    cmp byte ptr cnt_lc, 0
    jnz cnt_lc_nxt_digit


print_cnt_lc:
    pop dx
    mov ah, 02h
    int 21h
    loop print_cnt_lc
    mov dx, offset endl
    mov ah, 09h
    int 21h


    mov cx, 0
cnt_uc_nxt_digit:
    mov bx, 10
    mov ax, cnt_uc
    mov dx, 0
    div bx
    mov cnt_uc, ax
    add dl, 48
    push dx
    add cx, 1
    cmp byte ptr cnt_uc, 0
    jnz cnt_uc_nxt_digit


print_cnt_uc:
    pop dx
    mov ah, 02h
    int 21h
    loop print_cnt_uc
    mov dx, offset endl
    mov ah, 09h
    int 21h


    mov cx, 0
cnt_num_nxt_digit:
    mov bx, 10
    mov ax, cnt_num
    mov dx, 0
    div bx
    mov cnt_num, ax
    add dl, 48
    push dx
    add cx, 1
    cmp byte ptr cnt_num, 0
    jnz cnt_num_nxt_digit


print_cnt_num:
    pop dx
    mov ah, 02h
    int 21h
    loop print_cnt_num


    mov ah, 4cH
    int 21h
codeseg ends
end start

