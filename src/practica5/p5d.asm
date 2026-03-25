%include "../../lib/pc_io.inc"  	; incluir declaraciones de procedimiento externos
								    ; que se encuentran en la biblioteca libpc_io.a
                                    
; ------ BASE + INDICE ------

section	.text
	global _start               ;referencia para inicio de programa
	
_start:
	mov edx, msg                ; base 
    mov esi, 25                 ; indice 
    mov byte [edx + esi], 'Z'   ; base + indice = byte25=z y lo hacemos Z
    mov edx, msg                ; edx = dirección de la cadena msg
	call puts			        ; imprime cadena msg terminada en valor nulo (0)

	mov	eax, 1	    	; seleccionar llamada al sistema para fin de programa
	int	0x80        	; llamada al sistema - fin de programa
    
section	.data
    msg	db  'abcdefghijklmnopqrstuvwxyz0123456789',0xa,0