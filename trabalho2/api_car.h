/*
  Self Driving Car Application Programming Interface
*/
#ifndef API_CAR_H
#define API_CAR_H
/******************************************************************************/
/*  MOTORES                                                                   */
/******************************************************************************/

/*
  Define os valores para o deslocamento vertical e horizontal do carro.
  Paramêtros:
  * vertical:   um byte que define o deslocamento vertical, entre -1 e 1.
                Valor -1 faz o carro andar para trás e 1 para frente
  * horizontal: define o valor para o deslocamento horizontal, entre -127 e 127.
                Valores negativos gera deslocamento para a direita e positivos
                para a esquerda.
  Retorna:
  * 0 em caso de sucesso.
  * -1 caso algum parametro esteja fora de seu intervalo.
*/
int set_motor(char vertical, char horizontal);


/*
  Aciona o freio de mão do carro.
  Paramêtros:
  * valor:  um byte que define se o freio será acionado ou não.
            1 para acionar o freio e 0 para não acionar.
  Retorna:
  * 0 em caso de sucesso.
  * -1 caso algum parametro esteja fora de seu intervalo .
*/
int set_handbreak(char valor);


/******************************************************************************/
/*  SENSORES                                                                  */
/******************************************************************************/

/*
  Lê os valores da camera de linha.
  Paramêtros:
  * img:  endereço de um vetor de 256 elementos que armazenará os
          valores lidos da camera de linha.
  Retorna:
    Nada
*/
void read_camera(unsigned char* img);


/*
  Lê a distancia do sensor ultrasônico
  Paramêtros:
    Nenhum
  Retorna:
    O inteiro com a distância do sensor, em centímetros.
*/
int read_sensor_distance(void);


/*
  Lê a posição aproximada do carro usano um dispositivo de GPS
  Parametros:
  * x:  endereço da variável que armazenará o valor da posição x
  * y:  endereço da variável que armazenará o valor da posição y
  * z:  endereço da variável que armazenará o valor da posição z
  Retorna:
    Nada
*/
void get_position(int* x, int* y, int* z);


/*
  Lê a rotação global do dispositivo de giroscópio
  Parametros:
  * x:  endereço da variável que armazenará o valor do angulo de Euler em x
  * y:  endereço da variável que armazenará o valor do angulo de Euler em y
  * z:  endereço da variável que armazenará o valor do angulo de Euler em z
  Retorna:
    Nada
*/
void get_rotation(int* x, int* y, int* z);


/******************************************************************************/
/*  TIMER                                                                     */
/******************************************************************************/

/*
  Lê o tempo do sistema
  Paramêtros:
    Nenhum
  Retorna:
    O tempo do sistema, em milisegundos.
*/
unsigned int get_time(void);

/******************************************************************************/
/*  Processamento de Imagem                                                   */
/******************************************************************************/

/*
  Filtra uma imagem unidimensional utilizando um filtro unidimensional (similar ao lab 6b, mas para apenas uma dimensão). 
  Paramêtros:
    img: array representando a imagem.
    filter: vetor de 3 posições representando o filtro 1D.
  Retorna:
    Nada
*/
void filter_1d_image(char * img, char * filter);



/*
  Mostra uma imagem 1D (1x256) no canvas. 
  Paramêtros:
    img: array representando a imagem.
  Retorna:
    Nada
*/
void display_image(char * img);


/*
  Para as funções abaixo, veja detalhes no Laboratório 7.
*/
void puts ( const char * str );
char * gets ( char * str );
int atoi (const char * str);
char *  itoa ( int value, char * str, int base );
void sleep(int ms);
int approx_sqrt(int x, int iterations);


#endif  /* API_CAR_H */
