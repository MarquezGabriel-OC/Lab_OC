%include "../../lib/pc_io.inc" 

section .bss 
cadena resb 64 ; cajita 64 espacios 
letra_temporal resb 2 ; para sustituir ecx  

section .data 
msg_captura   db 'Ingresa una cadena (max 63 caracteres) y preciona ENTER: ', 0
msg_mayuscula db  10, 'Texto en mayuscula: ', 0
msg_minuscula db  10, 'Texto en minuscula: ', 0
msg_borrar    db 8, 32, 8, 0 
msg_fin       db 10, 0

section .text 
global _start 

_start:
; 1. Captura 
mov edx, msg_captura   ; lo que te aprece en la terminal 
call puts

mov edx, cadena 
mov ax, 64
call Captura 

; 2. Mayuscula
mov edx, msg_mayuscula ; lo que te aparece en la terminal 
call puts 

mov edx, cadena 
call Mayuscula

mov edx, cadena        ; imprimir cadena modificada Mayuscula
call puts 

; 3. Minuscula
mov edx, msg_minuscula ; lo que te aparece en la terminal 
call puts 

mov edx, cadena        ; imprimir cadena modificada Minuscula
call Minuscula

mov edx, cadena
call puts

; Ultimo salto de linea 
mov edx, msg_fin
call puts 

; 4. Fin 
mov eax, 1
int 0x80 

; -------- SUBRUTINAS ------- 

; 1. CAMPTURA 
Captura:
mov ecx, 0 ; contador letras 
dec ax     ; decrementar en 1 para el caracter nulo 

.Ciclo_leer: 
    cmp cx, ax 
    je .fin_captura 

    call getch

    cmp al, 10
    je .fin_captura 

    cmp al, 8 
    je .borrar_letra 

    cmp al, 127
    je .borrar_letra 

    ; ------ IMPRIMR LETRA (SIN getche) ------
    mov byte [edx + ecx], al
    inc ecx 

    push edx 
    mov byte [letra_temporal], al
    mov byte [letra_temporal + 1], 0
    mov edx, letra_temporal 
    call puts 
    pop edx 
    jmp .Ciclo_leer

.borrar_letra:
    cmp ecx, 0           
    je .Ciclo_leer      ; si estamos al inicio (0 letras), ingoramos el borrador 

    dec ecx
    ; Borrar 
    push edx 
    mov edx, msg_borrar
    call puts 
    pop edx 
    jmp .Ciclo_leer

.fin_captura:
mov byte [edx + ecx], 0
ret

; 2. Mayuscula
Mayuscula:
mov ecx, 0 

.ciclo_mayuscula: 
    mov al, byte [edx + ecx]  ;tomamos letra actual 
    cmp al, 0 
    je .fin_mayus

    cmp al, 'a'
    jl .siguiente_mayus       ; si es mayuscula pasa a la siguente letra / jl= si  (al)  es menor a 'a'
    cmp al, 'z'
    jg .siguiente_mayus       ; si es mayuscula pasa a la siguente letra / jg= si  (al)  es mayor a 'z'

    ; SI, SI es minucula: 
    sub al, 32
    mov byte [edx + ecx], al 

.siguiente_mayus:
inc ecx 
jmp .ciclo_mayuscula

.fin_mayus:
ret

; 3. Minuscula
Minuscula:
mov ecx, 0

.ciclo_minusculas: 
    mov al, byte [edx + ecx]
    cmp al, 0
    je .fin_minus

    cmp al, 'A'
    jl .siguente_minus 
    cmp al, 'Z'
    jg .siguente_minus

    ;SI, SI es 
    add al, 32 
    mov byte [edx + ecx], al 

.siguente_minus:
    inc ecx
    jmp .ciclo_minusculas

.fin_minus:
ret
    







    




















