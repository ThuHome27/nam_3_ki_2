; multi-segment executable file template.

data segment
    ; add your data here!
    USART_CMD Equ 002h
    USART_DATA Equ 000h
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

   
    CALL initUART
    
    LAP:               
    
    CALL DELAY 

    IN AL,USART_CMD
    
    CMP AL,0
    
    JE LAP
    ;CALL DELAY 
    MOV AL,65
    OUT USART_DATA,AL
    
            
    JMP LAP
    
             
ends 
DELAY PROC
    mov cx,10000
    L2:
    nop ;3 cycles
    loop L2; ;17 cycles
    RET
DELAY ENDP

initUART PROC
    ;Set up UART
    MOV AL,01001101b; //8E1 - /64 
    OUT USART_CMD,AL;
    MOV AL,00000111b;
    OUT USART_CMD,AL; 
    ;End Set up
    RET    
initUART ENDP

end start ; set entry point and stop the assembler.
