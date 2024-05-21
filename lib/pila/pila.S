.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm

.macro endfun nombre
    .size \nombre, . - \nombre
.endm

.equ Pila_base, 0     // Le doy valores a las expresiones 
.equ Pila_limite, 4
.equ Pila_puntero, 8

/**
 * @brief Inicializa un descriptor de pila. Inicialmente la pila está vacía
 * 
 * @param descriptor Descriptor a inicializar
 * @param base Dirección base (menor dirección) de la pila
 * @param capacidad Capacidad de la pila (en elementos)
 */
defun Pila_init                            // *d = r0 / *b = r1 / c = r2
    str r1, [r0, #Pila_base]
    mov r12, #4
    mul r2, r12                            // Límite = b + c*4
    add r3, r1, r2
    str r3, [r0, #Pila_limite]
    str r1, [r0, #Pila_puntero]
    bx lr
endfun Pila_init

/**
 * @brief Ingresa un valor en la pila descrita
 * 
 * @param descriptor Descriptor de pila
 * @param valor Valor a ingresar
 * @return int 0 si la operación se realizó, -1 si la pila estaba llena
 */
defun Pila_push                       // r0 = *d; r1 = valor
    ldr r2, [r0, #Pila_puntero]
    ldr r3, [r0, #Pila_limite]
    cmp r2, r3
    BHS 0f
    str r1, [r2]
    add r2, #4
    str r2, [r0, #Pila_puntero]
    mov r0, #0
    B 1f
0:
    mov r0, #-1
1:
    bx lr
endfun Pila_push

/**
 * @brief Quita el último elemento de la pila descrita y copia su valor en
 * destino
 * 
 * @param descriptor Descriptor de pila
 * @param destino Dirección de la variable de destino
 * @return int 0 si la operación se realizó, -1 si la pila estaba vacía
 */
defun Pila_pop                       // r0 = *d; r1 = *destino
    ldr r2, [r0, #Pila_puntero]
    ldr r3, [r0, #Pila_base]
    cmp r2, r3
    BLS 0f
    add r2, #-4
    ldr r12, [r2]
    str r12, [r1]
    str r2, [r0, #Pila_puntero]
    mov r0, #0
    B 1f
0:
    mov r0, #-1
1:    
    bx lr
endfun Pila_pop
