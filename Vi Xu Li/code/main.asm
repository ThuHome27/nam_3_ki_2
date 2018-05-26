.model small

.8086
.Stack 100h
.Data
Hello db '        MidTerm By Van Linh', 0Dh, '  Type String And Hit Enter To Get MD5', 0Dh, 0
hex_val db '0123456789ABCDEF'

; r xac dinh so dich chuyen moi vong
r  db 7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22  ; round0
   db 5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20  ; round1
   db 4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23  ; round2
   db 6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21  ; round3

; Hang so
k  dd 0d76aa478h, 0e8c7b756h, 0242070dbh, 0c1bdceeeh, 0f57c0fafh, 04787c62ah, 0a8304613h, 0fd469501h, 0698098d8h, 08b44f7afh, 0ffff5bb1h, 0895cd7beh, 06b901122h, 0fd987193h, 0a679438eh, 049b40821h
   dd 0f61e2562h, 0c040b340h, 0265e5a51h, 0e9b6c7aah, 0d62f105dh, 02441453h, 0d8a1e681h, 0e7d3fbc8h, 021e1cde6h, 0c33707d6h, 0f4d50d87h, 0455a14edh, 0a9e3e905h, 0fcefa3f8h, 0676f02d9h, 08d2a4c8ah
   dd 0fffa3942h, 08771f681h, 06d9d6122h, 0fde5380ch, 0a4beea44h, 04bdecfa9h, 0f6bb4b60h, 0bebfbc70h, 0289b7ec6h, 0eaa127fah, 0d4ef3085h, 04881d05h, 0d9d4d039h, 0e6db99e5h, 01fa27cf8h, 0c4ac5665h
   dd 0f4292244h, 0432aff97h, 0ab9423a7h, 0fc93a039h, 0655b59c3h, 08f0ccc92h, 0ffeff47dh, 085845dd1h, 06fa87e4fh, 0fe2ce6e0h, 0a3014314h, 04e0811a1h, 0f7537e82h, 0bd3af235h, 02ad7d2bbh, 0eb86d391h

; Md5 hash here
hash db 16 dup(0) ; 128 bits

; Temp buff of Md5
mBuff db 64 dup(0)

; Temp Buff Offset of Md5
mOff dw 0

; Temp Bit Count
mCount dq  0

padding db 80h, 127 dup(0)

cCount db 8 dup(0)

; Temp buff
mmBuffMax equ 128

mmBuff db mmBuffMax dup(0)
mmSize dw 0

OutChar db 0Dh, 'The String overSize!', 0Dh, 0

.Code
start:
    mov ax, @Data
    mov ds, ax
    mov es, ax
    jmp main

; %include uart.inc
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





; %include md5.inc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; MD5 ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init md5 to run
md5_init:
	; khoi tao bien
	; var int h0:= 0x67452301
	mov word ptr [hash], 2301h
	mov word ptr [hash+2], 6745h
	; var int h1:= 0xEFCDAB89
	mov word ptr [hash+4], 0AB89h
	mov word ptr [hash+6], 0EFCDh
	; var int h2:= 0x98BADCFE
	mov word ptr [hash+8], 0DCFEh
	mov word ptr [hash+10], 98BAh
	; var int h3:= 0x10325476
	mov word ptr [hash+12], 5476h
	mov word ptr [hash+14], 1032h
	; off = 0
	mov word ptr [mOff], 0
	; count = 0
	mov word ptr [mCount], 0
	mov word ptr [mCount+2], 0
	mov word ptr [mCount+4], 0
	mov word ptr [mCount+6], 0
	ret

; md5 transform
;  in: 512 bytes str in es:bx
md5_transform:
	push ax
	push cx
	push dx
	push bx
	push bp
	sub sp, 36 ; 12 bien a, b, c, d, f, g, i, temp1, temp2, buff
	mov bp, sp

	;; Khoi tao gia tri bam cho doan
	; a = h0
	mov cx, word ptr [hash]
	mov word ptr [bp], cx
	mov cx, word ptr [hash+2]
	mov word ptr [bp+2], cx
	; b = h1
	mov cx, word ptr [hash+4]
	mov word ptr [bp+4], cx
	mov cx, word ptr [hash+6]
	mov word ptr [bp+6], cx
	; c = h2
	mov cx, word ptr [hash+8]
	mov word ptr [bp+8], cx
	mov cx, word ptr [hash+10]
	mov word ptr [bp+10], cx
	; d = h3
	mov cx, word ptr [hash+12]
	mov word ptr [bp+12], cx
	mov cx, word ptr [hash+14]
	mov word ptr [bp+14], cx

	;; Vong lap chinh cho 4 round
	mov word ptr [bp+24], 0
tfloop2:
	cmp word ptr [bp+24], 15
	ja tfr1
tfr0:
	; ax:dx=bx:cx=d
	mov ax, word ptr [bp+12]
	mov dx, word ptr [bp+14]
	mov bx, ax
	mov cx, dx
	; ax:dx=c xor d
	xor ax, word ptr [bp+8]
	xor dx, word ptr [bp+10]
	; ax:dx = b and (c xor d)
	and ax, word ptr [bp+4]
	and dx, word ptr [bp+6]
	; ax:dx = d xor (b and (c xor d))
	xor ax, bx
	xor dx, cx
	; f = ax:dx = d xor (b and (c xor d))
	mov word ptr [bp+16], ax
	mov word ptr [bp+18], dx
	; g=j
	mov ax, word ptr [bp+24]
	mov word ptr [bp+20], ax
	jmp tfeloop2
tfr1:
	cmp word ptr [bp+24], 31
	ja tfr2
	; ax:dx=bx:cx=c
	mov ax, word ptr [bp+8]
	mov dx, word ptr [bp+10]
	mov bx, ax
	mov cx, dx
	; ax:dx = b xor c
	xor ax, word ptr [bp+4]
	xor dx, word ptr [bp+6]
	; bx:cx = d and (b xor c)
	and ax, word ptr [bp+12]
	and dx, word ptr [bp+14]
	; bx:cx = c xor (d and (b xor c))
	xor ax, bx
	xor dx, cx
	; f = ax:dx = c xor (d and (b xor c))
	mov word ptr [bp+16], ax
	mov word ptr [bp+18], dx
	; ax:dx=5*j+1
	mov ax, word ptr [bp+24]
	mov cx, 5
	mul cx
	inc ax
	; dx = (5*j+1) mod 16
	mov cx, 16
	div cx
	; g = dx = (5*j+1) mod 16
	mov word ptr [bp+20], dx
	jmp tfeloop2
tfr2:
	cmp word ptr [bp+24], 47
	ja tfr3
	; ax:dx = b
	mov ax, word ptr [bp+4]
	mov dx, word ptr [bp+6]
	; ax:dx = b xor c
	xor ax, word ptr [bp+8]
	xor dx, word ptr [bp+10]
	; ax:dx = b xor c cor d
	xor ax, word ptr [bp+12]
	xor dx, word ptr [bp+14]
	; f=ax:dx= b xor c xor d
	mov word ptr [bp+16], ax
	mov word ptr [bp+18], dx
	; ax:dx = 3*i+5
	mov ax, word ptr [bp+24]
	mov cx, 3
	mul cx
	add ax, 5
	; dx = (3*j+5) mod 16
	mov cx, 16
	div cx
	; g = dx = (3*j+5) mod 16
	mov word ptr [bp+20], dx
	jmp tfeloop2
tfr3:
	; ax:dx = d
	mov ax, word ptr [bp+12]
	mov dx, word ptr [bp+14]
	not ax
	not dx
	; ax:dx = b or (not d)
	or ax, word ptr [bp+4]
	or dx, word ptr [bp+6]
	; ax:dx = c xor (b or (not d))
	xor ax, word ptr [bp+8]
	xor dx, word ptr [bp+10]
	; f=ax:dx = c xor (b or (not d))
	mov word ptr [bp+16], ax
	mov word ptr [bp+18], dx
	; ax:dx = 7*i
	mov ax, word ptr [bp+24]
	mov cx, 7
	mul cx
	; dx = (7*j) mod 16
	mov cx, 16
	div cx
	; g = dx = (7*j) mod 16
	mov word ptr [bp+20], dx
tfeloop2:
	; temp=d
	mov ax, word ptr [bp+12]
	mov word ptr [bp+28], ax
	mov ax, word ptr [bp+14]
	mov word ptr [bp+30], ax
	; d=c
	mov ax, word ptr [bp+8]
	mov word ptr [bp+12], ax
	mov ax, word ptr [bp+10]
	mov word ptr [bp+14], ax
	; c=b
	mov ax, word ptr [bp+4]
	mov word ptr [bp+8], ax
	mov ax, word ptr [bp+6]
	mov word ptr [bp+10], ax
	; temp2 = a
	mov ax, word ptr [bp]
	mov word ptr [bp+32], ax
	mov ax, word ptr [bp+2]
	mov word ptr [bp+34], ax
	; temp2 = a+f
	mov ax, word ptr [bp+16]
	add word ptr [bp+32], ax
	mov ax, word ptr [bp+18]
	adc word ptr [bp+34], ax
	; temp2 = a+f+k[i]
	mov al, byte ptr [bp+24]
	mov bl, 4
	mul bl
	mov bx, ax
	add bx, offset k
	mov ax, word ptr [bx]
	add word ptr [bp+32], ax
	mov ax, word ptr [bx+2]
	adc word ptr [bp+34], ax
	; temp2 = a+f+k[i]+w[g]
	mov al, byte ptr [bp+20]
	mov bl, 4
	mul bl
	mov bx, ax
	add bx, word ptr [bp+38]
	mov ax, word ptr [bx]
	add word ptr [bp+32], ax
	mov ax, word ptr [bx+2]
	adc word ptr [bp+34], ax
	; ax:dx = temp2
	mov ax, word ptr [bp+32]
	mov dx, word ptr [bp+34]
	; cx = r[i]
	mov bx, word ptr [bp+24]
	xor cx, cx
	mov cl, byte ptr [r+bx]
; loop for ror(temp2, cx)
tfloop3:
	mov bx, dx
	shl bx, 1
	rcl ax, 1
	rcl dx, 1
	loop tfloop3
	; b = b + leftrotate((a + f + k[i] + w[g]), r[i])
	add word ptr [bp+4], ax
	adc word ptr [bp+6], dx
	; a = temp
	mov ax, word ptr [bp+28]
	mov word ptr [bp], ax
	mov ax, word ptr [bp+30]
	mov word ptr [bp+2], ax

	; test loop
	inc word ptr [bp+24]
	cmp word ptr [bp+24], 64
	jb tfloop2

tfdone:
	;; Them bang bam vao ket qua
	; h0 += a
	mov ax, word ptr [bp]
	add word ptr [hash], ax
	mov ax, word ptr [bp+2]
	adc word ptr [hash+2], ax
	; h1 += b
	mov ax, word ptr [bp+4]
	add word ptr [hash+4], ax
	mov ax, word ptr [bp+6]
	adc word ptr [hash+6], ax
	; h2 += c
	mov ax, word ptr [bp+8]
	add word ptr [hash+8], ax
	mov ax, word ptr [bp+10]
	adc word ptr [hash+10], ax
	; h3 += d
	mov ax, word ptr [bp+12]
	add word ptr [hash+12], ax
	mov ax, word ptr [bp+14]
	adc word ptr [hash+14], ax

	; Restore regs
	add sp, 36
	pop bp
	pop bx
	pop dx
	pop cx
	pop ax
	ret

; md5 append a buff
;  In: ds:bx -> buff
;      cx -> size of buff
md5_write:
	push si
	push di
    push dx
	push bp
	push cx
	push bx
	mov bp, sp

	; Add bit count
	mov ax, cx
	mov cl, 3
	shl ax, cl
	add word ptr [mCount], ax
	adc word ptr [mCount+2], 0
	adc word ptr [mCount+4], 0
	adc word ptr [mCount+6], 0

	; dx = buff_size
	mov dx, 64
	sub dx, word ptr [mOff]
	; If(size < buff_size) just append
	cmp word ptr [bp+2], dx
	jb mwappend
	; Fill buffer
	mov si, bx
	mov di, offset mBuff
	add di, word ptr [mOff]
	mov cx, dx
	rep movsb
	; Transform
	mov bx, offset mBuff
	call md5_transform
	; Update size
	add word ptr [bp], dx
	sub word ptr [bp+2], dx
	mov word ptr [mOff], 0
	; Tranform if size > 64
mwloop1:
	cmp word ptr [bp+2], 64
	jb mwappend
	mov bx, word ptr [bp]
	call md5_transform
	add word ptr [bp], 64
	sub word ptr [bp+2], 64
	jmp mwloop1
mwappend:
	mov si, word ptr [bp]
	mov di, offset mBuff
	add di, word ptr [mOff]
	mov cx, word ptr [bp+2]
	add word ptr [mOff], cx
	rep movsb
	add sp, 4
	pop bp
	pop dx
	pop di
	pop si
	ret

; md5 flush -> finish hash
md5_flush:
	push ax
	push bx
	push cx
	; Copy mCount to cCount
	mov ax, word ptr [mCount]
	mov word ptr [cCount], ax
	mov ax, word ptr [mCount+2]
	mov word ptr [cCount+2], ax
	mov ax, word ptr [mCount+4]
	mov word ptr [cCount+4], ax
	mov ax, word ptr [mCount+6]
	mov word ptr [cCount+6], ax
	; ax = mOff
	mov ax, word ptr [mOff]
	; dx = padlen
	cmp ax, 56
	jb mfh1
	mov cx, 120
	jmp mfh2
mfh1:
	mov cx, 56
mfh2:
	sub cx, ax
	; update
	mov bx, offset padding
	call md5_write
	; update bit count
	mov bx, offset cCount
	mov cx, 8
	call md5_write
	pop cx
	pop bx
	pop ax
	ret





main:
    call USART_Init

    mov si, offset Hello
    call USART_Write_Str

    jmp mRun
lap:
    call USART_Read
    call USART_Write
    cmp al, 0Dh
    je mHash
    cmp al, 08h
    je mBack
    mov byte ptr [bx], al
    inc bx
    inc word ptr [mmSize]
    cmp word ptr [mmSize], mmBuffMax
    je maxChar
    jmp lap
mBack:
    cmp word ptr [mmSize], 0
    je lap
    dec word ptr [mmSize]
    jmp lap
maxChar:
    mov si, offset Hello
    call USART_Write_Str
mHash:
    mov bx, offset mmBuff
    mov cx, word ptr [mmSize]
    call md5_write
    call md5_flush

    ; Print
    mov cx, 0
    xor ax, ax
mloop:
    mov bx, offset hash
    add bx, cx
    mov al, byte ptr [bx]
    call USART_Write_Hex
    inc cx
    cmp cx, 16
    jl mloop

    mov al, 0Dh
    call USART_Write
mRun:
    call md5_init
    mov bx, offset mmBuff
    mov word ptr [mmSize], 0
    jmp lap

END start
