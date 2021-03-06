module main

import gg
import iui as ui
import iui.extra
import os
import os.font

[console]
fn main() {
	// Create Window
	mut window := ui.window_with_config(ui.get_system_theme(), 'Notepad', 520, 550, &ui.WindowConfig{
		font_path: os.resource_abs_path('VeraMono.ttf')
		ui_mode: true
	})

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)

	mut theme_menu := ui.menuitem('Theme')

	themes := ui.get_all_themes()
	for theme2 in themes {
		item := ui.menu_item(
			text: theme2.name
			click_event_fn: theme_click
		)

		theme_menu.add_child(item)
	}

	file_menu := ui.menu_item(
		text: 'File'
		children: [
			ui.menu_item(
				text: 'Save'
				click_event_fn: save_as_click
			),
		]
	)

	help_menu := ui.menu_item(
		text: 'Help'
		children: [
			ui.menu_item(
				text: 'About Notepad'
				click_event_fn: about_click
			),
			ui.menu_item(
				text: 'About iUI'
			),
		]
	)

	font_menu := ui.menu_item(
		text: 'Font'
		children: [
			font_type_item('OS Default'),
			font_type_item('scientifica.ttf'),
			font_type_item('VeraMono.ttf'),
			font_type_item('JetBrainsMono-Regular.ttf'),
			font_type_item('AnomalyMono-Regular.otf'),
			ui.menu_item(
				text: 'More...'
				click_event_fn: font_picker
			),
		]
	)

	size_menu := ui.menu_item(
		text: 'Size'
		children: [
			font_size_item('12'),
			font_size_item('14'),
			font_size_item('16'),
			font_size_item('18'),
			font_size_item('24'),
		]
	)

	window.bar.add_child(file_menu)
	window.bar.add_child(help_menu)
	window.bar.add_child(theme_menu)
	window.bar.add_child(font_menu)
	window.bar.add_child(size_menu)

	mut res_box := ui.textarea(window, [''])
	res_box.set_id(mut window, 'notepad')
	res_box.set_bounds(4, 28, 0, 0)
	res_box.padding_x = 16
	res_box.padding_y = 16
	res_box.draw_event_fn = vbtn_draw
	window.add_child(res_box)

	window.gg.run()
}

fn font_size_item(size string) &ui.MenuItem {
	return ui.menu_item(text: size, click_event_fn: on_size_click)
}

fn font_type_item(size string) &ui.MenuItem {
	return ui.menu_item(text: size, click_event_fn: font_click)
}

fn font_click(mut win ui.Window, com ui.MenuItem) {
	mut path := os.resource_abs_path(com.text.replace(' ', '-'))
	txt := com.text

	if txt == 'OS Default' {
		path = font.default()
	}
	if txt.starts_with('System ') {
		path = 'C:/windows/fonts/' + com.text.split('System ')[1].to_lower()
	}

	font := win.add_font(txt, path)
	win.graphics_context.font = font
}

fn vbtn_draw(mut win ui.Window, com &ui.Component) {
	size := gg.window_size()

	mut this := *com

	this.width = size.width - 8
	this.height = size.height - 31
}

fn on_size_click(mut win ui.Window, com ui.MenuItem) {
	win.font_size = com.text.int()
}

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	theme := ui.theme_by_name(text)
	win.set_theme(theme)
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.page(win, 'About Notepad')

	mut title := ui.label(win, 'Notepad')
	title.set_config(28, true, true)
	title.pack()

	mut label := ui.label(win,
		'Small Notepad made in\nthe V Programming Language.\n\nVersion: 0.1' + '\nUI Version: ' +
		ui.version)

	label.pack()

	mut vbox := ui.vbox(win)
	vbox.set_pos(24, 18)
	vbox.add_child(title)
	vbox.add_child(label)

	modal.add_child(vbox)

	win.add_child(modal)
}

fn font_picker(mut win ui.Window, com ui.MenuItem) {
	dir := 'C:/windows/fonts/'

	path_change_fn := font_picker_path_change

	picker_conf := extra.FilePickerConfig{
		in_modal: true
		path: dir
		path_change_fn: path_change_fn
	}

	// TODO: put this in FilePickerConfig
	win.extra_map['file_picker_accept'] = '.ttf'

	mut modal := extra.open_file_picker(mut win, picker_conf, win)
	modal.z_index = 500

	win.extra_map['file_picker_accept'] = ''
}

fn save_as_click(mut win ui.Window, com ui.MenuItem) {
	dir := if 'save_path' in win.extra_map {
		win.extra_map['save_path']
	} else {
		os.real_path(os.home_dir())
	}

	path_change_fn := file_picker_path_change

	picker_conf := extra.FilePickerConfig{
		in_modal: true
		path: dir
		path_change_fn: path_change_fn
	}

	mut modal := extra.open_file_picker(mut win, picker_conf, win)
	modal.z_index = 500
}

fn file_picker_path_change(a voidptr, b voidptr) {
	println('FILE PICKED')

	picker := &extra.FilePicker(a)
	mut win := &ui.Window(b)
	mut text_box := &ui.TextArea(win.get_from_id('notepad'))
	path := picker.get_full_path()
	dump(text_box.lines)
	win.extra_map['save_path'] = path
	os.write_file(path, text_box.lines.join('\n')) or {}
}

fn font_picker_path_change(a voidptr, b voidptr) {
	picker := &extra.FilePicker(a)
	mut win := &ui.Window(b)
	path := picker.get_full_path()

	font := win.add_font(picker.get_file_name(), path)
	win.graphics_context.font = font
}
