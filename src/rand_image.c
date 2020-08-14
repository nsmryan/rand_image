#include "stdio.h"
#include "stdlib.h"

#include "log.h"
#include "lodepng.h"
#include "swill.h"


#define WIDTH 640
#define HEIGHT 640
#define TOTAL (WIDTH * HEIGHT)
#define HIDDEN (TOTAL / 10)

#define DEFAULT_IMAGE_NAME "test.png"


void handle_image(FILE *file_handle, void *user_data);

int main(int argc, char *argv[]) {
    (void)argc;
    (void)argv;

    uint32_t *image_u32 = (uint32_t*)malloc(TOTAL * sizeof(uint32_t));
    if (image_u32 == NULL) {
        printf("could not allocate image_u32!\n");
        exit(0);
    }

    for (uint32_t x = 0; x < WIDTH; x++) {
        for (uint32_t y = 0; y < HEIGHT; y++) {
            image_u32[x + y * WIDTH] = rand();
        }
    }

    swill_init(8080);
    swill_file("index.html", NULL);
    swill_handle(DEFAULT_IMAGE_NAME, handle_image, image_u32);

    while (1) {
        swill_serve();
    }

    swill_close();
}

void handle_image(FILE *file_handle, void *user_data) {
    uint32_t *image = (uint32_t*)user_data;

    unsigned char *png_ptr = NULL;
    size_t png_size = 0;

    lodepng_encode32(&png_ptr, &png_size, (unsigned char *)image, WIDTH, HEIGHT);

    fwrite((void*)png_ptr, png_size, 1, file_handle);
}

