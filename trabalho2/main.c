int set_motor(int vertical, int horizontal);
void read_camera(unsigned char* img);
void filter_1d_image(unsigned char * img, char * filter);
void display_image(unsigned char * img);

#define SENSOR_SIZE 256

unsigned char light_sensor_buffer[SENSOR_SIZE];
char *print_buffer[256];

/* Lê e filtra camera do carro */
void my_read_sensors(unsigned char *sensor_values)
{
    char kernel[] = {-2, 5, -2};
    read_camera(light_sensor_buffer);
    filter_1d_image(light_sensor_buffer, kernel);
    // display_image(light_sensor_buffer); // Apenas para debug, pode gerar um atraso considerável
}

/* A partir do meio da faixa de sensores, ele procura o primeiro sensor que 
tiver valor acima de THRESHOLD tanto a esquerda quanto a direita, então retorna 
a média entre eles.
Depende de que o meio do sensor já esteja na faixa */
const int THRESHOLD = 180;
int dist_meio()
{
    my_read_sensors(light_sensor_buffer);

    int left;
    int right;
    int i;
    for (i = 255 / 2; i >= 0; i--)
    {
        if (light_sensor_buffer[i] > THRESHOLD)
            break;
    }
    left = i;

    for (i = 255 / 2; i < 256; i++)
    {
        if (light_sensor_buffer[i] > THRESHOLD)
            break;
    }
    right = i;

    return ((right + left) / 2);
}

// Garante que x esteja entre min e max, trunca x se necessário
int clamp(int x, int min, int max)
{
    if (x > max)
        x = max;
    else if (x < min)
        x = min;
    return x;
}

// É um controle PID, sem a parte integrativa
int PID(int target)
{
    static int last_error = 0;
    int proportional;
    int derivative;
    int pid;
    const int Kp_num = 28; // Numerador da constante proporcional
    const int Kp_den = 10; // Denominador da constante proporcional
    const int Kd_num = 5;  // Numerador da constante derivativa
    const int Kd_den = 10; // Denominador da constante derivativa
    int erro;

    erro = dist_meio() - target;
    proportional = erro * Kp_num;
    proportional = proportional / Kp_den;

    derivative = (erro - last_error) * Kd_num;
    derivative = derivative / Kd_den;

    pid = clamp(proportional + derivative, -127, 127);
    last_error = erro;
    return pid;
}

int main(void)
{
    const int target = SENSOR_SIZE / 2; // Alvo para o PID tentar seguir (meio do sensor)

    /* Liga o motor momentaneamente, e em seguida o desliga, apenas movimentando
    o volante */
    while (1)
    {
        set_motor(1, PID(target));
        for (int i = 0; i < 7; i++)
        {
            set_motor(0, PID(target));
        }
    }
}
