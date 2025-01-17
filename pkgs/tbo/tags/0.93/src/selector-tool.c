#include <glib/gi18n.h>
#include <gtk/gtk.h>
#include <gdk/gdkkeysyms.h>
#include <cairo.h>
#include <math.h>
#include "selector-tool.h"
#include "tbo-window.h"
#include "tbo-types.h"
#include "tbo-object.h"
#include "page.h"
#include "frame.h"
#include "comic.h"
#include "ui-drawing.h"

#define R_SIZE 10

static Frame *SELECTED = NULL;
static tbo_object *OBJ = NULL;
static int START_X=0, START_Y=0;
static int START_M_X=0, START_M_Y=0;
static int START_M_W=0, START_M_H=0;
static int X=0, Y=0;
gboolean CLICKED = FALSE;
gboolean OVER_RESIZER = FALSE;
gboolean OVER_ROTATER = FALSE;
gboolean RESIZING = FALSE;
gboolean ROTATING = FALSE;
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

gboolean
update_color_cb (GtkColorButton *button, TboWindow *tbo)
{
    if (RESIZING || CLICKED || SELECTED == NULL)
        return FALSE;

    GdkColor color = {0,0,0};
    gtk_color_button_get_color (button, &color);
    tbo_frame_set_color (SELECTED, &color);
    update_drawing (tbo);
    return FALSE;
}

gboolean
update_border_cb (GtkToggleButton *button, TboWindow *tbo)
{
    if (RESIZING || CLICKED || SELECTED == NULL)
        return FALSE;

    SELECTED->border = !SELECTED->border;
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
    GtkWidget *hpanel;
    GtkWidget *label;
    GtkWidget *color;
    GtkWidget *border;
    GdkColor gdk_color = {0, 0, 0};

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

        hpanel = gtk_hbox_new (FALSE, 0);
        label = gtk_label_new (_("Color: "));
        gtk_misc_set_alignment (GTK_MISC (label), 0, 0);
        color = gtk_color_button_new ();
        gdk_color.red = SELECTED->color->r * 65535;
        gdk_color.green = SELECTED->color->g * 65535;
        gdk_color.blue = SELECTED->color->b * 65535;
        gtk_color_button_set_color (GTK_COLOR_BUTTON (color), &gdk_color);

        gtk_box_pack_start (GTK_BOX (hpanel), label, TRUE, TRUE, 5);
        gtk_box_pack_start (GTK_BOX (hpanel), color, TRUE, TRUE, 5);
        gtk_box_pack_start (GTK_BOX (toolarea), hpanel, FALSE, FALSE, 5);
        g_signal_connect (color, "color-set", G_CALLBACK (update_color_cb), tbo);

        border = gtk_check_button_new_with_label (_("border"));
        gtk_toggle_button_set_active (GTK_TOGGLE_BUTTON (border), SELECTED->border);
        gtk_box_pack_start (GTK_BOX (toolarea), border, FALSE, FALSE, 5);
        g_signal_connect (border, "toggled", G_CALLBACK (update_border_cb), tbo);

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

void
set_selected_obj (tbo_object *obj, TboWindow *tbo)
{
    OBJ = obj;
}

gboolean
over_resizer (Frame *frame, int x, int y)
{
    int rx, ry;
    rx = frame->x + frame->width;
    ry = frame->y + frame->height;

    float r_size;
    r_size = R_SIZE / tbo_drawing_get_zoom ();

    if (((rx-r_size) < x) &&
        ((rx+r_size) > x) &&
        ((ry-r_size) < y) &&
        ((ry+r_size) > y))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

gboolean
over_resizer_obj (tbo_object *obj, int x, int y)
{
    int rx, ry;
    int ox, oy, ow, oh;
    tbo_frame_get_obj_relative (OBJ, &ox, &oy, &ow, &oh);
    rx = ox + (ow * cos(obj->angle) - oh * sin(obj->angle));
    ry = oy + (oh * cos(obj->angle) + ow * sin(obj->angle));

    float r_size;
    r_size = R_SIZE / tbo_drawing_get_zoom ();

    if (((rx-r_size) < x) &&
        ((rx+r_size) > x) &&
        ((ry-r_size) < y) &&
        ((ry+r_size) > y))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

gboolean
over_rotater_obj (tbo_object *obj, int x, int y)
{
    int rx, ry;
    int ox, oy, ow, oh;
    tbo_frame_get_obj_relative (OBJ, &ox, &oy, &ow, &oh);
    rx = ox;
    ry = oy;

    float r_size;
    r_size = R_SIZE / tbo_drawing_get_zoom ();

    if (((rx-r_size/2.0) < x) &&
        ((rx+r_size/2.0) > x) &&
        ((ry-r_size/2.0) < y) &&
        ((ry+r_size/2.0) > y))
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
    if (get_frame_view ())
        frame_view_on_move (widget, event, tbo);
    else
        page_view_on_move (widget, event, tbo);
}

void
frame_view_on_move (GtkWidget *widget,
        GdkEventMotion *event,
        TboWindow *tbo)
{
    int x, y, offset_x, offset_y;

    x = (int)event->x;
    y = (int)event->y;

    X = x;
    Y = y;

    if (OBJ != NULL)
    {
        if (CLICKED)
        {
            offset_x = (START_X - x) / tbo_frame_get_scale_factor ();
            offset_y = (START_Y - y) / tbo_frame_get_scale_factor ();

            // resizing object
            if (RESIZING)
            {
                OBJ->width = abs (START_M_W - offset_x);
                OBJ->height = abs (START_M_H - offset_y);
            }
            else if (ROTATING)
            {
                OBJ->angle = atan2 (offset_y, offset_x);
            }
            // moving object
            else
            {
                OBJ->x = START_M_X - offset_x;
                OBJ->y = START_M_Y - offset_y;
            }
        }

        // over resizer
        if (over_resizer_obj (OBJ, x, y))
        {
            OVER_RESIZER = TRUE;
        }
        else
        {
            OVER_RESIZER = FALSE;
        }
        // over rotater
        if (over_rotater_obj (OBJ, x, y))
        {
            OVER_ROTATER = TRUE;
        }
        else
        {
            OVER_ROTATER = FALSE;
        }
    }
}

void
frame_view_on_click (GtkWidget *widget, GdkEventButton *event, TboWindow *tbo)
{
    int x, y;
    GList *obj_list;
    Frame *frame;
    tbo_object *obj;
    gboolean found = FALSE;

    x = (int)event->x;
    y = (int)event->y;

    // resizing
    if (OBJ && over_resizer_obj (OBJ, x, y))
    {
        RESIZING = TRUE;
    }
    else if (OBJ && over_rotater_obj (OBJ, x, y))
    {
        ROTATING = TRUE;
    }
    else
    {
        frame = get_frame_view ();
        for (obj_list = g_list_first (frame->objects); obj_list; obj_list = obj_list->next)
        {
            obj = (tbo_object *)obj_list->data;
            if (tbo_frame_point_inside_obj (obj, x, y))
            {
                // Selecting last occurrence.
                set_selected_obj (obj, tbo);
                found = TRUE;
            }
        }
        if (!found)
            set_selected_obj (NULL, tbo);
    }

    START_X = x;
    START_Y = y;

    if (OBJ != NULL)
    {
        START_M_X = OBJ->x;
        START_M_Y = OBJ->y;
        START_M_W = OBJ->width;
        START_M_H = OBJ->height;
    }
    CLICKED = TRUE;
}

void
frame_view_drawing (cairo_t *cr)
{
    const double dashes[] = {5, 5};
    Color border = {0.9, 0.9, 0};
    Color white = {1, 1, 1};
    Color black = {0, 0, 0};
    Color *resizer_border;
    Color *resizer_fill;
    Color *rotater_border;
    Color *rotater_fill;
    int x, y;
    float r_size;

    if (OBJ != NULL)
    {
        cairo_set_antialias (cr, CAIRO_ANTIALIAS_NONE);
        cairo_set_line_width (cr, 1);
        cairo_set_dash (cr, dashes, G_N_ELEMENTS (dashes), 0);
        cairo_set_source_rgb (cr, border.r, border.g, border.b);
        int ox, oy, ow, oh;
        tbo_frame_get_obj_relative (OBJ, &ox, &oy, &ow, &oh);

        cairo_translate (cr, ox, oy);
        cairo_rotate (cr, OBJ->angle);
        cairo_rectangle (cr, 0, 0, ow, oh);
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

        // rotater
        if (OVER_ROTATER)
        {
            rotater_fill = &black;
            rotater_border = &white;
        }
        else
        {
            rotater_fill = &white;
            rotater_border = &black;
        }

        cairo_set_line_width (cr, 1);
        cairo_set_dash (cr, dashes, 0, 0);

        x = ow;
        y = oh;

        r_size = R_SIZE / tbo_drawing_get_zoom ();
        cairo_set_line_width (cr, 1/tbo_drawing_get_zoom ());

        cairo_rectangle (cr, x, y, r_size, r_size);
        cairo_set_source_rgb(cr, resizer_fill->r, resizer_fill->g, resizer_fill->b);
        cairo_fill (cr);

        cairo_set_source_rgb(cr, resizer_border->r, resizer_border->g, resizer_border->b);
        cairo_rectangle (cr, x, y, r_size, r_size);
        cairo_stroke (cr);

        // object rotate zone
        cairo_set_source_rgb(cr, rotater_fill->r, rotater_fill->g, rotater_fill->b);
        cairo_arc (cr, 0, 0, r_size / 2., 0, 2 * M_PI);
        cairo_fill (cr);
        cairo_set_source_rgb(cr, rotater_border->r, rotater_border->g, rotater_border->b);
        cairo_arc (cr, 0, 0, r_size / 2., 0, 2 * M_PI);
        cairo_stroke (cr);
        cairo_set_line_width (cr, tbo_drawing_get_zoom ());

        cairo_rotate (cr, -OBJ->angle);
        cairo_translate (cr, -ox, -oy);

        cairo_set_antialias (cr, CAIRO_ANTIALIAS_DEFAULT);

        if (ROTATING)
        {
            cairo_set_source_rgb(cr, 1, 0, 0);
            cairo_move_to (cr, ox, oy);
            cairo_line_to (cr, X, Y);
            cairo_stroke (cr);
        }
    }
}

void
frame_view_on_key (GtkWidget *widget, GdkEventKey *event, TboWindow *tbo)
{
    if (SELECTED != NULL && event->keyval == GDK_Escape)
    {
        set_frame_view (NULL);
    }

    if (OBJ != NULL)
    {
        switch (event->keyval)
        {
            case GDK_Delete:
                tbo_frame_del_obj (SELECTED, OBJ);
                set_selected_obj (NULL, tbo);
                break;
            case GDK_v:
                tbo_object_flipv (OBJ);
                break;
            case GDK_h:
                tbo_object_fliph (OBJ);
                break;
            case GDK_Page_Up:
                tbo_object_order_up (OBJ);
                break;
            case GDK_Page_Down:
                tbo_object_order_down (OBJ);
                break;
            case GDK_Up:
                tbo_object_move (OBJ, MOVE_UP);
                break;
            case GDK_less:
                tbo_object_resize (OBJ, RESIZE_LESS);
                break;
            case GDK_greater:
                tbo_object_resize (OBJ, RESIZE_GREATER);
                break;
            case GDK_Down:
                tbo_object_move (OBJ, MOVE_DOWN);
                break;
            case GDK_Left:
                tbo_object_move (OBJ, MOVE_LEFT);
                break;
            case GDK_Right:
                tbo_object_move (OBJ, MOVE_RIGHT);
                break;
            case GDK_d:
                if (event->state & GDK_CONTROL_MASK)
                {
                    tbo_object *cloned_obj = OBJ->clone (OBJ);
                    cloned_obj->x += 10;
                    cloned_obj->y -= 10;
                    tbo_frame_add_obj (SELECTED, cloned_obj);
                    set_selected_obj (cloned_obj, tbo);
                }
                break;
            default:
                break;
        }
    }
}

void
page_view_on_move (GtkWidget *widget,
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
    float r_size;

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

        r_size = R_SIZE / tbo_drawing_get_zoom ();
        cairo_set_line_width (cr, 1 / tbo_drawing_get_zoom ());
        cairo_rectangle (cr, x, y, r_size, r_size);
        cairo_set_source_rgb(cr, resizer_fill->r, resizer_fill->g, resizer_fill->b);
        cairo_fill (cr);

        cairo_set_source_rgb(cr, resizer_border->r, resizer_border->g, resizer_border->b);
        cairo_rectangle (cr, x, y, r_size, r_size);
        cairo_stroke (cr);
        cairo_set_line_width (cr, tbo_drawing_get_zoom ());

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

    switch (event->keyval)
    {
        case GDK_Tab:
            set_selected (tbo_page_next_frame (page), tbo);
            if (SELECTED == NULL)
            {
                set_selected (tbo_page_first_frame (page), tbo);
            }
            break;

        case GDK_d:
            if ((event->state & GDK_CONTROL_MASK) && SELECTED)
            {
                Frame *cloned_frame = tbo_frame_clone (SELECTED);
                cloned_frame->x += 10;
                cloned_frame->y -= 10;
                tbo_page_add_frame (page, cloned_frame);
                set_selected (cloned_frame, tbo);
            }
            break;
        default:
            break;
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
    ROTATING = FALSE;
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

