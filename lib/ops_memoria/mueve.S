.syntax unified
.cpu cortex-m3
.thumb


.text

/**
 * @brief Copia los tamano valores desde origen a destino, si la memoria de
 * destino se solapa con la de origen al final destino tiene que tener la copia
 * completa de los datos (y en ese caso origen no la tendrá más)
 * 
 * @param destino puntero a base (menor dirección) de la región de destino
 * @param origen puntero a base de la región de origen
 * @param tamano tamano de las regiones
 */

    .type mueveMemoria, %function
    .global mueveMemoria
mueveMemoria:
    mov r12, #0         // r12 = índice
    cmp r0, r1          // r0 = destino, r1 = origen, r2 = tamaño
    BGT 1f              // si r0 > r1 ---> 1
0:
    cmp r12, r2
    BGE 3f                   // si r12 >= r2 ----> 3
    ldrb r3, [r1, r12]
    strb r3, [r0, r12]
    add r12, #1
    B 0b
1:
    add r12,r2, #-1
2:    
    cmp r12, #0
    BLT 3f                  // si r2 < 0 ----> 3
    ldrb r3, [r1, r12]
    strb r3, [r0, r12]
    add r12, #-1
    B 2b
3:
    bx lr       // Retorna
    .size mueveMemoria, . - mueveMemoria

