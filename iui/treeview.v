module iui

import gg
import gx
import time
import math

// Treeview
struct Tree {
pub mut:
	app            &Window
	text           string
	x              int
	y              int
	width          int
	height         int
	last_click     f64
	click_event_fn fn (mut Window, Tree)
	is_selected    bool
	in_modal       bool
	childs         []Component
	carrot_index   int = 1
    z_index        int
}

pub fn tree(app &Window, text string) Tree {
	return Tree{
		text: text
		app: app
		click_event_fn: fn (mut a Window, b Tree) {}
	}
}

pub fn (mut tr Tree) draw() {
	//tr.app.draw_bordered_rect(tr.x, tr.y, tr.width, tr.height, 2, tr.app.theme.button_bg_normal,
	//	tr.app.theme.button_border_normal)
	mut mult := 20
	mut app := tr.app
	mut bg := app.theme.button_bg_normal
	mut border := tr.app.theme.button_border_normal

	mut mid := (tr.x + (tr.width / 2))
	mut midy := (tr.y + 3 + (20 / 2))
	if (math.abs(mid - app.click_x) < (tr.width / 2)) && (math.abs(midy - app.click_y) < (20 / 2)) {
		now := time.now().unix_time_milli()

		if now - tr.last_click > 100 {
			tr.is_selected = !tr.is_selected
			tr.click_event_fn(app, *tr)

			bg = app.theme.button_bg_click
			border = app.theme.button_border_click
			tr.last_click = time.now().unix_time_milli()
		}
	}
	if tr.is_selected {
        if tr.childs.len > 0 {
            bg = app.theme.button_bg_click
        } else {
            tr.is_selected = false
        }
	}

	//tr.app.draw_bordered_rect(tr.x + 4, tr.y + 3, tr.width - 8, 20, 2, bg, border)
    tr.app.gg.draw_rounded_rect(tr.x + 4, tr.y + 3, tr.width - 8, 20, 2, bg)
    
    
    if tr.is_selected {
        tr.app.gg.draw_triangle(tr.x + 5, tr.y + 8,
                            tr.x + 12, tr.y + 8,
                            tr.x + 8, tr.y + 16,
                        app.theme.text_color)
    } else if tr.childs.len > 0 {
        tr.app.gg.draw_triangle(tr.x + 7, tr.y + 6,
                            tr.x + 12, tr.y + 11,
                            tr.x + 7, tr.y + 16,
                        app.theme.text_color)
    }
    
	tr.app.gg.draw_text(tr.x + 14, tr.y + 4, tr.text, gx.TextCfg{
		size: 14
		color: tr.app.theme.text_color
	})

    mut multx := 8
	if tr.is_selected  {
        for mut child in tr.childs {
            child.width = tr.width - (multx*2)
            draw_with_offset(mut child, tr.x + multx, tr.y + mult)
            mult += child.height
        }
    }

}