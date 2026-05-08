; ugaday.asm - minimalnaya rabochaya versiya
extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern ExitProcess
extern GetTickCount

section .data
    vkhod_desk     dq 0
    vykhod_desk    dq 0
    sekret         dd 0
    popytki        dd 0
    bufer          db 32 dup(0)
    prochitano     dq 0
    zapisano       dq 0

    podskazka      db 'Ugaday (1-100): '
    podskazka_dl   equ $ - podskazka
    slishkom_mnogo db 'Slishkom mnogo!', 13, 10
    slishkom_mnogo_dl equ $ - slishkom_mnogo
    slishkom_malo  db 'Slishkom malo!', 13, 10
    slishkom_malo_dl equ $ - slishkom_malo
    pravilno_soob  db 'Pravilno! Popytok: '
    pravilno_dl    equ $ - pravilno_soob
    novaya_stroka  db 13, 10
    novaya_stroka_dl equ $ - novaya_stroka
    chislo_bufer   db 16 dup(0)

section .text
global glavnaya

; universalnaya pechat (rcx=deskriptor, rdx=buffer, r8=dlina)
pechat:
    sub rsp, 40
    lea r9, [zapisano]
    push 0
    sub rsp, 32
    call WriteConsoleA
    add rsp, 32+8
    add rsp, 40
    ret

; preobrazovanie stroki (bufer) v chislo -> eax
stroka_v_chislo:
    lea rsi, [bufer]
    xor eax, eax
.sled:
    movzx ecx, byte [rsi]
    cmp cl, '0'
    jb .gotovo
    cmp cl, '9'
    ja .gotovo
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc rsi
    jmp .sled
.gotovo:
    ret

; preobrazovanie chisla (eax) v stroku (rdi=buffer)
chislo_v_stroku:
    push rdi
    add rdi, 15
    mov byte [rdi], 0
    dec rdi
    mov ebx, eax
    test ebx, ebx
    jnz .polozhitelnoe
    mov byte [rdi], '0'
    jmp .zapolnit
.polozhitelnoe:
    mov ecx, 10
.delenie:
    xor edx, edx
    mov eax, ebx
    div ecx
    mov ebx, eax
    add dl, '0'
    mov byte [rdi], dl
    dec rdi
    test ebx, ebx
    jnz .delenie
.zapolnit:
    inc rdi
    mov rsi, rdi
    pop rdi
    mov rcx, rdi
.kopirovat:
    mov al, [rsi]
    mov [rcx], al
    inc rsi
    inc rcx
    test al, al
    jnz .kopirovat
    ret

glavnaya:
    sub rsp, 40

    ; poluchaem deskriptory
    mov rcx, -10
    call GetStdHandle
    mov [vkhod_desk], rax
    mov rcx, -11
    call GetStdHandle
    mov [vykhod_desk], rax

    ; sekretnoe chislo 1..100
    call GetTickCount
    xor edx, edx
    mov ecx, 100
    div ecx
    inc edx
    mov [sekret], edx

igra_tsikl:
    inc dword [popytki]

    ; vyvod podskazki
    mov rcx, [vykhod_desk]
    lea rdx, [podskazka]
    mov r8, podskazka_dl
    call pechat

    ; chtenie stroki
    mov rcx, [vkhod_desk]
    lea rdx, [bufer]
    mov r8, 31
    lea r9, [prochitano]
    push 0
    sub rsp, 32
    call ReadConsoleA
    add rsp, 32+8

    ; preobrazovanie v chislo
    call stroka_v_chislo
    cmp eax, [sekret]
    je .pravilno
    jg .mnogo

    ; slishkom malo
    mov rcx, [vykhod_desk]
    lea rdx, [slishkom_malo]
    mov r8, slishkom_malo_dl
    call pechat
    jmp igra_tsikl

.mnogo:
    mov rcx, [vykhod_desk]
    lea rdx, [slishkom_mnogo]
    mov r8, slishkom_mnogo_dl
    call pechat
    jmp igra_tsikl

.pravilno:
    mov rcx, [vykhod_desk]
    lea rdx, [pravilno_soob]
    mov r8, pravilno_dl
    call pechat

    ; vyvodim chislo popytok
    mov eax, [popytki]
    lea rdi, [chislo_bufer]
    call chislo_v_stroku
    lea rdx, [chislo_bufer]
    ; vychislyaem dlinu
    mov rsi, rdx
    xor r8, r8
.dlina:
    cmp byte [rsi+r8], 0
    je .dlina_gotova
    inc r8
    jmp .dlina
.dlina_gotova:
    mov rcx, [vykhod_desk]
    call pechat

    ; novaya stroka
    mov rcx, [vykhod_desk]
    lea rdx, [novaya_stroka]
    mov r8, novaya_stroka_dl
    call pechat

    ; vykhod
    mov rcx, 0
    call ExitProcess

    add rsp, 40
    ret