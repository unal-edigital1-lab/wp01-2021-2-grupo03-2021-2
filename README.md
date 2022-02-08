# WP01
# Lab05 - Proyecto- Prueba Buffer Memoria y test VGA

* Ana Isabella Goyeneche Fonseca 1.192.793.310
* Diego Andrés Quintero Rois 1.003.243.161
* Oscar Santiago Suarez Aguilar 1.003.822.596

## Preguntas Introductorias.
 
 ** Pregunta 1: ¿Cuál es el tamaño máximo de buffer de memoria que puede crear, acorde a la FPGA?, Contraste este resultado con la memoria necesaria par la la visualización en un pantalla VGA 640 X 480 de RGB444, y compruebe si es posible dejando el 50 % libre de la memoria **

 La información disponible respecto al espacio de memoria disponible en la FPGA(Cyclone IV FPGA EP4CE6E22C8N) usada es que cuenta con 414 kbits, así las cosas y teniendo en cuenta que la memoría requerida para una pantalla RGB444 de 640x480 corresponde a:

                        
                           640 X 480 X 12 = 3686400 bits / 1024 = 3600 kbits

Resulta evidente que es insuficiente la memoria buffer de la FPGA utilizada para la representación VGA-RGB de 4 bits para una resolución tan amplia, y mucho menos es posible tener la mitad de la memoria libre.

 ** Pregunta 2: Revise el datasheet de la Tarjeta de desarrollo que usted esta usando y compruebe el pinout neceario para la implementación ¿Debe realizar algún cambio en el apartado anterior y que criterios debe tener en cuanta para ello?.

 Al revisar la documentación desponible se obtiene la siguiente información referente al pin-out VGA:

    - Red   PIN_2
    - Green PIN_1
    - Blue  PIN_144
    - VS    PIN_143
    - HS    PIN_142

Así, resulta claro que el planteamiento inicial es erroneo, pues la FPGA hace representación RGB111 y no RGB444 como se había supuesto, por lo que ahora hay que re-evaluar la memoria requerida, entendiendo que ahora es menor pues no se usan 12 bits para el color, si no, solo 3 bits.

Por lo tanto si quiere hacer la representación VGA RGB111 sin cambiar la resolución, se tendría que la FPGA debe contar con una memoria disponible de:

                                *640 X 480 X 3 = 921600 bits / 1024 = 900 kbits*

Es de nuevo notorio que la resolución tan grande sigue siendo impedimento para el adecuado almacenamiento de la información que se desea proyectar.

 ** Pregunta 3:¿Usted qué estrategia propone usar para modificar el uso de RAM considerando para la posible futura implementación de la FSM del juego?.

 Partiendo del hecho de que se procura usar solamente la mitad de la memoria disponible, es decir, que sólo se usaran 207 kbits y que, la representación RGB111 es inmodificable pues ya está delimitada por la capacidad del Hardware, se tiene que:

                                     *Resolución de Pantalla = 207 * 1024/3*
                                        *width X height    =    70656 bits*

Así pues, por facilidad, se decide proceder con una pantalla cuadrada, por lo que:

                                   *width = height  = SQRT(70656)*
                                                   *=  265, 811 pixels*

Ahora, como no existen pixeles decimales y teniendo en cuenta que 256 es potencia binaria y cumple con el objetivo de mantener la memoria y es muy cercano al calculo mostrado, se procede con éste valor.

                                *Se define  width = height = 256 pixeles* 




## VGA driver.
Parte muy importante del laboratorio consistió en adecuar el software de acuerdo al hardware disponible, tras conseguir un monitor VGA se procedió a revisar el código VGA_driver y actualizar que sus parámetros de forma adecuada de acuerdo a la pantalla adquirida teniendo en cuenta que la misma por referencia correspondía a una de 15 pulgadas TFT LCD visualización 0.297 mm, Dot pitch 1024 x 768 @ 60 Hz, con Máxima resolución
30 – 61 kHz frecuencia de 56 – 76 Hz vertical y frecuencia horizontal de contraste de 450: 1.

Por lo tanto, los cambios reflejados en éste archivo corresponden a la actualización teniendo usando como fuente de consulta la página http://tinyvga.com/vga-timing/1024x768@70Hz tal como fue indicado. 

## Archivo fuente para almacenamiento de información.
En el top del proyecto test_VGA se encuentra la instanciación del buffer ram que almacena la representación de pixeles que como grupo decidimos pintar y que obtiene a partir del archivo "image.men". La estrategia de la escritura de éste corresponde al deseo del deseo de dibujar lineas verticales en la pantalla las cuales de izquierda a derecha van, cambiando su color RGB progresivamente y repetetivamente así:

RGB
000 --> Negro
001 --> Azul
010 --> Verde
011 --> Cian
100 --> Rojo
101 --> Violeta
110 --> Amarillo
111 --> Blanco

La anterior secuencia se contruyó repetitivamente en una representación de 256 líneas, ésto corresponde a que como se planeó pintar lineas no era necesario extenderse en dicha pixel a pixel, si no, mas bien desde la lógica de pixel empleada en la instanciación redirigir la lectura a los valores ya explicados. Vale la pena mencionar que por facilidad la construcción del archivo se hizo en excel y desde ahí se exportó a su forma final que se puede encontrar en la carpeta fuente.

## Dificultades y superación de las mismas.
En un inicio la carga del blaster a la FPGA se hizo desde un computador de escritorio y no fue posible obtener la visualización; posteriormente tras haber revisado cada modificaición del código fue posible determinar que no era un problema del trabajo realizado; posteriormente se hizo la prueba pero ésta vez desde un computador portatil y todo corrió sin problema; es decir se concluye que existe un problema con la instalación de Quartus o alguna de sus extensiones en el primer equipo en el que fue probado.  A continuación se muestra el resultado final de la sección.

##Simulación
Para realizar la simulación, se tuvo en cuenta que la salida es RGB111 por lo tanto, dado que el simulador de Eric Eastwood es RGB322 lo que se hizo fue adicionar los bits adicionales correspondientes teniendo en cuenta que el bit mas signifcativo corresponderia a la salida RGB111, el codigo usado para lo descrito se observa a continuación.
![Fig3](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/testbench.png)

A partir de concatenar la salida RGB111 con los bits adicionales se logra crear el archivo necesario para simular en linea la pantalla VGA. A continuación se muestra el resultado obtenido:
![Fig4](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/frame.png)
## Video Demostrativo
Se adjunta link del video donde se puede evidenciar el correcto funcionamiento del proyecto, demostrando que se hace envío de información y reset de la misma: https://youtu.be/CAzSEY2RYaQ


# Complemento de Laboratorio Final: Modificación de memoria desde MEF.
A partir del trabajo previamento mostrado y explicado se decidión proceder a llevar el laboratorio un paso más allá; en este sentido se tiene como objetivo escalar la visualización a toda la pantalla y además no sólo presentar los datos almacenados en memoria sino modificarlos mediante los periféricos de  la tarjeta Cyclone IV y poder visualizar éstos a medida que son cambiados.  Vale la pena mencionar que las consideraciones respecto a la memoria y la manera de representar los colores de forma RGB111 siguen en pie.

## Lógica de visualización.

Para solventar la decisión de mostrar en toda la pantalla se optó por proponer el uso de "pixeles aumentados"; ésto quiere decir, pintar en un cuadrado de 32 x 32 pixeles la información correspondiente a un solo lugar de memoria; de ésta forma y con el uso de dos registros auxiliares se planteó la lógica correspondiente a través de la cual se obtuevieron los resultados mostrados a continuación.

SI SE QUIERE AQUI PONER LA LOGICA QUE HICIMOS Y NO SIRVIO :,U

![Fig1](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/ErrorVisualizacion.jpeg)

Como es claro a simple inspección, los resultados no son coherentes con los esperados. Tras revisar y corregir el código se evidencia que aunque la lógica era adecuada no era la forma más idónea de implmentarla pues se hacían muchas comparaciones y operaciones en muy poco tiempo haciendo que no existiera sincronización adecuada con el reloj; por lo tanto se procedio con una versión mejorada del código:

SI SE QUIERE AQUI PONER LA LOGICA QUE EL PROFE AYUDÓ :,U 

Así, se obtiene el resultado correspondiente al propuesto por el grupo como se muestra a continuación.

![Fig2](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/VisualizacionCorrecta.png)




