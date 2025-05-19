

## Useful links

https://www.hackster.io/adam-taylor/using-chipscope-to-debug-amd-versal-designs-2a2fcd

https://fpgacpu.ca/fpga/index.html
https://link.springer.com/chapter/10.1007/978-3-319-22035-2_4

## DMA
https://ijirt.org/publishedpaper/IJIRT100876_PAPER.pdf



https://www.parallels.com/products/desktop/buy/?


## external communication

1. Introduc¸ao˜
A proposta do trabalho esta em cima da utilizac¸ ´ ao de uma interface serial como meio de ˜
comunicac¸ao entre processador e perif ˜ erico. Para que tal comunicac¸ ´ ao seja poss ˜ ´ıvel, e ne- ´
cessario que a interface serial, atrav ´ es de autobaud, detecte o clock do perif ´ erico para que ´
seja poss´ıvel enviar e receber dados deste. Alem disso, ´ e necess ´ ario uma l ´ ogica de cola ´
que mapeie certos enderec¸os de memoria do processador para o perif ´ erico. O controle da ´
comunicac¸ao˜ e realizado atrav ´ es de um software em c ´ odigo de m ´ aquina que tamb ´ em deve ´
ser produzido. Neste relatorio ser ´ ao descritos as implementac¸ ˜ oes do hardware e software ˜
dessa aplicac¸ao. ˜
2. Hardware
A implementac¸ao de hardware tem como objetivo a criac¸ ˜ ao de um componente de l ˜ ogica ´
de cola. A logica de cola ´ e respons ´ avel por mapear certas posic¸ ´ oes da mem ˜ oria em ac¸ ´ oes ˜
com o periferico. Os enderec¸os escolhidos n ´ ao s ˜ ao utilizados por nenhuma mem ˜ oria do ´
MIPS (dados ou de instruc¸oes) e s ˜ ao descritas a seguir. ˜
1. 0x10008000 : E utilizado para o tx ´ data, quando houver uma instruc¸ao de lbu ˜
(load byte unsigned) a logica de cola deve colocar no barramento de dados o valor ´
correspondente ao dado que o periferico enviou ao processador. ´
2. 0x10008001 : Indica se existe um dado dispon´ıvel no barramento tx data. Quando
houver uma instruc¸ao lbu, coloca-se no barramento de dados 1 , se h ˜ a um dado ou ´
0 se nao h ˜ a.´
3. 0x10008002 : Utilizado para enviar um dado ao periferico. Para uso deste ´ e ne- ´
cessario um registrador que armazene tal dado at ´ e que a operac¸ ´ ao de envio seja ˜
inciada.
4. 0x10008003 : Indica se existe um dado dispon´ıvel em rx data. Quando este recebe
1 , a operac¸ao de envio de dados ao perif ˜ erico inicia. ´
5. 0x10008004 : Indica se a interface serial esta ocupada ou n ´ ao atrav ˜ es de rx ´ busy
realizando um processo de envio de dados ao periferico. Fica em 1 desde rx ´ start
ate que termine de enviar. ´
A implementac¸ao da l ˜ ogica de cola foi feita atrav ´ es de duas m ´ aquinas de estados, uma ´ e´
responsavel pela operac¸ ´ ao de envio de dados ao perif ˜ erico, enquanto outra ´ e respons ´ avel ´
por receber dados do periferico. ´
3. Software
Inicialmente, como sera melhor descrito na sec¸ ´ ao˜ a respeito do perif ` erico, espera-se um ´
per´ıodo de tempo necessario para que a interface serial inicie sua comunicac¸ ´ ao com o ˜
periferico.Tal espera ´ e feita atrav ´ es de um lac¸o de repetic¸ ´ ao. ˜ A respeito do software, pode- `
se dividi-lo em duas partes sendo uma as rotinas de acionamento do periferico (envio e ´
recebimento de dados) e outra a aplicac¸ao. ˜
3.1. Rotinas
A comunicac¸ao entre perif ˜ erico e processador possui duas rotinas, que foram implementa- ´
das na forma de func¸oes seguindo os padr ˜ oes de implementac¸ ˜ ao da linguagem de monta- ˜
gem do MIPS, tais como utilizac¸ao de registradores de argumento e de retorno de func¸ ˜ ao. ˜
Para utilizar a rotina de envio de dados, primeiro e necess ´ ario armazenar um dado no ´
registrador de argumento a0. Esta rotina possui tres passos: ˆ
1. Verificar se a interface serial esta ocupada atrav ´ es de lbu rx ´ busy, se estiver tenta
novamente, senao pode continuar para o pr ˜ oximo passo. ´
2. Armazenar o dado provido pelo registrador de argumento atraves de sb rx ´ data
que deseja-se enviar ao periferico. ´
3. Armazenar o valor 1 atraves de sb rx ´ start para que o envio do dado do passo 2
seja inciado.
A rotina de recebimento de dados do periferico possui dois passos: ´
1. Verificar se a interface serial ja est ´ a pronta para mandar o dado atrav ´ es de lbu ´
tx av, se estiver pode continuar para o proximo passo, sen ´ ao tenta novamente. ˜
2. Ler o valor enviado do periferico atrav ´ es de lbu tx ´ data.
Apos ler o valor presente em tx ´ data, este valor e armazenado no registrador de retorno ´
de func¸ao e volta-se para a aplicac¸ ˜ ao. ˜
3.2. Aplicac¸ao˜
A aplicac¸ao modelada para este trabalho ˜ e simples, os passos desta s ´ ao descritos a seguir. ˜
1. Carregar dado 1 da memoria de dados. ´
2. Enviar dado 1 como argumento para a rotina de envio de dados.
3. Carregar dado 2 da memoria de dados. ´
4. Enviar dado 2 como argumento para a rotina de envio de dados.
5. Realizar a rotina de recebimento de dados.
6. Salvar o valor do registrador de retorno de func¸ao na mem ˜ oria de dados. ´
Em outras palavras, a aplicac¸ao˜ e:´
C = A + B (1)
4. Periferico ´
O periferico implementado no testbench do sistema ´ e uma m ´ aquina de estados simples ´
que segue os princ´ıpios da aplicac¸ao descrita no software. Recebe dois dados, soma-os e ˜
devolve o resultado ao processador. Um ponto importante a considerar e que a proposta do ´
periferico era que este tivesse uma frequ ´ encia significativamente menor que a do processa- ˆ
dor. Tal frequencia deveria ser entre 1200bps (bits por segundo) ate 115200 bps. Optou-se ´
pela frequencia mais alta (115200 bps) e calculou-se que para a transfer ˆ encia de cada bit ˆ
e necess ´ ario um per ´ ´ıodo de 8, 64us. Com proposito de simplificar a implementac¸ ´ ao do ˜
periferico, decidiu-se utilizar tal per ´ ´ıodo como o ciclo (clock) do mesmo. A comunicac¸ao˜
entre o periferico e a interface serial requer que o perif ´ erico envie o dado ´ 0x55 para a interface serial de modo que esta consiga calcular a velocidade com que o periferico envia ´
dados. Sobre o envio, ha duas peculiaridades que devem ser consideradas. Neste modelo ´
de comunicac¸ao, embora os dados sejam de um byte, enviam-se 2 bits extras que repre- ˜
sentam o inicio de um envio(bit 1) e o fim de um envio(bit 0). Outra ponto importante e´
que o envio dos dados e do bit menos significativo ao mais significativo. 
