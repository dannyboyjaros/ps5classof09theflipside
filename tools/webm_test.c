/*
 * Host-side smoke test for src/webm.c.
 *
 *   cc -O2 -o webm_test tools/webm_test.c src/webm.c -lvpx -lvorbis -logg
 *   ./webm_test file.webm [frames.ppm] [audio.wav]
 */
#include "../src/webm.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int write_ppm(const char *path, const unsigned char *rgba, int width, int height) {
    FILE *file = fopen(path, "wb");
    int i;
    if (!file) {
        return 0;
    }
    fprintf(file, "P6\n%d %d\n255\n", width, height);
    for (i = 0; i < width * height; i++) {
        fwrite(rgba + i * 4, 1, 3, file);
    }
    fclose(file);
    return 1;
}

int main(int argc, char **argv) {
    WebmPlayer *player;
    const unsigned char *rgba = NULL;
    int width = 0;
    int height = 0;
    int serial = 0;
    double t;
    int frames = 0;

    if (argc < 2) {
        fprintf(stderr, "usage: %s file.webm [frames.ppm] [audio.wav]\n", argv[0]);
        return 1;
    }
    player = webm_open(argv[1]);
    if (!player) {
        fprintf(stderr, "cannot open %s\n", argv[1]);
        return 1;
    }
    printf("video=%d %dx%d audio=%d duration=%.3f\n", webm_has_video(player), webm_width(player),
           webm_height(player), webm_has_audio(player), webm_duration(player));
    for (t = 0.0; t < webm_duration(player) && frames < 60; t += 0.1) {
        if (webm_frame(player, t, &rgba, &width, &height, &serial)) {
            frames++;
            if (argc > 2 && frames == 10) {
                write_ppm(argv[2], rgba, width, height);
                printf("wrote %s (%dx%d)\n", argv[2], width, height);
            }
        }
    }
    printf("decoded %d frames, last %dx%d serial=%d\n", frames, width, height, serial);
    if (argc > 3) {
        if (webm_audio_to_wav(player, argv[3])) {
            printf("wrote %s\n", argv[3]);
        } else {
            fprintf(stderr, "audio decode failed\n");
        }
    }
    webm_close(player);
    return 0;
}
