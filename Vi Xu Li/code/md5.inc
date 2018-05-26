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
