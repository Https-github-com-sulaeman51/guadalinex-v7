#include <gtk/gtk.h>
#include <gdk/gdkkeysyms.h>
#include <cairo.h>
#include <math.h>
#include "selector-tool.h"
#include "tbo-window.h"
#include "page.h"
#include "frame.h"
#include "comic.h"
#include "ui-drawing.h"

#define R_SIZE 10

typedef struct
{
    double r;
    double g;
    double b;
} Color;

static Frame *SELECTED = NULL;
static int START_X=0, START_Y=0;
static int START_M_X=0, START_M_Y=0;
static int START_M_W=0, START_M_H=0;
gboolean CLICKED = FALSE;
gboolean OVER_RESIZER = FALSE;
gboolean RESIZING = FALSE;
GtkWidget *SPIN_W = NULL;
GtkWidget *SPIN_H = NULL;
GtkWidget *SPIN_X = NULL;
GtkWidget *SPIN_Y = NULL;


gboolean
update_selected_cb (GtkSpinButton *widget, TboWindow *tbo)
{
    if (RESIZING || CLICKED || SELECTED == NULL || SPIN_X == NULL)
        return FALSE;

    SELECTED->x = gtk_spin_button_get_value_as_int (GTK_SPIN_BUTTON (SPIN_X));
    SELECTED->y = gtk_spin_button_get_value_as_int (GTK_SPIN_BUTTON (SPIN_Y));
    SELECTED->width = gtk_spin_button_get_value_as_int (GTK_SPIN_BUTTON (SPIN_W));
    SELECTED->height = gtk_spin_button_get_value_as_int (GTK_SPIN_BUTTON (SPIN_H));

    update_drawing (tbo);
    return FALSE;
}

GtkWidget *add_spin_with_label (GtkWidget *toolarea, const char *string, int value)
{
        GtkWidget *label;
        GtkWidget *spin;
        GtkObject *adjustment;
        GtkWidget *hpanel;

        hpanel = gtk_hbox_new (FALSE, 0);
        label = gtk_label_new (string);
        gtk_misc_set_alignment (GTK_MISC (label), 0, 0);
        adjustment = gtk_adjustment_new (value, 0, 10000, 1, 1, 0);
        spin = gtk_spin_button_new (GTK_ADJUSTMENT (adjustment), 1, 0);
        gtk_box_pack_start (GTK_BOX (hpanel), label, TRUE, TRUE, 5);
        gtk_box_pack_start (GTK_BOX (hpanel), spin, TRUE, TRUE, 5);
        gtk_box_pack_start (GTK_BOX (toolarea), hpanel, FALSE, FALSE, 5);

        return spin;
}

void
empty_tool_area (TboWindow *tbo)
{
    tbo_empty_tool_area (tbo);
    SPIN_X = NULL;
    SPIN_Y = NULL;
    SPIN_H = NULL;
    SPIN_W = NULL;
}

void
update_tool_area (TboWindow *tbo)
{
    GtkWidget *toolarea = tbo->toolarea;

    if (!SPIN_X)
    {
        empty_tool_area (tbo);
        SPIN_X = add_spin_with_label (toolarea, "x: ", SELECTED->x);
        SPIN_Y = add_spin_with_label (toolarea, "y: ", SELECTED->y);
        SPIN_W = add_spin_with_label (toolarea, "w: ", SELECTED->width);
        SPIN_H = add_spin_with_label (toolarea, "h: ", SELECTED->height);

        g_signal_connect (SPIN_X, "value-changed", G_CALLBACK (update_selected_cb), tbo);
        g_signal_connect (SPIN_Y, "value-changed", G_CALLBACK (update_selected_cb), tbo);
        g_signal_connect (SPIN_W, "value-changed", G_CALLBACK (update_selected_cb), tbo);
        g_signal_connect (SPIN_H, "value-changed", G_CALLBACK (update_selected_cb), tbo);

        gtk_widget_show_all (toolarea);
    }

    gtk_spin_button_set_value (GTK_SPIN_BUTTON (SPIN_X), SELECTED->x);
    gtk_spin_button_set_value (GTK_SPIN_BUTTON (SPIN_Y), SELECTED->y);
    gtk_spin_button_set_value (GTK_SPIN_BUTTON (SPIN_W), SELECTED->width);
    gtk_spin_button_set_value (GTK_SPIN_BUTTON (SPIN_H), SELECTED->height);
}

void
set_selected (Frame *frame, TboWindow *tbo)
{
    SELECTED = frame;
    empty_tool_area (tbo);
    if (SELECTED != NULL)
        update_tool_area (tbo);
}

gboolean
over_resizer (Frame *frame, int x, int y)
{
    int rx, ry;
    rx = frame->x + frame->width;
    ry = frame->y + frame->height;

    if (((rx-R_SIZE) < x) &&
        ((rx+R_SIZE) > x) &&
        ((ry-R_SIZE) < y) &&
        ((ry+R_SIZE) > y))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

void
selector_tool_on_select (TboWindow *tbo)
{}

void
selector_tool_on_unselect (TboWindow *tbo)
{}

void
selector_tool_on_move (GtkWidget *widget,
        GdkEventMotion *event,
        TboWindow *tbo)
{
    int x, y, offset_x, offset_y;

    x = (int)event->x;
    y = (int)event->y;

    if (SELECTED != NULL)
    {
        if (CLICKED)
        {
            offset_x = (START_X - x);
            offset_y = (START_Y - y);

            // resizing frame
            if (RESIZING)
            {
                SELECTED->width = abs (START_M_W - offset_x);
                SELECTED->height = abs (START_M_H - offset_y);

                update_tool_area (tbo);
            }
            // moving frame
            else
            {
                SELECTED->x = START_M_X - offset_x;
                SELECTED->y = START_M_Y - offset_y;

                update_tool_area (tbo);
            }
        }

        // over resizer
        if (over_resizer (SELECTED, x, y))
        {
            OVER_RESIZER = TRUE;
        }
        else
        {
            OVER_RESIZER = FALSE;
        }
    }
}

void
frame_view_on_click (GtkWidget *widget, GdkEventButton *event, TboWindow *tbo) {}

void
frame_view_drawing (cairo_t *cr){}

void
frame_view_on_key (GtkWidget *widget, GdkEventKey *event, TboWindow *tbo)
{
    if (SELECTED != NULL && event->keyval == GDK_Escape)
    {
        set_frame_view (NULL);
    }
}

void
page_view_on_click (GtkWidget *widget, GdkEventButton *event, TboWindow *tbo)
{
    int x, y;
    GList *frame_list;
    Page *page;
    Frame *frame;
    gboolean found = FALSE;

    x = (int)event->x;
    y = (int)event->y;


    page = tbo_comic_get_current_page (tbo->comic);
    for (frame_list = tbo_page_get_frames (page); frame_list; frame_list = frame_list->next)
    {
        frame = (Frame *)frame_list->data;
        if (tbo_frame_point_inside (frame, x, y))
        {
            // Selecting last occurrence.
            set_selected (frame, tbo);
            found = TRUE;
        }
    }

    // resizing
    if (SELECTED && over_resizer (SELECTED, x, y))
    {
        RESIZING = TRUE;
    }
    else if (!found)
        set_selected (NULL, tbo);

    // double click, frame view
    if (SELECTED && event->type == GDK_2BUTTON_PRESS)
    {
        set_frame_view (SELECTED);
        empty_tool_area (tbo);
    }

    START_X = x;
    START_Y = y;

    if (SELECTED != NULL)
    {
        START_M_X = SELECTED->x;
        START_M_Y = SELECTED->y;
        START_M_W = SELECTED->width;
        START_M_H = SELECTED->height;
        tbo_page_set_current_frame (page, SELECTED);
    }
    CLICKED = TRUE;
}

void
page_view_drawing (cairo_t *cr)
{
    const double dashes[] = {5, 5};
    Color border = {0.9, 0.9, 0};
    Color white = {1, 1, 1};
    Color black = {0, 0, 0};
    Color *resizer_border;
    Color *resizer_fill;
    int x, y;

    if (SELECTED != NULL)
    {
        cairo_set_antialias (cr, CAIRO_ANTIALIAS_NONE);
        cairo_set_line_width (cr, 1);
        cairo_set_dash (cr, dashes, G_N_ELEMENTS (dashes), 0);
        cairo_set_source_rgb (cr, border.r, border.g, border.b);
        cairo_rectangle (cr, SELECTED->x, SELECTED->y,
                SELECTED->width, SELECTED->height);
        cairo_stroke (cr);

        // resizer
        if (OVER_RESIZER)
        {
            resizer_fill = &black;
            resizer_border = &white;
        }
        else
        {
            resizer_fill = &white;
            resizer_border = &black;
        }

        cairo_set_line_width (cr, 1);
        cairo_set_dash (cr, dashes, 0, 0);

        x = SELECTED->x + SELECTED->width;
        y = SELECTED->y + SELECTED->height;

        cairo_rectangle (cr, x, y, R_SIZE, R_SIZE);
        cairo_set_source_rgb(cr, resizer_fill->r, resizer_fill->g, resizer_fill->b);
        cairo_fill (cr);

        cairo_set_source_rgb(cr, resizer_border->r, resizer_border->g, resizer_border->b);
        cairo_rectangle (cr, x, y, R_SIZE, R_SIZE);
        cairo_stroke (cr);

        cairo_set_antialias (cr, CAIRO_ANTIALIAS_DEFAULT);

    }
}

void
page_view_on_key (GtkWidget *widget, GdkEventKey *event, TboWindow *tbo)
{
    Page *page;

    page = tbo_comic_get_current_page (tbo->comic);

    if (SELECTED != NULL && event->keyval == GDK_Delete)
    {
        tbo_page_del_frame (page, SELECTED);
        set_selected (NULL, tbo);
    }

    if (event->keyval == GDK_Tab)
    {
        set_selected (tbo_page_next_frame (page), tbo);
        if (SELECTED == NULL)
        {
            set_selected (tbo_page_first_frame (page), tbo);
        }
    }
}

void
selector_tool_on_click (GtkWidget *widget,
        GdkEventButton *event,
        TboWindow *tbo)
{
    if (get_frame_view ())
        frame_view_on_click (widget, event, tbo);
    else
        page_view_on_click (widget, event, tbo);
}

void
selector_tool_on_release (GtkWidget *widget,
        GdkEventButton *event,
        TboWindow *tbo)
{
    START_X = 0;
    START_Y = 0;
    CLICKED = FALSE;
    RESIZING = FALSE;
}

void
selector_tool_drawing (cairo_t *cr)
{
    if (get_frame_view ())
        frame_view_drawing (cr);
    else
        page_view_drawing (cr);
}

void
selector_tool_on_key (GtkWidget *widget, GdkEventKey *event, TboWindow *tbo)
{
    if (get_frame_view ())
        frame_view_on_key (widget, event, tbo);
    else
        page_view_on_key (widget, event, tbo);
}

Frame *
selector_tool_get_selected_frame ()
{
    return SELECTED;
}
