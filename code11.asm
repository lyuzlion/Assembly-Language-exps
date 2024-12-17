dataseg segment
    n db 0
    phone db 25 dup(15, 0, 15 dup('$'))
    mingzi db 25 dup(15, 0, 15 dup('$'))
    endl db 13, 10, '$'

    tmp1 dw 0
    tmp2 db 0
    tmp3 dw 0
    tmp4 dw 0
    tmp5 dw 0
    tmp6 db 0

    tmp7 db 15, 0, 15 dup('$')
    tmp8 db 1
    tmp9 db 1

    str1 db 'Input name:$'
    str2 db 'Input a telephone number:$'
    str3 db 'Do you want a telephone number?(Y/N)$'
    str4 db 'name                tel.$'
    str5 db 'name?$'
dataseg ends

stkseg segment 

stkseg ends

codeseg segment

    assume cs:codeseg, ds:dataseg, ss:stkseg
start:

    mov ax, dataseg
    mov ds, ax
    mov es, ax


input_n:
    mov ah, 01h         ; 读入的字符放到al
    int 21h

    ;mov dl, al          ;
    ;mov ah, 02h         ; 
    ;int 21h             ; 打印输入的字符

    cmp al, 13          ; 
    je input_endl


    sub al, 48
    mov bl, al
    mov al, 10
    mul n
    add al, bl
    mov n, al           ; 乘10并加末位


    ;mov dl, bl
    ;add dl, 48
    ;mov ah, 02h
    ;int 21h


    jmp input_n
input_endl:

    ;mov ah, 0
    ;mov al, n
    ;mov bl, 10
    ;div bl
    ;mov dl, ah
    ;add dl, 48
    ;mov ah, 02h
    ;int 21h




    mov ch, 0
    mov cl, n

    mov bl, 0               ;用来记录当前是第几个字符串
insert_phone_and_mingzi:
;    mov dx, offset endl     ;输出换行
;    mov ah, 09h
;    int 21h
    mov dx, offset str1     ;输出名字提示
    mov ah, 09h
    int 21h


    mov dx, offset mingzi
    mov ah, 0
    mov al, 17
    mul bl                  ;bl * 17, 放在ax里
    add dx, ax              ;offset + ax, 得到正在遍历的字符串的首地址，放到dx里

    mov ah, 0ah             ;读入第bl个名字
    int 21h

    ;mov bx, dx             ; 用于打印第二个字符
    ;mov dl, [bx + 3]
    ;mov ah, 02h
    ;int 21h

    mov dx, offset endl     ;输出换行
    mov ah, 09h
    int 21h
    mov dx, offset str2     ;输出电话提示
    mov ah, 09h
    int 21h

    mov dx, offset phone   ;
    mov ah, 0
    mov al, 17
    mul bl                  ;bl * 17，放到ax里
    add dx, ax              ;加上偏移量，得到正在遍历的字符串的首地址，放到d里

    mov ah, 0ah             ;读入第bl个电话
    int 21h

    mov dx, offset endl     ;输出换行
    mov ah, 09h
    int 21h

    inc bl                  ;下一个字符
    loop insert_phone_and_mingzi


    mov ch, 0
    mov cl, n
    dec cx                  ;冒泡排序，n-1轮

    cmp cx, 0
    je skip_sort


bubble_sort_outer_loop:
    push cx            ;tmp1暂存cx
    mov ch, 0
    mov cl, n
    dec cl
bubble_sort_inner_loop:     ;这里我倒着往前冒泡，最后一个数会比较n-1次，以此类推
    mov tmp2, cl            ;tmp2暂存cl
    
    mov bx, offset mingzi
    add bx, 2

    mov al, cl    
    mov dl, 17
    mul dl                  ;al * dl，因为ax存的是tmp2，tmp2存的是cx，不会超过20，所以ah不会用到

    add bx, ax              ;mingzi加上偏移量，得到当前字符串的首地址
    mov di, bx                          ;s[i]

    sub bx, 17                          ;s[i-1]
    mov si, bx              ;减去17，得到上一个字符的首地址

    mov dl, [si - 1]                          ;做12次比较
    mov tmp8, dl
    mov cl, dl

    mov dl, [di - 1]                          ;做12次比较
    mov tmp9, dl
    cmp cl, dl
    jl comp
    mov cl, dl
comp:
    repz cmpsb              ;返回si代表的字符串-di代表的字符串的字典序

    jl skip_swap            ;si < di说明要不交换，因为si是前面的，di是后面的
    jg begin_swap            ;si < di说明要不交换，因为si是前面的，di是后面的
    

    mov dh, tmp8
    cmp dh, dl

;    add dl, 48
;    mov ah, 02H
;    int 21h
    

    jl skip_swap

begin_swap:        
    mov cx, 14              ;开始交换，连同前两个字节也交换

exe_swap_mingzi:
    mov al, [bx - 2]            ;现在bx里存的是前一个字符串的首地址，放到al里
    mov ah, [bx - 2 + 17]       ;现在bx+17里存的是当前字符串的首地址，放到ah里
    mov [bx - 2], ah            ;交换
    mov [bx - 2 + 17], al       ;交换
    inc bx
    loop exe_swap_mingzi

    mov bx, offset phone

    mov ah, 0
    mov al, tmp2    
    mov dl, 17              ;al 变成 tmp2
    mul dl                  ;al * dl，因为ax存的是tmp2，tmp2存的是cx，不会超过20，所以ah不会用到    

    add bx, ax
    mov cl, 14
exe_swap_phone:
    mov al, [bx - 17]            ;现在bx里存的是前一个字符串的首地址，放到al里
    mov ah, [bx]       ;现在bx+17里存的是当前字符串的首地址，放到ah里
    mov [bx - 17], ah            ;交换
    mov [bx], al       ;交换
    inc bx
    loop exe_swap_phone

skip_swap:                  ;交换结束，要恢复cx
    mov cl, tmp2
    loop bubble_sort_inner_loop

    pop cx              ;恢复cx
    loop bubble_sort_outer_loop


skip_sort:

    mov dx, offset str3     ;输出提示Do you want a telephone number?(Y/N)
    mov ah, 09h
    int 21h

    mov dx, offset endl     ;输出换行
    mov ah, 09h
    int 21h

    mov ah, 01h             ;读入的字符放到al
    int 21h
    cmp al, 'Y'             ;如果是Y的话进入查询

    je query
    jmp eop
    


query:

    mov dx, offset str5     ;输出name?
    mov ah, 09h
    int 21h

    

input_query:
    mov dx, offset tmp7
    mov ah, 0ah
    int 21h                 ;读入的字符放到al



search:

    ; mov dx, offset endl     ;输出换行
    ; mov ah, 09h
    ; int 21h
    
    mov ch, 0
    mov cl, n

    mov di, offset tmp7

    mov dl, [di + 1]
    mov tmp6, dl            ;tmp6里存的是读入长度

query_enum:

;    mov dx, offset endl
;    mov ah, 09h
;    int 21h


    mov si, offset tmp7            ;si里存tmp7的首地址
    add si, 2
    mov di, offset mingzi   
    add di, 2

    mov dx, 17
    mov ax, cx              ;
    dec ax                  ;
    mul dl                  ;dl*al放在ax里，得到当前枚举的字符串的首地址

    add di, ax              ;di存当前枚举的字符串的首地址


    mov al, tmp6 
    cmp al, [di - 1]
    jnz retry

 
    mov tmp1, cx
    mov ch, 0
    mov cl, tmp6
    repz cmpsb              ;比较字符串是否相等
    mov cx, tmp1


    jz found
retry:
    loop query_enum

    mov dx, offset endl     ;输出换行
    mov ah, 09h
    int 21h

    jmp skip_sort
found:

    mov di, offset mingzi
    add di, 2

    mov dx, 17
    mov ax, cx
    dec ax
    mul dl                  ;dl*al放在ax里

    add di, ax

    mov dx, offset endl     ;输出换行
    mov ah, 09h
    int 21h

    mov dx, offset str4     ;输出提示 name    tel
    mov ah, 09h
    int 21h

    mov dx, offset endl     ;输出换行
    mov ah, 09h
    int 21h

    push di
    mov dx, di
    mov al, [di - 1]
    mov ah, 0
    add di, ax
    mov byte ptr [di], '$'
    mov ah, 09h             ;输出name
    int 21h
    pop di    


    push cx

    mov cx, 20
    mov dh, 0
    mov dl, [di - 1]
    sub cx, dx

output_space:
    mov dl, ' '
    mov ah, 02h
    int 21h
    loop output_space

    pop cx


    sub di, offset mingzi
    add di, offset phone

    mov dx, di
    mov ah, 09h
    int 21h


    ; mov dx, offset endl     ;输出换行
    ; mov ah, 09h
    ; int 21h

    jmp skip_sort


eop:

    mov ch, 0
    mov cl, n
    mov si, offset mingzi    ;
    add si, 2


print_all:
    mov bx, si

    mov al, [si - 1]
    mov ah, 0
    add bx, ax
    mov byte ptr [bx], '$'
    mov dx, si
    mov ah, 09h
    int 21h

    
    push cx

    mov cx, 20
    mov dh, 0
    mov dl, [si - 1]
    sub cx, dx

output_space2:
    mov dl, ' '
    mov ah, 02h
    int 21h
    loop output_space2

    pop cx

    mov di, si
    sub di, offset mingzi
    add di, offset phone

    mov dx, di
    mov ah, 09h
    int 21h

    ; mov dx, offset endl
    ; mov ah, 09h
    ; int 21h

    add si, 17
    loop print_all

    mov ah, 4ch
    int 21h

dbg:

    mov ah, 02h
    mov dl, 'T'
    int 21h
    mov ah, 4ch
    int 21h


codeseg ends
end start
