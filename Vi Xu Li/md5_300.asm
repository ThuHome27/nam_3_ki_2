
;*************************************************  
MAND  Macro M1,M2  
  mov    eax,M1  
  and    eax,M2  
  EXITM  <eax>  
ENDM  
MXOR  Macro M1,M2  
  mov    eax,M1  
  xor    eax,M2  
  EXITM  <eax>  
endm  
MADD  Macro M1,M2  
  mov    eax,M1  
  add    eax,M2  
  EXITM  <eax>  
ENDM  
SWAP  Macro M1,M2  
  push  M1  
  push  M2  
  pop    M1  
  pop    M2  
endm  
Mcopy MACRO lpSource,lpDest,len  
  mov    esi, lpSource  
  mov    edi, lpDest  
  mov    ecx, len  
  rep    movsb  
ENDM  
WordToHex MACRO _lValue  
  mov    eax,_lValue  
  xchg  al,ah  
  rol    eax,16  
  xchg  al,ah  
  EXITM  <eax>  
ENDM  
.const  
.data?  
stMd5Hex  DB    33  DUP  (?)  
.data  
szData_SS  DWORD  7,12,17,22  
      DWORD  5,9,14,20  
      DWORD  4,11,16,23  
      DWORD  6,10,15,21  
        
stData_FF  DWORD  0D76AA478H,0E8C7B756H,0242070DBH,0C1BDCEEEH  
      DWORD  0F57C0FAFH,04787C62AH,0A8304613H,0FD469501H  
      DWORD  0698098D8H,08B44F7AFH,0FFFF5BB1H,0895CD7BEH  
      DWORD  06B901122H,0FD987193H,0A679438EH,049B40821H  
        
stData_GG  DWORD  0F61E2562H,0C040B340H,0265E5A51H,0E9B6C7AAH  
      DWORD  0D62F105DH,002441453H,0D8A1E681H,0E7D3FBC8H  
      DWORD  021E1CDE6H,0C33707D6H,0F4D50D87H,0455A14EDH  
      DWORD  0A9E3E905H,0FCEFA3F8H,0676F02D9H,08D2A4C8AH  
        
stData_HH  DWORD  0FFFA3942H,08771F681H,06D9D6122H,0FDE5380CH  
      DWORD  0A4BEEA44H,04BDECFA9H,0F6BB4B60H,0BEBFBC70H  
      DWORD  0289B7EC6H,0EAA127FAH,0D4EF3085H,004881D05H  
      DWORD  0D9D4D039H,0E6DB99E5H,01FA27CF8H,0C4AC5665H  
        
stData_II  DWORD  0F4292244H,0432AFF97H,0AB9423A7H,0FC93A039H  
      DWORD  0655B59C3H,08F0CCC92H,0FFEFF47DH,085845DD1H  
      DWORD  06FA87E4FH,0FE2CE6E0H,0A3014314H,04E0811A1H  
      DWORD  0F7537E82H,0BD3AF235H,02AD7D2BBH,0EB86D391H  
.code  
 
 
_md5_FF Proc uses ecx _a, _b, _c, _d, _x, _s, _ac  
  mov    eax,_b  
  and    eax,_c  
  mov    ecx,_b  
  not    ecx  
  and    ecx,_d  
  or    eax,ecx  
    
  add    eax,_a  
  add    eax,_x  
  add    eax,_ac  
  mov    ecx,_s  
  rol    eax,cl  
  add    eax,_b  
  ret  
_md5_FF endp  
_md5_GG Proc uses ecx _a,_b,_c,_d,_x,_s,_ac  
  mov    eax,_b  
  and    eax,_d  
  mov    ecx,_d  
  not    ecx  
  and    ecx,_c  
  or    eax,ecx  
    
  add    eax,_a  
  add    eax,_x  
  add    eax,_ac  
  mov    ecx,_s  
  rol    eax,cl  
  add    eax,_b  
    ret  
_md5_GG EndP  
_md5_HH Proc uses ecx _a,_b,_c,_d,_x,_s,_ac  
    mov    eax,_b  
    xor    eax,_c  
    xor    eax,_d  
 
  add    eax,_a  
  add    eax,_x  
  add    eax,_ac  
  mov    ecx,_s  
  rol    eax,cl  
  add    eax,_b  
    ret  
_md5_HH EndP  
 
_md5_II Proc uses ecx _a,_b,_c,_d,_x,_s,_ac  
    mov    eax,_d  
    not    eax  
    or    eax,_b  
    xor    eax,_c  
 
  add    eax,_a  
  add    eax,_x  
  add    eax,_ac  
  mov    ecx,_s  
  rol    eax,cl  
  add    eax,_b  
    ret  
_md5_II EndP  
_ConvertToWordArray  Proc uses edi esi ecx _lpData,_dwLen  
  LOCAL  @lWordArray,@lNumberOfWords  
    
  mov    eax,_dwLen  
  add    eax,8  
  shr    eax,6  
  inc    eax  
  shl    eax,4  
  dec    eax  
  shl    eax,2  
  mov    @lNumberOfWords,eax  
  invoke  VirtualAlloc,NULL,@lNumberOfWords,MEM_COMMIT,PAGE_READWRITE  
  mov    @lWordArray,eax  
  mov    edi,eax  
  invoke  RtlZeroMemory,@lWordArray,@lNumberOfWords  
  mov    esi,_lpData  
  Mcopy  _lpData,@lWordArray,_dwLen  
  mov    eax,128  
  stosd  
  mov    edi,@lWordArray  
  mov    ecx,@lNumberOfWords  
  shr    ecx,2  
  mov    eax,_dwLen  
  shr    eax,29  
  mov    DWORD PTR [edi+ecx*4],eax  
  dec    ecx  
  mov    eax,_dwLen  
  shl    eax,3  
  mov    DWORD PTR [edi+ecx*4],eax  
  mov    eax,@lWordArray  
  ret  
_ConvertToWordArray endp  
;###############################################  
; Ö÷³ÌÐò  
; _lpData ÐèÒª¼ÓÃÜµÄÊý¾ÝÖ¸Õë  
; _dwLen  ÐèÒª¼ÓÃÜµÄÊý¾Ý³¤¶È  
; ·µ»ØÖµ  MD5ÎÄ±¾Ö¸Õë  
;###############################################  
_Md5 Proc uses edi ebx ecx edx _lpData,_dwLen  
  LOCAL  @a,@b1,@c,@d  
  LOCAL  @AA,@BB,@CC,@DD  
  LOCAL  @lNumber  
    
  invoke  _ConvertToWordArray,_lpData,_dwLen  
  mov    edi,eax  
    
  mov    @a,67452301H  
  mov    @b1,0EFCDAB89H  
  mov    @c,98BADCFEH  
  mov    @d,10325476H  
    
  mov    eax,_dwLen  
  add    eax,8  
  shr    eax,6  
  inc    eax  
  shl    eax,4  
  dec    eax  
  mov    @lNumber,eax  
 
  xor    ebx,ebx  
  .While  ebx<=@lNumber  
    push  @a  
    pop    @AA  
    push  @b1  
    pop    @BB  
    push  @c  
    pop    @CC  
    push  @d  
    pop    @DD  
      
    push  ebx  
    push  edi  
    lea    ebx,[ebx*4]  
    add    edi,ebx  
    xor    ebx,ebx  
    .While  ebx<16  
      mov    ecx,ebx  
      shl    ecx,30  
      shr    ecx,30  
      mov    eax,[edi+ebx*4]  
      invoke  _md5_FF,@a,@b1,@c,@d,eax,szData_SS[ecx*4],stData_FF[ebx*4]  
      mov    @a,eax  
      SWAP  @a,@d  
      SWAP  @b1,@d  
      SWAP  @c,@d  
      inc    ebx  
    .endw  
    xor    ebx,ebx  
    mov    edx,ebx  
    inc    dl  
    .While  ebx<16  
      mov    ecx,ebx  
      shl    ecx,30  
      shr    ecx,30  
        
      mov    eax,[edi+edx*4]  
      invoke  _md5_GG,@a,@b1,@c,@d,eax,szData_SS[ecx*4+16],stData_GG[ebx*4]  
      mov    @a,eax  
      SWAP  @a,@d  
      SWAP  @b1,@d  
      SWAP  @c,@d  
      add    dl,5  
      shl    dl,4  
      shr    dl,4  
      inc    ebx  
    .endw  
    xor    ebx,ebx  
    mov    edx,5  
    .While  ebx<16  
      mov    ecx,ebx  
      shl    ecx,30  
      shr    ecx,30  
        
      mov    eax,[edi+edx*4]  
      invoke  _md5_HH,@a,@b1,@c,@d,eax,szData_SS[ecx*4+32],stData_HH[ebx*4]  
      mov    @a,eax  
      SWAP  @a,@d  
      SWAP  @b1,@d  
      SWAP  @c,@d  
      add    edx,3  
      shl    dl,4  
      shr    dl,4  
      inc    ebx  
    .endw  
    xor    ebx,ebx  
    mov    edx,ebx  
    .While  ebx<16  
      mov    ecx,ebx  
      shl    ecx,30  
      shr    ecx,30  
        
      mov    eax,[edi+edx*4]  
      invoke  _md5_II,@a,@b1,@c,@d,eax,szData_SS[ecx*4+48],stData_II[ebx*4]  
      mov    @a,eax  
      SWAP  @a,@d  
      SWAP  @b1,@d  
      SWAP  @c,@d  
      add    edx,7  
      shl    dl,4  
      shr    dl,4  
      inc    ebx  
    .endw  
    pop    edi  
    pop    ebx  
      
    mov    @a,MADD(@a,@AA)  
    mov    @b1,MADD(@b1,@BB)  
    mov    @c,MADD(@c,@CC)  
    mov    @d,MADD(@d,@DD)  
    add    ebx,16  
  .EndW  
 
  mov    @a,WordToHex(@a)  
  mov    @b1,WordToHex(@b1)  
  mov    @c,WordToHex(@c)  
  mov    @d,WordToHex(@d)  
    
  invoke  wsprintf,addr stMd5Hex,SADD("%08x%08x%08x%08x"),@a,@b1,@c,@d  
  lea    eax,stMd5Hex  
  ret  
_Md5 endp  
;************************************************* 
 