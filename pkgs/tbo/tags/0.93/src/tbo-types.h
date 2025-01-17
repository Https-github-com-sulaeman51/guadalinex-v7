#ifndef __TBO_TYPES__
#define __TBO_TYPES__

#include <gtk/gtk.h>
#include <stdio.h>
#include <cairo.h>

typedef struct
{
    double r;
    double g;
    double b;
} Color;

typedef struct
{
    char title[255];
    int width;
    int height;
    GList *pages;

} Comic;

typedef struct
{
    Comic *comic;
    GList *frames;

} Page;

typedef struct
{
    int x;
    int y;
    int width;
    int height;
    gboolean border;
    Color *color;
    GList *objects;

} Frame;

enum TYPE
{
    SVGOBJ,
    TEXTOBJ,
};

struct tbo_object
{
    int x;
    int y;
    int width;
    int height;
    double angle;
    gboolean flipv;
    gboolean fliph;
    void (*free) (struct tbo_object *);
    void (*draw) (struct tbo_object *, Frame *, cairo_t *);
    void (*save) (struct tbo_object *, FILE *);
    struct tbo_object * (*clone) (struct tbo_object *);
    enum TYPE type;
    gpointer data;
};

typedef struct tbo_object tbo_object;

#endif

