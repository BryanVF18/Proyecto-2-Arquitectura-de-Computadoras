; Estudiantes:Carlos Badilla, Esteban Oviedo, Bryan Valverde.
; Curso: Arquitectura de Computadores.
; Proyecto2: Juego de ensamblador para EMU8086.

#make_COM#
org 100h

; Juego: Esquivar meteoritos
; La nave se mueve con las teclas A y D.
; El jugador debe evitar los meteoritos que aparecen en distintas posiciones.
; El programa muestra la puntuacion y las vidas durante la partida.
; La tecla P permite pausar o continuar el juego.

    jmp inicio

menuTexto db 13,10
          db 'ESQUIVAR METEORITOS',13,10,13,10
          db '1. Iniciar juego',13,10
          db '2. Salir',13,10
          db 'Elija una opcion: $'

instrucciones db 'ESQUIVAR METEORITOS',13,10
              db 'Flechas o A/D: mover la nave.',13,10
              db 'P: pausa. ESC: volver al menu.',13,10
              db 'Puntos:00  Record:00  Vidas:3$'

pausaTexto db 'PAUSA: P para continuar'

finTexto db 'GAME OVER',13,10
         db 'Presione una tecla para volver al menu.$'

victoriaTexto db 'GANASTE',13,10
              db 'Presione una tecla para volver al menu.$'

textoNave db '<A>'
espacios3 db '   '
espacios2 db '  '
estrellas3 db '***'
estrellas2 db '**'
barra db '|'

posicionNave db 39

filaM1 db 6
colM1 db 29
formaM1 db 0

filaM2 db 10
colM2 db 39
formaM2 db 1

filaM3 db 14
colM3 db 49
formaM3 db 0

ultimoTick dw 0
semilla dw 1

colActual db 0
formaActual db 0
filaActual db 0
caracterActual db 0
atributoActual db 0
filaBorde db 0

puntuacion db 0
mejorPuntaje db 0
vidas db 3
decenas db 0
unidades db 0

inicio:
    mov ax, cs
    mov ds, ax

menu:
    mov sp, 0FFFEh          ; restablece la pila (GAME OVER y GANASTE saltan aqui desde dentro de llamadas)
    mov ax, 0003h
    int 10h

    mov dx, offset menuTexto
    mov ah, 09h
    int 21h

    mov ah, 00h
    int 16h

    cmp al, '1'
    je empezar

    cmp al, '2'
    jne menu
    jmp salir               ; salto largo (je salir queda fuera del rango corto)

empezar:
    mov posicionNave, 39
    mov filaM1, 6
    mov filaM2, 10
    mov filaM3, 14
    mov puntuacion, 0
    mov vidas, 3

    call columnaAleatoria
    mov colM1, dl
    call formaAleatoria
    mov formaM1, al

    call columnaAleatoria
    mov colM2, dl
    call formaAleatoria
    mov formaM2, al

    call columnaAleatoria
    mov colM3, dl
    call formaAleatoria
    mov formaM3, al

    mov ah, 00h
    int 1Ah
    mov ultimoTick, dx

    call prepararPantalla
    call mostrarEstado

juego:
    ; Revisa el teclado continuamente
    mov ah, 01h
    int 16h
    jnz hayTecla
    jmp revisarReloj        ; salto largo

hayTecla:
    mov ah, 00h
    int 16h

    cmp al, 27
    jne noEsc
    jmp menu                ; salto largo
noEsc:

    cmp al, 'p'
    je irPausa

    cmp al, 'P'
    je irPausa

    cmp ah, 4Bh
    je izquierda

    cmp ah, 4Dh
    je derecha

    cmp al, 'a'
    je izquierda

    cmp al, 'A'
    je izquierda

    cmp al, 'd'
    je derecha

    cmp al, 'D'
    je derecha

    jmp revisarReloj

irPausa:
    jmp pausa               ; salto largo

izquierda:
    cmp posicionNave, 19
    jbe revisarReloj

    call borrarNave
    sub posicionNave, 4

    cmp posicionNave, 19
    jae naveIzquierdaLista

    mov posicionNave, 19

naveIzquierdaLista:
    call dibujarNave
    jmp revisarReloj

derecha:
    cmp posicionNave, 58
    jae revisarReloj

    call borrarNave
    add posicionNave, 4

    cmp posicionNave, 58
    jbe naveDerechaLista

    mov posicionNave, 58

naveDerechaLista:
    call dibujarNave

revisarReloj:
    mov ah, 00h
    int 1Ah
    cmp dx, ultimoTick
    jne tickNuevo
    jmp juego               ; salto largo (el corto quedaba al limite del rango)

tickNuevo:
    mov ultimoTick, dx

    call moverM1
    call moverM2
    call moverM3

    ; Repinta los tres meteoritos: si dos quedan en filas contiguas,
    ; el borrado de uno no deja huecos en el otro.
    call dibujarM1
    call dibujarM2
    call dibujarM3

    jmp juego

pausa:
    mov dh, 4
    mov dl, 30
    mov bp, offset pausaTexto
    mov cx, 23
    mov bl, 0Fh
    call imprimirTexto

esperarPausa:
    mov ah, 00h
    int 16h

    cmp al, 27
    jne pausaNoEsc
    jmp menu                ; salto largo
pausaNoEsc:

    cmp al, 'p'
    je continuarJuego

    cmp al, 'P'
    jne esperarPausa

continuarJuego:
    mov ah, 02h
    mov bh, 00h
    mov dh, 4
    mov dl, 30
    int 10h

    mov ah, 09h
    mov al, ' '
    mov bh, 00h
    mov bl, 07h
    mov cx, 23
    int 10h

    mov ah, 00h
    int 1Ah
    mov ultimoTick, dx

    jmp juego

prepararPantalla:
    mov ax, 0003h
    int 10h

    mov dx, offset instrucciones
    mov ah, 09h
    int 21h

    call dibujarMarco
    call dibujarM1
    call dibujarM2
    call dibujarM3
    call dibujarNave

    ret

dibujarMarco:
    ; Borde superior
    mov ah, 02h
    mov bh, 00h
    mov dh, 5
    mov dl, 18
    int 10h

    mov ah, 09h
    mov al, '-'
    mov bh, 00h
    mov bl, 07h
    mov cx, 44
    int 10h

    ; Borde inferior
    mov ah, 02h
    mov bh, 00h
    mov dh, 20
    mov dl, 18
    int 10h

    mov ah, 09h
    mov al, '-'
    mov bh, 00h
    mov bl, 07h
    mov cx, 44
    int 10h

    ; Lados del marco
    mov filaBorde, 6

marcoLados:
    mov dh, filaBorde
    mov dl, 18
    mov bp, offset barra
    mov cx, 1
    mov bl, 07h
    call imprimirTexto

    mov dh, filaBorde
    mov dl, 61
    mov bp, offset barra
    mov cx, 1
    mov bl, 07h
    call imprimirTexto

    inc filaBorde
    cmp filaBorde, 20
    jne marcoLados

    ret

dibujarNave:
    mov dh, 18
    mov dl, posicionNave
    mov bp, offset textoNave
    mov cx, 3
    mov bl, 0Ah
    call imprimirTexto
    ret

borrarNave:
    mov dh, 18
    mov dl, posicionNave
    mov bp, offset espacios3
    mov cx, 3
    mov bl, 07h
    call imprimirTexto
    ret

dibujarM1:
    mov dh, filaM1
    mov dl, colM1
    mov bl, formaM1
    mov al, '*'
    mov ah, 0Ch
    call pintarForma
    ret

dibujarM2:
    mov dh, filaM2
    mov dl, colM2
    mov bl, formaM2
    mov al, '*'
    mov ah, 0Ch
    call pintarForma
    ret

dibujarM3:
    mov dh, filaM3
    mov dl, colM3
    mov bl, formaM3
    mov al, '*'
    mov ah, 0Ch
    call pintarForma
    ret

borrarM1:
    mov dh, filaM1
    mov dl, colM1
    mov bl, formaM1
    mov al, ' '
    mov ah, 07h
    call pintarForma
    ret

borrarM2:
    mov dh, filaM2
    mov dl, colM2
    mov bl, formaM2
    mov al, ' '
    mov ah, 07h
    call pintarForma
    ret

borrarM3:
    mov dh, filaM3
    mov dl, colM3
    mov bl, formaM3
    mov al, ' '
    mov ah, 07h
    call pintarForma
    ret

pintarForma:
    mov filaActual, dh
    mov colActual, dl
    mov formaActual, bl
    mov caracterActual, al
    mov atributoActual, ah

    cmp formaActual, 0
    jne pintarCuadro

    ; Meteorito horizontal: ***
    mov dh, filaActual
    mov dl, colActual
    mov cx, 3
    mov bl, atributoActual

    cmp caracterActual, '*'
    jne borrarHorizontal

    mov bp, offset estrellas3
    jmp escribirHorizontal

borrarHorizontal:
    mov bp, offset espacios3

escribirHorizontal:
    call imprimirTexto
    ret

pintarCuadro:
    ; Primera fila del meteorito 2 x 2
    mov dh, filaActual
    mov dl, colActual
    mov cx, 2
    mov bl, atributoActual

    cmp caracterActual, '*'
    jne borrarPrimeraFila

    mov bp, offset estrellas2
    jmp escribirPrimeraFila

borrarPrimeraFila:
    mov bp, offset espacios2

escribirPrimeraFila:
    call imprimirTexto

    ; Segunda fila del meteorito 2 x 2
    mov dh, filaActual
    inc dh
    mov dl, colActual
    mov cx, 2
    mov bl, atributoActual

    cmp caracterActual, '*'
    jne borrarSegundaFila

    mov bp, offset estrellas2
    jmp escribirSegundaFila

borrarSegundaFila:
    mov bp, offset espacios2

escribirSegundaFila:
    call imprimirTexto
    ret

moverM1:
    call borrarM1
    inc filaM1

    cmp formaM1, 1
    je revisarFilaCuadroM1

    cmp filaM1, 18
    jae revisarChoqueM1
    jmp dibujarM1          ; salto largo

revisarFilaCuadroM1:
    cmp filaM1, 17
    jae revisarChoqueM1
    jmp dibujarM1          ; salto largo

revisarChoqueM1:
    mov al, colM1
    mov bl, formaM1
    call revisarChoque
    cmp al, 1
    je golpeM1

    call sumarPunto
    call reiniciarM1
    ret

golpeM1:
    dec vidas
    call mostrarEstado
    cmp vidas, 0
    jne seguirM1
    jmp gameOver            ; salto largo

seguirM1:
    call reiniciarM1
    ret

reiniciarM1:
    mov filaM1, 6
    call columnaAleatoria
    mov colM1, dl
    call formaAleatoria
    mov formaM1, al
    call dibujarM1
    ret

moverM2:
    call borrarM2
    inc filaM2

    cmp formaM2, 1
    je revisarFilaCuadroM2

    cmp filaM2, 18
    jae revisarChoqueM2
    jmp dibujarM2          ; salto largo

revisarFilaCuadroM2:
    cmp filaM2, 17
    jae revisarChoqueM2
    jmp dibujarM2          ; salto largo

revisarChoqueM2:
    mov al, colM2
    mov bl, formaM2
    call revisarChoque
    cmp al, 1
    je golpeM2

    call sumarPunto
    call reiniciarM2
    ret

golpeM2:
    dec vidas
    call mostrarEstado
    cmp vidas, 0
    jne seguirM2
    jmp gameOver            ; salto largo

seguirM2:
    call reiniciarM2
    ret

reiniciarM2:
    mov filaM2, 10
    call columnaAleatoria
    mov colM2, dl
    call formaAleatoria
    mov formaM2, al
    call dibujarM2
    ret

moverM3:
    call borrarM3
    inc filaM3

    cmp formaM3, 1
    je revisarFilaCuadroM3

    cmp filaM3, 18
    jae revisarChoqueM3
    jmp dibujarM3          ; salto largo

revisarFilaCuadroM3:
    cmp filaM3, 17
    jae revisarChoqueM3
    jmp dibujarM3          ; salto largo

revisarChoqueM3:
    mov al, colM3
    mov bl, formaM3
    call revisarChoque
    cmp al, 1
    je golpeM3

    call sumarPunto
    call reiniciarM3
    ret

golpeM3:
    dec vidas
    call mostrarEstado
    cmp vidas, 0
    jne seguirM3
    jmp gameOver            ; salto largo

seguirM3:
    call reiniciarM3
    ret

reiniciarM3:
    mov filaM3, 14
    call columnaAleatoria
    mov colM3, dl
    call formaAleatoria
    mov formaM3, al
    call dibujarM3
    ret

revisarChoque:
    mov colActual, al
    mov formaActual, bl

    mov al, posicionNave
    add al, 2
    cmp colActual, al
    ja noHayChoque

    mov al, colActual
    cmp formaActual, 1
    je anchoCuadro

    add al, 2
    jmp revisarBordeIzquierdo

anchoCuadro:
    inc al

revisarBordeIzquierdo:
    cmp al, posicionNave
    jb noHayChoque

    mov al, 1
    ret

noHayChoque:
    mov al, 0
    ret

sumarPunto:
    inc puntuacion

    mov al, puntuacion
    cmp al, mejorPuntaje
    jbe mostrarPuntos

    mov mejorPuntaje, al

mostrarPuntos:
    call mostrarEstado

    cmp puntuacion, 10
    jb seguirJugando
    jmp victoria            ; salto largo

seguirJugando:
    ret

siguienteAleatorio:
    ; Generador congruencial lineal de 16 bits: semilla = semilla * 25173 + 13849
    ; Devuelve el numero en AX (usa BX y DX).
    mov ax, semilla
    mov bx, 25173
    mul bx
    add ax, 13849
    mov semilla, ax
    ret

columnaAleatoria:
    ; Devuelve en DL una columna entre 19 y 58
    mov ah, 00h
    int 1Ah
    xor semilla, dx         ; mezcla el reloj para que cada partida sea distinta
    call siguienteAleatorio

    xor dx, dx
    mov bx, 40
    div bx

    add dl, 19
    ret

formaAleatoria:
    ; Devuelve en AL la forma: 0 = horizontal (***), 1 = cuadro (2 x 2)
    call siguienteAleatorio
    mov al, ah
    and al, 1
    ret

mostrarEstado:
    ; Puntos
    mov al, puntuacion
    call convertirNumero

    mov dh, 3
    mov dl, 7
    mov al, decenas
    mov bl, 0Fh
    call ponerCaracter

    mov dh, 3
    mov dl, 8
    mov al, unidades
    mov bl, 0Fh
    call ponerCaracter

    ; Record
    mov al, mejorPuntaje
    call convertirNumero

    mov dh, 3
    mov dl, 18
    mov al, decenas
    mov bl, 0Fh
    call ponerCaracter

    mov dh, 3
    mov dl, 19
    mov al, unidades
    mov bl, 0Fh
    call ponerCaracter

    ; Vidas
    mov dh, 3
    mov dl, 28
    mov al, vidas
    add al, '0'
    mov bl, 0Fh
    call ponerCaracter

    ret

convertirNumero:
    xor ah, ah
    mov bl, 10
    div bl

    add al, '0'
    mov decenas, al

    mov al, ah
    add al, '0'
    mov unidades, al
    ret

ponerCaracter:
    push ax
    push bx
    push cx
    push dx

    mov ah, 02h
    mov bh, 00h
    int 10h

    mov ah, 09h
    mov bh, 00h
    mov cx, 1
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret

imprimirTexto:
    push ax
    push bx
    push cx
    push dx
    push bp
    push es

    mov ax, ds
    mov es, ax

    mov ah, 13h
    mov al, 01h
    mov bh, 00h
    int 10h

    pop es
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

gameOver:
    mov ax, 0003h
    int 10h

    mov dx, offset finTexto
    mov ah, 09h
    int 21h

    mov ah, 00h
    int 16h
    jmp menu

victoria:
    mov ax, 0003h
    int 10h

    mov dx, offset victoriaTexto
    mov ah, 09h
    int 21h

    mov ah, 00h
    int 16h
    jmp menu

salir:
    mov ax, 4C00h
    int 21h