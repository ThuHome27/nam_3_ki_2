name "mycode"   ; output file name (max 8 chars for DOS compatibility)

.model small

org  100h	; set location counter to 100h
.data  
USART_CMD Equ 002h
USART_DATA Equ 000h
.code
START:
MAIN PROC   
    
    ;Set up UART
    MOV AL,01001101b; //8E1 - /64 
    OUT USART_CMD,AL;
    MOV AL,00000111b;
    OUT USART_CMD,AL; 
    ;End Set up
   
LAP:               
    
   ; CALL DELAY 
    mov cx,10000
    L2:
    nop ;3 cycles
    loop L2; ;17 cycles
    
    MOV AL,65
    OUT USART_DATA,AL
            
    JMP LAP
    RET 
MAIN ENDP  

DELAY PROC 
    mov cx,100
    l1:
    nop ;3 cycles
    loop l1; ;17 cycles
    JMP LAP
DELAY ENDP  

END START






