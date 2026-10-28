ESQUIVAR METEORITOS
===================

Proyecto 2 - Arquitectura de Computadores
Estudiantes: Carlos Badilla, Esteban Oviedo, Bryan Valverde.

DESCRIPCION
Juego sencillo hecho en lenguaje ensamblador 8086 para EMU8086. El jugador
mueve una nave ("<A>") en la parte baja del marco y debe esquivar los
meteoritos que caen. Hay meteoritos horizontales (***) y cuadrados (2 x 2).

REQUISITOS
- EMU8086 (el programa se compila como archivo .COM, con #make_COM# y org 100h).

COMO EJECUTAR
1. Abrir el archivo ESQUIVAR.ASM en EMU8086.
2. Presionar "emulate" (compila el programa y abre el emulador) y luego "run".
3. Hacer clic en la ventana de pantalla del emulador para que reciba el teclado.
4. En el menu, presionar 1 para iniciar o 2 para salir.

CONTROLES
A o flecha izquierda : mover la nave a la izquierda (4 columnas por pulsacion).
D o flecha derecha   : mover la nave a la derecha (4 columnas por pulsacion).
P                    : pausar o continuar el juego.
ESC                  : volver al menu (durante el juego o en pausa).
1 / 2 (menu)         : iniciar el juego / salir.

REGLAS
- Se comienza con 3 vidas y 0 puntos.
- Cada meteorito que se esquiva suma 1 punto.
- Cada meteorito que choca con la nave resta 1 vida.
- Con 0 vidas aparece GAME OVER; al llegar a 10 puntos aparece GANASTE.
- En ambos casos, cualquier tecla regresa al menu.
- El record se conserva mientras el programa siga abierto.

ARCHIVOS
- ESQUIVAR.ASM : codigo fuente final del juego.
- README.txt   : este archivo.
- Informe tecnico: documento aparte (explicacion del juego, partes principales y pruebas).

REPOSITORIO GIT
- Enlace del repositorio: (agregar aqui el enlace del repositorio del grupo)
