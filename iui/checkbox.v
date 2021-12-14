module iui

import gg
import gx
import time
import math

// Checkbox
struct Checkbox {
pub mut:
	app            &Window
	text           string
	x              int
	y              int
	width          int
	height         int
	last_click     f64
	click_event_fn fn (mut Window, Checkbox)
	is_selected    bool
}

pub fn checkbox(app &Window, text string) Checkbox {
	return Checkbox{
		text: text
		app: app
		click_event_fn: blank_event_cbox
	}
}

pub fn (mut com Checkbox) set_click(b fn (mut Window, Checkbox)) {
	com.click_event_fn = b
}

pub fn blank_event_cbox(mut win Window, a Checkbox) {
}

pub fn (mut com Checkbox) draw() {
	app := com.app
	width := com.width
	height := com.height
	mut bg := app.theme.checkbox_bg
	mut border := app.theme.button_border_normal

	mut mid := (com.x + (width / 2))
	mut midy := (com.y + (height / 2))

	// Detect Hover
	if (math.abs(mid - app.mouse_x) < (width / 2)) && (math.abs(midy - app.mouse_y) < (height / 2)) {
		bg = app.theme.button_bg_hover
		border = app.theme.button_border_hover
	}

	// Detect Click
	if (math.abs(mid - app.click_x) < (width / 2)) && (math.abs(midy - app.click_y) < (height / 2)) {
		now := time.now().unix_time_milli()

		if now - com.last_click > 100 {
			com.is_selected = !com.is_selected
			com.click_event_fn(app, *com)

			bg = app.theme.button_bg_click
			border = app.theme.button_border_click
			com.last_click = time.now().unix_time_milli()
		}
	}

	com.app.draw_bordered_rect(com.x, com.y, com.width, com.height, 2, bg, border)
	if com.is_selected {
		cut := 4
		com.app.draw_bordered_rect(com.x + cut, com.y + cut, com.width - (cut * 2), com.height - (cut * 2),
			2, com.app.theme.checkbox_selected, com.app.theme.checkbox_selected)
	}
	sizh := app.gg.text_height(com.text) / 2
	app.gg.draw_text(com.x + com.width + 4, com.y + (height / 2) - sizh, com.text, gx.TextCfg{
		size: 14
		color: app.theme.text_color
	})
}