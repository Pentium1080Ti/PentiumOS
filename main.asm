[bits 16]
[org 0x7C00]

start:

    xor ax,ax
    mov ds,ax
    mov es,ax
    mov bx,0x8000

    mov ax,0x13 ; bios video interrupt
    int 0x10

    mov ah,02
    int 0x10 ; interrupt display

    mov ah,0x02 ; move cursor
    mov bh,0x00
    mov dh,0x06
    mov dl,0x09
    int 0x10

    mov si,start_os
    call _print_string

    mov ah,0x02
    mov bh,0x00
    mov dh,0x10
    mov dl,0x06
    int 0x10

    mov si,press_key
    call _print_green

    mov ax,0x00 ; keyboard input
    int 0x16

    mov ah,0x02
    mov al,1
    mov dl,0x80
    mov ch,0
    mov dh,0
    mov cl,2
    mov bx,_stage_two
    int 0x13 ; disk IO interrupt

    jmp _stage_two

    start_os db 'Welcome to PentiumOS',0
    press_key db 'Press any key to continue...',0
    login_label db 'Please login... (ESC to skip)',0
    login_username db 'Username:',0
    login_password db 'Password:',0
    display_text db ':)',0
    os_info db 10,'PentiumOS - 16 bit - v1.0.0',13,0
    press_key_two db 10,'Press any key to go to GUI',0
    window_text db 10,'PentiumOS GUI...',0
    main_text db 10,10, 'Hello world',0

print:
    mov ah,0x0E

.repeat_next_char:

    lodsb
    cmp al,0
    je .done_print
    int 0x10
    jmp .repeat_next_char

.done_print:
    ret

_print_string:

    mov bl,1
    mov ah,0x0E

.repeat_next_char:

    lodsb
    cmp al,0
    je .done_print
    add bl,6
    int 0x10
    jmp .repeat_next_char

.done_print:
    ret

_print_green:

    mov bl,10
    mov ah,0x0E

.repeat_next_char:

    lodsb
    cmp al, 0
    je .done_print
    int 0x10
    jmp .repeat_next_char

.done_print:
    ret

_print_white:

    mov bl,15
    mov ah, 0x0E

.repeat_next_char:

    lodsb
    cmp al, 0
    je .done_print
    int 0x10
    jmp .repeat_next_char

.done_print:

    ret

    times ((0x200 - 2) - ($ - $$)) db 0x00     ;set 512 bytes for boot sector which are necessary
    dw 0xAA55                                  ; boot signature 0xAA & 0x55

_stage_two:

    mov al,2
    mov ah,0
    int 0x10

    mov cx,0

    mov ah,0x02
    mov bh,0x00
    mov dh,0x00
    mov dl,0x00
    int 0x10

    mov si,login_label
    call print

    mov ah,0x02
    mov bh,0x00
    mov dh,0x02
    mov dl,0x00
    int 0x10

    mov si,login_username
    call print

_get_username_input:
    
    mov ax,0x00
    int 0x16

    cmp ah,0x1C ; enter
    je .exit_input
    cmp ah,0x01 ; esc
    je .exit_input

    mov ah,0x0E
    int 0x10

    inc cx
    cmp cx,5
    jbe _get_username_input
    jmp .input_done

.input_done:
    mov cx,0
    jmp _get_username_input
    ret

.exit_input:

    hlt

    mov ah,0x02
    mov bh,0x00
    mov dh,0x03
    mov dl,0x00
    int 0x10

    mov si,login_password
    call print

_get_password_input:
    
    mov ax,0x00
    int 0x16

    cmp ah,0x1C ; enter
    je .exit_input
    cmp ah,0x01 ; esc
    je .exit_input

    inc cx
    cmp cx,5
    jbe _get_password_input
    jmp .input_done

.input_done:

    mov cx,0
    jmp _get_password_input
    ret

.exit_input:

    hlt

    mov ah,0x02
    mov bh,0x00
    mov dh,0x08
    mov dl,0x12
    int 0x10

    mov si,display_text
    call print

    mov ah,0x02
    mov bh,0x00
    mov dh,0x9
    mov dl,0x10
    int 0x10

    mov si, os_info
    call print

    mov ah,0x02
    mov bh,0x00
    mov dh,0x11
    mov dl,0x11
    int 0x10

    mov si,press_key_two
    call print

    mov ah,0x00
    int 0x16

_skip_login:

    mov ah,0x03
    mov al,1
    mov dl,0x80
    mov ch,0
    mov dh,0
    mov cl,3
    mov bx,_stage_three
    int 0x13

    jmp _stage_three

_stage_three:

    mov ax,0x13
    int 0x10

    push 0x0A000 ; video memory segment
    pop es ; pop extar segments from stack
    xor di,di ; index 0
    xor ax,ax ; color register 0

    mov ax,0x02 ; green
    mov dx,0
    add di,320 ; \n
    imul di,10

    add di,10

_top_line_pixel_loop:

    mov [es:di],ax

    inc di
    inc dx
    cmp dx,300
    jbe _top_line_pixel_loop ; if <=300 jmp to _top_line_pixel_loop
    
    hlt

    xor dx,dx
    xor di,di
    add di,320
    imul di,190
    add di,10

    mov ax,0x01 ; blue

_bottom_line_pixel_loop:

    mov [es:di],ax

    inc di
    inc dx
    cmp dx,300
    jbe _bottom_line_pixel_loop

    hlt

    xor dx,dx
    xor di,di
    add di,320
    imul di,10
    add di,10

    mov ax,0x03 ; cyan

_left_line_pixel_loop:
    
    mov [es:di],ax

    inc dx
    add di,320
    cmp dx,180
    jmp _left_line_pixel_loop

    hlt

    xor dx,dx
    xor di,di
    add di,320
    imul di,27
    add di,11

    mov ax,0x06 ; orange

_right_line_pixel_loop:
    
    mov [es:di],ax

    inc dx
    add di,320
    cmp dx,180
    jmp _left_line_pixel_loop

    hlt

    xor dx,dx
    xor di,di
    add di,320
    imul di,27
    add di,11

    mov ax,0x05 ; orange

_below_line_top_line_pixel_loop:

    mov [es:di],ax

    inc di
    inc dx
    cmp dx,298
    jbe _below_line_top_line_pixel_loop

    hlt

    mov ah,0x02
    mov bh,0x00
    mov dh,0x01
    mov dl,0x02
    int 0x10

    mov si,window_text
    call print

    hlt

    mov ah,0x02
    mov bh,0x00
    mov dh,0x02
    mov dl,0x25
    int 0x10

    mov ah,0x0E
    mov al,0x58
    mov bh,0x00
    mov bl,4
    int 0x10

    hlt

    mov ah,0x02
    mov bh,0x00
    mov dh,0x02
    mov dl,0x23
    int 0x10

    mov ah,0x0E
    mov al,0x5F
    mov bh,0x00
    mov bl,9
    int 0x10

    hlt

    mov ah,0x02
    mov bh,0x00
    mov dh,0x05
    mov dl,0x09
    int 0x10

    mov si,main_text
    call print

    hlt

    mov ah,0x02
    mov bh,0x00
    mov dh,0x12
    mov dl,0x03
    int 0x10

    mov si,display_text
    call print

    hlt

    times (1024-($-$$)) db 0x00