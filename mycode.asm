
; You may customize this and other start-up templates;
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.data
    id_table    dw  0123h,  4567h,  89abh,  0cdefh, 1234h,  5678h,  9abch,  0def0h, 2345h,  6789h,  0abcdh, 0ef01h, 3456h,  789ah,  0bcdeh, 0f012h, 4567h,  89abh,  0cdefh, 0122h
    pw_table    db  00h,    01h,    02h,    03h,    04h,    05h,    06h,    07h,    08h,     09h,   0ah,    0bh,    0ch,    0dh,    0eh,    0fh,    00h,    01h,    02h,    03h
    welcomemsg  db  "Security Lock.",10,13,"$"
    successmsg  dw  10,13,"Access allowed!  :)",10,13,"$"
    failmsg     dw  10,13,"Access denied!  :(",10,13,"$"
    msgid       db  10,13,"Enter ID (4 hexa digits)",10,13,">> $"
    msgpw       db  10,13,"Enter Password (1 hexa digit)",10,13,">> $"
    id          dw  ?
    pw          db  ?
    sixteen     dw  10h
    size        dw  14h
    temp        dw  ?

.code
    mov     ax,@data
    mov     ds,ax

    mov     ax,offset welcomemsg   ;msg to be printed
    mov     si,ax
    mov     bl, 0ah                ;color of the msg
    call    print
    
    call    get_id
    call    get_pw
    call    login

    ; wait for any key press...
    mov     ah, 0
    int     16h

    ret
    
    print     proc    near
        mov     dl, 0   ; current column.
        mov     dh, 0   ; current row.
            
        x:
        mov     ah, 02h
        int     10h
        cmp     [si],'$'
        je      exit  
        mov     al,[si]
        inc     si
        mov     bh,0
        mov     cx,1
        inc     dl
        
        mov     ah,09h 
        int     10h
       
        jmp     x
                
        exit: 
        ret
    endp
    
    login   proc    near
        ; set forward direction:
        cld
        ; set counter to data size:
        mov     cx,size
        ; load string address into es:di
        mov     ax,cs
        mov     es,ax
        lea     di,id_table
        ; we will look for the word in data string:
        mov     ax,id
        repne   scasw
        jz      found
        not_found:
        ; "no" - not found!
        mov     dx,offset failmsg
        mov     ah,9h
        int     21h
        jmp     exit_here
        found:
        ; "yes" - found!
        mov     si,size
        sub     si,cx
        dec     si
        mov     bx,offset pw_table
        mov     al,byte ptr([bx+si])
        cmp     al,pw
        jne     not_found
        mov     dx,offset successmsg
        mov     ah,9
        int     21h
        ; di contains the address of searched word:
        dec     di

        exit_here:
        ret
    endp

    get_id  proc    near
        mov     dx,offset msgid
        mov     ah,9
        int     21h

        mov     cx,4
        mov     bx,0
        xx:
        call    readch
        call    s2h
        call    store
        loop    xx
        mov     id,bx
        ret
    endp

    get_pw  proc    near
        mov     dx,offset msgpw
        mov     ah,9
        int     21h

        mov     cx,1
        call    readch
        call    s2h
        mov     pw,al
        ret
    endp

    readch  proc    near
        mov     ah,1
        int     21h
        ret
    endp

    s2h     proc    near
        cmp al, '0'
        jae  f1

        f1:
        cmp al, '9'
        ja f2     ; jumps only if not '0' to '9'.

        sub al, 30h  ; convert char '0' to '9' to numeric value.
        jmp done

        f2:
        ; gets here if it's 'a' to 'f' case:
        or al, 00100000b   ; remove upper case (if any).
        sub al, 57h  ;  convert char 'a' to 'f' to numeric value.

        done:

        ret
    endp

    store   proc    near
        mov     temp,cx
        dec     cx
        mov     ah,0
        cmp     cx,0
        je      jump
        g1:
        mul     sixteen
        loop    g1
        jump:
        mov     cx,temp
        add     bx,ax
        ret
    endp


ret




