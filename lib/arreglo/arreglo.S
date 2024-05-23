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


.equ Arreglo_base, 0     // Le doy valores a las expresiones 
.equ Arreglo_tamanoElemento, 4
.equ Arreglo_numElementos, 8


/**
 * @brief Inicializa un descriptor que describe un arreglo con una direccion de
 * memoria base, tamaño de elemento y número de elementos dados
 * 
 * @param descriptor Puntero al descriptor a inicializar 
 * @param base Dirección base del arreglo
 * @param tamanoElemento Tamaño del elemento
 * @param numElementos Número de elementos
 */
defun Arreglo_init
    str r1, [r0, #Arreglo_base]
    str r2, [r0, #Arreglo_tamanoElemento]
    str r3, [r0, #Arreglo_numElementos]
    bx lr
endfun Arreglo_init

/**
 * @brief Retorna un puntero a un elemento del arreglo descrito
 * 
 * @param descriptor Descriptor de arreglo inicializado con Arreglo_init
 * @param indice
 * @return void* Puntero al elemento indicado por indice, NULL si no existe el
 * elemento (NULL es la dirección 0)
 */
defun Arreglo_apunta
    ldr r2, [r0, #Arreglo_numElementos]       // Traigo n = n° de elementos
    cmp r1, r2                                // Comparo r1 = índice con n
    BHS 1f                                    // Si i >= n, retorno NULL
0:
    ldr r3, [r0, #Arreglo_base]               // Traigo *b = puntero base
    ldr r12, [r0, #Arreglo_tamanoElemento]    // Traigo t = tamaño de los elementos
    mul r1, r1, r12                           // Multiplico r1*r12 (i*t) = offset y sobreescribo en r1
    add r3, r1                                // Sumo el offset a la base y la sobreescribo
    mov r0, r3                                // Muevo el puntero r3 a r0
    B 2f
1:
    mov r0, #0
2:
    bx lr
endfun Arreglo_apunta

/**
 * @brief Lee el valor de un elemento del arreglo descrito, copiándolo en el
 * espacio de memoria proporcionado. Supone que la región de memoria tiene
 * tamaño suficiente
 * 
 * @param descriptor Descriptor del arreglo
 * @param indice Índice del elemento a leer
 * @param destino Puntero a la regió de memoria donde copiar el valor
 * @return int 0 si la operación pudo realizarse, -1 si el elemento no existe
 */
defun Arreglo_lee                              // r0 = *descriptor; r1 = índice; r2 = *destino CORREGIR LO DE ABAJO
    ldr r12, [r0, #Arreglo_numElementos]       // Traigo n = n° de elementos
    cmp r1, r12                                // Comparo r1 = índice con n
    BHS 2f                                     // Si r1 >= n, salto 
    ldr r3, [r0, #Arreglo_base]                // Traigo b = base a r3
    ldr r12, [r0, #Arreglo_tamanoElemento]     // Traigo t = tamaño de elementos a r12 (Sobreescribo porque ya no uso n)
    mul r1, r1, r12                            // Multiplico i*t y guardo en i  
    add r3, r1                                 // r3 = b+i*t (dirección donde escribiré)
    mov r1, #0                                 // Índice que va a recorrer la celda
0:
    cmp r1, r12                                // Comparo i con tamaño
    BHS 1f
    ldrb r0, [r3, r1]
    strb r0, [r2, r1]
    add r1, #1
    B 0b
1:
    mov r0, #0
    B 3f
2:
    mov r0, #-1
3:    
    bx lr
endfun Arreglo_lee

/**
 * @brief Escribe el valor proporcionado en el arreglo descrito
 * 
 * @param descriptor Descriptor de arreglo
 * @param indice Índice del elemento a escribir
 * @param origen Puntero a región conteniendo los datos a escribir
 * @return int 0 si efectuó la operación, -1 si no existe el elemento en el
 * arreglo
 */
defun Arreglo_escribe                          // r0 = *descriptor; r1 = índice; r2 = *origen
    ldr r12, [r0, #Arreglo_numElementos]       // Traigo n = n° de elementos
    cmp r1, r12                                // Comparo r1 = índice con n
    BHS 2f                                     // Si r1 >= n, salto 
    ldr r3, [r0, #Arreglo_base]                // Traigo b = base a r3
    ldr r12, [r0, #Arreglo_tamanoElemento]     // Traigo t = tamaño de elementos a r12 (Sobreescribo porque ya no uso n)
    mul r1, r1, r12                            // Multiplico i*t y guardo en i  
    add r3, r1                                 // r3 = b+i*t (dirección donde escribiré)
    mov r1, #0                                 // Índice que va a recorrer la celda
0:
    cmp r1, r12                                // Comparo i con tamaño
    BHS 1f
    ldrb r0, [r2, r1]
    strb r0, [r3, r1]
    add r1, #1
    B 0b
1:
    mov r0, #0
    B 3f
2:
    mov r0, #-1
3:    
    bx lr
endfun Arreglo_escribe

/**
 * @brief Intercambia los valores de dos elementos del arreglo
 * 
 * @param descriptor Descriptor de arreglo
 * @param indice_1 Primer índice
 * @param indice_2 Segundo índice
 * @return int 0 si tuvo exito, 1 si algún elemento no existe
 */
defun Arreglo_intercambia                     // r0 = *d, r1 = i, r2 = j
    push {r4-r5,lr}
    ldr r3, [r0, #Arreglo_numElementos]       // Traigo n = n° de elementos
    cmp r1, r3                                // Comparo r1 = i con n
    BHS 2f
    cmp r2, r3                                // Comparo r2 = j con n
    BHS 2f
    ldr r3, [r0, #Arreglo_base]                // Traigo b = base a r3
    ldr r12, [r0, #Arreglo_tamanoElemento] 
    mul r1, r1, r12
    add r4, r3, r1
    mul r2, r2, r12
    add r5, r3, r2
    mov r0, #0
0:
    cmp r0, r12                                // Comparo i con tamaño
    BHS 1f
    ldrb r1, [r4, r0]
    ldrb r2, [r5, r0]
    strb r1, [r5, r0]
    strb r2, [r4, r0]
    add r0, #1
    B 0b
1:
    mov r0, #0
    B 3f
2:
    mov r0, #-1
3:
    pop {r4-r5,pc}
endfun Arreglo_intercambia