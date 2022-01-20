module iui

import gg
import gx

// Label - implements Component interface
struct Label {
	Component_A
pub mut:
	app            &Window
	text           string
	click_event_fn fn (mut Window, Label)
	in_modal       bool
	need_pack      bool
}

pub fn label(app &Window, text string) Label {
	return Label{
		text: text
		app: app
		click_event_fn: blank_event_l
	}
}

pub fn (mut btn Label) draw() {
	btn.app.draw_label(btn.x, btn.y, btn.width, btn.height, mut btn)
}

pub fn (mut btn Label) pack() {
	btn.need_pack = true
}

pub fn (mut btn Label) pack_do() {
	width := text_width(btn.app, btn.text + 'ab')
	btn.width = width
	btn.height = text_height(btn.app, btn.text) + 4
	btn.need_pack = false
}

fn (mut app Window) draw_label(x int, y int, width int, height int, mut this Label) {
	if this.need_pack {
		this.pack_do()
	}

	text := this.text
	sizh := text_height(app, text) / 2

	if this.is_mouse_rele {
		this.is_mouse_rele = false
		this.click_event_fn(app, *this)
	}

	// Draw Button Text
	mut line_height := text_height(app, '1A{')
	mut my := 0
	for mut spl in text.split('\n') {
		app.gg.draw_text(x, y + (height / 2) - sizh + my, spl.replace('\t',
			'  '.repeat(8)), gx.TextCfg{
			size: app.font_size
			color: app.theme.text_color
		})
		my += line_height
	}
}

pub fn (mut this Label) set_click(b fn (mut Window, Label)) {
	this.click_event_fn = b
}

pub fn blank_event_l(mut win Window, a Label) {
}