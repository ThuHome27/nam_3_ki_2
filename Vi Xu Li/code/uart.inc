USART_CMD  Equ 2
USART_DATA Equ 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; USART ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
USART_Init:
    ;Set up UART
    mov al, 7Dh
    out USART_CMD, al
    mov al, 7h
    out USART_CMD, al
    ret

; Read a byte form USART to AL
USART_Read:
RL1:
    in al, USART_CMD
    test al, 2
    JE RL1
    in al, USART_DATA
    shr al, 1
    ret

; Write a byte from al to USART
USART_Write:
    push bx
    mov bl, al
WL1:
    in al, USART_CMD
    test al, 1
    JE WL1
    mov al, bl
    out USART_DATA, al
    pop bx
    ret

; Write a Sring to USART
USART_Write_Str:
swloop:
    lodsb
    or al, al
    je swdone
    call USART_Write
    jmp swloop
swdone:
    ret

; Write a hex from al to USART
USART_Write_Hex:
    push bx
    push cx

    mov cx, 2
whloop:
    push cx
    push ax
    mov cl, 4
    shr ax, cl
    and ax, 0Fh
    mov bx, offset hex_val
    add bx, ax
    mov al, byte ptr [bx]

    ; Print char
    call USART_Write

    pop ax
    mov cx, 4
    shl ax, cl
    pop cx
    
    loop whloop		; loop until 0 terminated found
whdone:
    pop cx
    pop bx
    ret
