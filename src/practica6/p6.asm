%include "../../lib/pc_io.inc"   

section .bss
    cadena resb 64      ; Reserva 64 espacios para la palabra
    letra_temp resb 2   ; NUEVO: Cajita temporal para imprimir letra por letra

section .data
    msg_ingreso db 'Escribe una frase (max 63 caracteres) y presiona Enter: ', 0
    msg_mayus   db 10, 'Version Mayusculas: ', 0    
    msg_minus   db 10, 'Version Minusculas: ', 0
    msg_borrar  db 8, 32, 8, 0
    msg_fin     db 10, 0

section .text
    global _start       ; referencia para inicio de programa

_start:
    ; --- 1. PEDIR DATOS ---
    mov edx, msg_ingreso
    call puts

    ; Preparar parametros para el procedimiento Capturar
    mov edx, cadena     ; edx = dirección donde se guardará la captura
    mov ax, 64          ; ax = número máximo de caracteres
    call Capturar

    ; --- 2. MAYUSCULAS ---
    mov edx, msg_mayus
    call puts           ; Imprimir título
    
    mov edx, cadena     ; edx = inicio de la cadena capturada
    call Mayusculas     ; Convertir internamente
    
    mov edx, cadena
    call puts           ; Imprimir cadena modificada

    ; --- 3. MINUSCULAS ---
    mov edx, msg_minus
    call puts           ; Imprimir titulo
    
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


; --------------------- SUBRUTINAS ----------------------

; 1. Capturar (Con borrado visual perfecto)
Capturar:
    mov ecx, 0              ; cntador para las letras , inicia en 0              
    dec ax                  ; decremanta el 64 a 63            

.ciclo_leer:
    cmp cx, ax              
    je .fin_captura         
    
    call getch             
    
    cmp al, 10              ; ¿Presionó Enter?
    je .fin_captura         

    cmp al, 8               ; Backspace normal
    je .borrar_letra
    cmp al, 127             ; Backspace Linux
    je .borrar_letra

    ; --- Si es una letra normal ---
    mov byte [edx + ecx], al    ; 1. La guardamos en la memoria principal
    inc ecx                     ; 2. Avanzamos el contador

    ; ¡SECRETO 2! Imprimimos la letra nosotros mismos
    push edx                      ; Guardamos nuestra dirección base por seguridad
    mov byte [letra_temp], al     ; Ponemos la letra en la variable temporal
    mov byte [letra_temp + 1], 0  ; Cerramos con el nulo
    mov edx, letra_temp           ; Le damos la letra a EDX
    call puts                     ; Imprimimos la letra en pantalla
    pop edx                       ; Recuperamos nuestra dirección base intacta
    jmp .ciclo_leer

.borrar_letra:
    cmp ecx, 0              
    je .ciclo_leer          ; Si estamos al inicio (0 letras), ignoramos el borrado
    
    dec ecx                 ; Borrado lógico en la memoria (retrocedemos el contador)

    ;  Borrado
    push edx
    mov edx, msg_borrar     ; Mandamos la secuencia mágica (Atrás, Espacio, Atrás)
    call puts
    pop edx
    jmp .ciclo_leer

.fin_captura:
    mov byte [edx + ecx], 0 
    ret

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