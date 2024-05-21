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

.equ Cola_base, 0     // Le doy valores a las expresiones 
.equ Cola_limite, 4
.equ Cola_pLectura, 8
.equ Cola_pEscritura, 12
.equ Cola_llena, 16           // 0 = vacía; 1 = llena

/**
 * @brief Inicializa un descriptor de cola
 * 
 * @param descriptor Descriptor
 * @param base Dirección base de memoria
 * @param tamano Tamano de memoria para la cola
 */
defun Cola_init              // r0 = *d; r1 = *b; r2 = tamaño
    str r1, [r0, #Cola_base]
    mov r12, #4
    mul r2, r12                            // Límite = b + c*4
    add r3, r1, r2
    str r3, [r0, #Cola_limite]
    str r1, [r0, #Cola_pLectura]
    str r1, [r0, #Cola_pEscritura]
    mov r12, #0
    str r12, [r0, #Cola_llena]
    bx lr
endfun Cola_init

/**
 * @brief Pone un nuevo valor en cola.
 * 
 * @param descriptor Descriptor de cola
 * @param valor Valor a introducir
 * @return int 0 si la operación fue exitosa. -1 si la cola estaba llena.
 */
defun Cola_pone       // r0 = *d; r1 = valor
    push {r4-r5,lr}
    ldr r2, [r0, #Cola_llena]
    ldr r3, [r0, #Cola_pEscritura]
    ldr r4, [r0, #Cola_pLectura]
    ldr r5, [r0, #Cola_limite]
    cmp r2, #0                               // Comparo llena con 0
    BNE 2f                                   // Si llena != 0, salto a 2, sino sigo
    str r1, [r3]                             // Guardo valor en pE
    add r3, #4                               // pE ++ (x4)
    cmp r3, r5                               // Comparo pE con límite
    BNE 0f                                   // Si pE != límite, salto a 0, sino sigo
    ldr r5, [r0, #Cola_base]                 // Para pE = límite, traigo la base
    mov r3, r5                               // pE <--- pbase
0:                                         // 0:
    cmp r3, r4                               // Comparo pE con pL
    BEQ 1f                                   // Si pE = pL, salto a 1
    str r3, [r0, #Cola_pEscritura]           // Para pE != pL, guardo pE
    mov r0, #0                               // Operación exitosa: retorno 0
    B 3f                                     // Salgo
1:                                         // 1:
    mov r2, #1                               // llena = 1
    str r2, [r0, #Cola_llena]                // Guardo llena
    str r3, [r0, #Cola_pEscritura]           // Guardo pE
    mov r0, #0                               // Operación exitosa: retorno 0
    B 3f                                     // Salgo
2:                                         // 2:
    mov r0, #-1                              // No pudo realizarse la operación: retorno -1  
3:                                         // 3:
    pop {r4-r5,pc}                           // Salida
endfun Cola_pone
/**
 * @brief Quita el elemento más antiguo de la cola y escribe su valor en 
 * destino.
 * 
 * @param descriptor Descriptor de cola
 * @param destino Puntero a variable donde guardar el valor quitado
 * @return int 0 si la operación tuvo éxito. -1 si la cola estaba vacía.
 */
defun Cola_quita           // r0 = *d; r1 = destino
    push {r4-r5,lr}
    ldr r2, [r0, #Cola_llena]
    ldr r3, [r0, #Cola_pEscritura]
    ldr r4, [r0, #Cola_pLectura]
    ldr r5, [r0, #Cola_limite]
    cmp r2, #1                                // Comparo llena con 1
    BNE 2f                                    // Si llena != 1, salto a 2
    mov r2, #0                                // Para llena = 1, pongo llena = 0
    str r2, [r0, #Cola_llena]                 // Guardo llena
0:                                          // 0:
    str r4, [r1]                              // Guardo el valor que lee pL en *destino
    add r4, #4                                // pL ++ (x4)
    cmp r4, r5                                // Comparo pL con el límite
    BNE 1f                                    // Si pL != límite, salto a 1
    ldr r5, [r0, #Cola_base]                  // Para pL = límite, cargo la base
    mov r4, r5                                // pL <--- pbase
1:                                          // 1:
    str r4, [r0, #Cola_pLectura]              // Guardo pL
    mov r0, #0                                // Operación exitosa: retorno 0
    B 3f                                      // Salgo
2:                                          // 2:
    cmp r3, r4                                // Comparo pE con pL  
    BNE 0b                                    // Si pE != pL, salto a 0
    mov r0, #-1                               // Si pE = pL, no pudo realizarse la operación: retorno -1
3:                                          // 3:
    pop {r4-r5,pc}                            // Salida
endfun Cola_quita
