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

# Video Demostrativo
Se adjunta link del video donde se puede evidenciar el correcto funcionamiento del proyecto, demostrando que se hace envío de información y reset de la misma: https://youtu.be/CAzSEY2RYaQ

