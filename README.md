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
## Logica
A partir del codigo que se tenia, se realizaron los cambios correspondientes para implementarlo en la FPGA. El principal cambio fue en las salidas que son de 1 bit, además se estableció el tamaño de la pantalla con el que se iba trabajar, como se mencionó previamente será de 256x256. Finalmente se calcularon los parametros AW y DW a partir del tamaño de visualización establecido, para de esta forma cumplir con el requerimiento de memoria.
```
module test_VGA(
    input wire clk,           // board clock: 50 MHz
    input wire rst,         	// reset button

	// VGA input/output  
    output wire VGA_Hsync_n,  // horizontal sync output
    output wire VGA_Vsync_n,  // vertical sync output
    output wire VGA_R,	// 1-bit VGA red output
    output wire VGA_G,  // 1-bit VGA green output
    output wire VGA_B,  // 1-bit VGA blue output
    output wire clkout,  
 	
	// input/output
	
	
	input wire bntr,
	input wire bntl
		
);

// TAMAÑO DE visualización 
parameter CAM_SCREEN_X = 256;
parameter CAM_SCREEN_Y = 256;

localparam AW = 8; // LOG2(CAM_SCREEN_X*CAM_SCREEN_Y)
localparam DW = 3; //Numero de bits RGB

// El color es RGB 111
localparam RED_VGA =   3'b100;
localparam GREEN_VGA = 3'b010;
localparam BLUE_VGA =  3'b001;
```

Tambien es necesario asignar las salidas del VGA driver a cada una de las salidas designadas para cada color. Dado que el reloj de la pantalla es de 75MHz es necesario implementar un divisor de frecuencia, para aumentar la frecuencia proporcionada por el reloj de la FPGA que es de 50MHz.
```
assign VGA_R = data_RGB111[2];
	assign VGA_G = data_RGB111[1];
	assign VGA_B = data_RGB111[0];




assign clk50M=clk;
clock75 clk75(	
	.inclk0(clk50M),


divisor_de_frecuencia(
	.clk(clk75M),
	.clk_out(clkout)
);
```

Finalmente, se implemento la logica que permite visualizar en la VGA lo que esta en memoria, en este caso la logica usada establece que todo lo que este fuera del tamaño definido sea de color negro. Por otro lado, para usar una menor cantidad de memoria y como se mencionó previamente, solo se guardan en memoria 256 pixeles y lo que se hace para el resto de pixeles es repetir la lectura de la memoria. Esto se logra usando tan solo la variable 'VGA_posX' para indicar la dirección de memoria para la lectura, de esta forma se logra el objetivo de obtener franjas de diferentes colores.
```
always @ (VGA_posX, VGA_posY) begin
		if ((VGA_posX>CAM_SCREEN_X-1) || (VGA_posY>CAM_SCREEN_Y-1))
			DP_RAM_addr_out=0;
		else
			DP_RAM_addr_out=VGA_posX;
end
```
## Dificultades y superación de las mismas.
En un inicio la carga del blaster a la FPGA se hizo desde un computador de escritorio y no fue posible obtener la visualización; posteriormente tras haber revisado cada modificaición del código fue posible determinar que no era un problema del trabajo realizado; posteriormente se hizo la prueba pero ésta vez desde un computador portatil y todo corrió sin problema; es decir se concluye que existe un problema con la instalación de Quartus o alguna de sus extensiones en el primer equipo en el que fue probado.  A continuación se muestra el resultado final de la sección.

## Simulación
Para realizar la simulación, se tuvo en cuenta que la salida es RGB111 por lo tanto, dado que el simulador de Eric Eastwood es RGB322 lo que se hizo fue adicionar los bits adicionales correspondientes teniendo en cuenta que el bit mas signifcativo corresponderia a la salida RGB111, el codigo usado para lo descrito se observa a continuación.
```
	/*************************************************************************
			INICIO DE  GENERACION DE ARCHIVO test_vga	
	**************************************************************************/

	/* log para cargar de archivo*/
	integer f;
	initial begin
      f = $fopen("file_test_vga.txt","w");
   end
	
	reg clk_w =0;
	always #1 clk_w  = ~clk_w;

	initial forever begin
	@(posedge clk_w)
	
		
		$fwrite(f,"%0t ps: %b %b %b %b %b\n",$time,VGA_Hsync_n, VGA_Vsync_n, {VGA_R,2'b00},{VGA_G,2'b00},{VGA_B,1'b0});
		$display("%0t ps: %b %b %b %b %b\n",$time,VGA_Hsync_n, VGA_Vsync_n, {VGA_R,2'b00},{VGA_G,2'b00},{VGA_B,1'b0});
		
	end
```

A partir de concatenar la salida RGB111 con los bits adicionales se logra crear el archivo necesario para simular en linea la pantalla VGA. A continuación se muestra el resultado obtenido:
![Fig4](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/frame.png)
## Video Demostrativo
Se adjunta link del video donde se puede evidenciar el correcto funcionamiento de la pantalla VGA, demostrando que se hace envío de información y reset de la misma: https://youtu.be/CAzSEY2RYaQ


# Complemento de Laboratorio Final: Modificación de memoria desde MEF.
A partir del trabajo previamento mostrado y explicado se decidión proceder a llevar el laboratorio un paso más allá; en este sentido se tiene como objetivo escalar la visualización a toda la pantalla y además no sólo presentar los datos almacenados en memoria sino modificarlos mediante los periféricos de  la tarjeta Cyclone IV y poder visualizar éstos a medida que son cambiados.  Vale la pena mencionar que las consideraciones respecto a la memoria y la manera de representar los colores de forma RGB111 siguen en pie.

## Lógica de visualización.

Para solventar la decisión de mostrar en toda la pantalla se optó por proponer el uso de "pixeles aumentados"; ésto quiere decir, pintar en un cuadrado de 64 x 64 pixeles la información correspondiente a un solo lugar de memoria; de ésta forma y con el uso de dos registros auxiliares se planteó la lógica correspondiente. A 
continuación se observa la logica empleada.

![Fig1](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/Estrategia.png)

![Fig1](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/logicaprevia.png)

Como se observa en la figura, en este caso se hace la operación modulo para evaluar el cambio de cuadrado, y se hace uso de un if para aumentar el contador en caso de que no se haya superado el borde de la pantalla, si ya se supero se asigna 0. En la dirección de memoria se asigna el valor del pixel correspondiente.


Sin embargo al realizar la implementación, se obtuvieron los siguientes resultados:

![Fig1](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/ErrorVisualizacion.jpeg)

Como es claro a simple inspección, los resultados no son coherentes con los esperados. Tras revisar y corregir el código se evidencia que aunque la lógica era adecuada no era la forma más idónea de implmentarla pues se hacían muchas comparaciones y operaciones en muy poco tiempo haciendo que no existiera sincronización adecuada con el reloj; por lo tanto se procedio con una versión mejorada del código:

```
reg [AW-1:0] countx;
reg [AW-1:0] county;

localparam px_scale = 64;
localparam width = CAM_SCREEN_X/px_scale;
localparam height = CAM_SCREEN_Y/px_scale;

always @ (VGA_posX, VGA_posY) begin
	
	if(rst) begin
		countx=0;
		county=0;
	end
	
	countx=VGA_posX/px_scale;
	if(countx>=width) 
		countx = 0;
	
	county=VGA_posY/px_scale;
	if(county>=height) 
		county = 0;
	
	DP_RAM_addr_out = countx+county*width;
	
end
	
initial begin
	countx=0;
	county=0;
end
```

En este caso en lugar de realizar comparaciones para aumentar el valor del contador tanto x como en y, se hace uso de la posición tanto x como en y, diviendolas por el factor de escalamiento. De esta forma se logra obtener el resultado deseado, de tener pixeles aumentados de 64x64.


Así, se obtiene el resultado correspondiente al propuesto por el grupo como se muestra a continuación.

![Fig2](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/VisualizacionCorrecta.png)

## Implementación Digital Drawing

Como propuesta de proyecto se decidió realizar un codigo que permita pintar pixel a pixel en la pantalla. Para ello fue necesario implementar una serie de modificaciones al codigo ya descrito previamente. En primera instancia, se necesitaron dos entradas adicionales, una que sera para limpiar la pantalla (clr) y la otra entrada corresponde al color que se debe pintar en pantalla y guardar en memoria (switch). Además en este caso, se usara la pantalla completa pero usando la estrategia de pixeles aumentados que se describio previamente, esto con el fin de no exceder la memoria de la FPGA. 

![Fig6](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/entradas1.png)

En la figura, se observan los cambios implementados en el codigo para lograr este fin.

Ahora se ahondara en la logica que se sigue para realizar el dibujo, en este caso se usa una maquina de estados, que se instancia a partir del archivo FSM_game. En este caso se tiene un reloj, un reset, un clear para limpiar la pizarra y dos botones (in1 y in2). Además es necesario la entrada de la variable switch que indica el color y un registro adicional blocker que hará las veces de limitador de acciones. Finalmente se tienen como salidas la dirección en memoria, la información de dicha dirección y el enable de escritura.

![Fig7](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/entradas2.png)

Una vez definidas las entradas y las salidas, se realiza la implementación de un reloj propio para la realización del dibujo que permitiera realizar las acciones de manera secuenciales y controlada. Con esto se implementa la siguiente logica:


Como se observa en la figura, en el caso de que in1 este activo se asigna a la dirección de memoria (addr) el valor de un contador (count) el cual permite identificar/cambiar el pixel sobre el que se encuentra actualmente. Por otro lado, se implementa un switch case, que a partir de la entrada de los 3 bits que designan el color asigna el color correspondiente a la variable (data).

En el caso de que in2 este activo, este tan solo funciona como un cursor y lo que permite es ir moviendose a través de los pixeles de la pantalla.

En el caso de que clr este activo lo que hace es asignar en la posición actual el valor de 111 que corresponde al color blanco, funciona de borrador secuencial automático que hace su función con el reloj del juego (7Hz).

Finalmente con el rst se le asigna el valor del 0 al contador y se desactiva la escritura, esto hace que el cursor del motor de dibujo vuelva a la posición inicial (Esquina superior izquierda). 

Fué necesario el uso adicional del registro blocker para que por pulsación, de in1 o in2, se realizara una única vez la acción que desencadena cada uno de los pulsadores según el presionado.

La logica descrita previamente se observa a continuación:

![Fig7](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/logicajuego.png)

Por último, y como preambulo al video, se presentan las instrucciones de uso del motor de dibujo:

![Fig8](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/Instrucciones.png)

y las correspondientes asignaciones establecidas:

![Fig8](https://github.com/unal-edigital1-lab/wp01-2021-2-grupo03-2021-2/blob/main/figs/Asignaciones.png)

## Video del proyecto en funcionamiento

Se adjunta link del video donde se puede evidenciar el correcto funcionamiento del motor de dibujo, demostrando que su funcionamiento corresponde a las instrucciones definidas: https://youtu.be/yQmHipuTU-8
