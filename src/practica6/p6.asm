%include "../../lib/pc_io.inc"    ; incluir declaraciones de procedimiento externos

section .bss
    cadena resb 64      ; Reserva 64 bytes (espacios) vacíos para lo que el usuario escriba

section .data
    msg_ingreso db 'Escribe una frase (max 63 caracteres) y presiona Enter: ', 0
    msg_mayus   db 10, 'Version Mayusculas: ', 0    ; El 10 inicial es un salto de línea
    msg_minus   db 10, 'Version Minusculas: ', 0
    msg_fin     db 10, 0

section .text
    global _start       ; referencia para inicio de programa

_start:
    ; --- 1. PEDIR DATOS ---
    mov edx, msg_ingreso
    call puts

    ; Preparar parámetros para el procedimiento Capturar
    mov edx, cadena     ; edx = dirección donde se guardará la captura
    mov ax, 64          ; ax = número máximo de caracteres
    call Capturar

    ; --- 2. MAYÚSCULAS ---
    mov edx, msg_mayus
    call puts           ; Imprimir título
    
    mov edx, cadena     ; edx = inicio de la cadena capturada
    call Mayusculas     ; Convertir internamente
    
    mov edx, cadena
    call puts           ; Imprimir cadena modificada

    ; --- 3. MINÚSCULAS ---
    mov edx, msg_minus
    call puts           ; Imprimir título
    
    mov edx, cadena     ; edx = inicio de la cadena
    call Minusculas     ; Convertir internamente
    
    mov edx, cadena
    call puts           ; Imprimir cadena modificada

    ; Imprimir un salto de línea final para que la terminal se vea limpia
    mov edx, msg_fin
    call puts

    ; --- FIN DEL PROGRAMA ---
    mov eax, 1          ; seleccionar llamada al sistema para fin de programa
    int 0x80            ; llamada al sistema - fin de programa


; =========================================================================
;                       PROCEDIMIENTOS REQUERIDOS
; =========================================================================

; 1.Capturar
Capturar:
    mov ecx, 0              ; ecx será nuestro Índice/Contador, empezamos en 0
    dec ax                  ; Le restamos 1 al límite (64) para dejar espacio al nulo (0) al final

.ciclo_leer:
    cmp cx, ax              ; ¿Ya escribimos 63 letras?
    je .fin_captura         ; Si sí, terminamos a la fuerza
    
    call getche             ; Leemos tecla (se muestra en pantalla y se guarda en registro AL)
    
    cmp al, 10              ; ¿Presionó Enter (salto de línea / ASCII 10)?
    je .fin_captura         ; Si sí, dejamos de capturar

    mov byte [edx + ecx], al; Modo Base+Índice: Guardamos la letra en la memoria
    inc ecx                 ; Aumentamos el contador en 1 (siguiente espacio)
    jmp .ciclo_leer         ; Repetimos el ciclo

.fin_captura:
    mov byte [edx + ecx], 0 ; Ponemos el carácter nulo al final para cerrar la cadena
    ret                     ; Regresamos a la rutina principal (_start)


; 2. Procedimiento Mayúsculas
Mayusculas:
    mov ecx, 0              ; Reiniciamos contador a 0

.ciclo_mayus:
    mov al, byte [edx + ecx]; Tomamos la letra actual
    cmp al, 0               ; ¿Es el fin de la cadena (nulo)?
    je .fin_mayus           ; Si sí, terminamos
    
    ; Condicional (If): ¿Es letra minúscula (entre 'a' y 'z')?
    cmp al, 'a'             
    jl .siguiente_mayus     ; Si es un símbolo antes de la 'a', lo ignoramos
    cmp al, 'z'
    jg .siguiente_mayus     ; Si es un símbolo después de la 'z', lo ignoramos

    ; Si pasó los filtros, ES minúscula. La convertimos restando 32
    sub al, 32
    mov byte [edx + ecx], al; Guardamos la letra ya convertida de vuelta en memoria

.siguiente_mayus:
    inc ecx                 ; Siguiente letra
    jmp .ciclo_mayus        ; Repetimos

.fin_mayus:
    ret


; 3. Procedimiento Minúsculas
Minusculas:
    mov ecx, 0              ; Reiniciamos contador a 0

.ciclo_minus:
    mov al, byte [edx + ecx]; Tomamos la letra actual
    cmp al, 0               ; ¿Es el fin de la cadena (nulo)?
    je .fin_minus           
    
    ; Condicional (If): ¿Es letra MAYÚSCULA (entre 'A' y 'Z')?
    cmp al, 'A'             
    jl .siguiente_minus     
    cmp al, 'Z'
    jg .siguiente_minus     

    ; Si pasó los filtros, ES mayúscula. La convertimos sumando 32
    add al, 32
    mov byte [edx + ecx], al; Guardamos en memoria

.siguiente_minus:
    inc ecx                 
    jmp .ciclo_minus        

.fin_minus:
    ret