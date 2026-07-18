module main

import simplegui
import db.sqlite
import os

// 1. Database Model mapped to SQLite using V's ORM
struct Product {
mut:
	id        int @[primary; sql: serial]
	name      string
	category  string
	stock     int
	price     f64
	in_stock  bool
	date_recv string
}

// 2. Application State holding database connection and active results
struct AppState {
mut:
	db               sqlite.DB
	db_path          string
	products         []Product
	selected_row_idx int = -1
	filter_query     string
}

// 3. Helper to fetch products from SQLite with optional fuzzy search filtering
fn filter_and_format_rows(mut state AppState) [][]string {
	pattern := '%' + state.filter_query + '%'

	// Query database using V ORM. It automatically matches name OR category.
	prods := sql state.db {
		select from Product where name like pattern || category like pattern
	} or { []Product{} }

	state.products = prods

	mut rows := [][]string{}
	for p in prods {
		rows << [
			p.id.str(),
			p.name,
			p.category,
			p.stock.str(),
			'$' + p.price.str(),
			if p.in_stock { 'Yes' } else { 'No' },
			p.date_recv,
		]
	}
	return rows
}

// 4. Synchronize selected product attributes to the editor form fields
fn sync_selection_to_ui(mut win simplegui.SimpleWindow, mut state AppState) {
	if state.selected_row_idx >= 0 && state.selected_row_idx < state.products.len {
		p := state.products[state.selected_row_idx]

		// Populate row editor fields
		win.set_text('id_input', p.id.str())
		win.set_text('name_input', p.name)
		win.set_text('category_input', p.category)
		win.set_value_int('stock_input', p.stock)
		win.set_text('price_input', p.price.str())
		win.set_checked('in_stock_input', p.in_stock)
		win.set_text('date_recv_input', p.date_recv)

		win.set_text('info_label', 'Selected Product: ' + p.name + ' (ID: ' + p.id.str() + ')')

		win.set_control_enabled('delete_row_btn', true)
		win.set_control_enabled('save_row_btn', true)
	} else {
		// No selection: Clear the editor form to allow quick creation
		win.set_text('id_input', 'AUTO-GENERATE')
		win.set_text('name_input', '')
		win.set_text('category_input', 'Electronics')
		win.set_value_int('stock_input', 0)
		win.set_text('price_input', '')
		win.set_checked('in_stock_input', true)
		win.set_text('date_recv_input', '2026-07-05')

		win.set_text('info_label', 'Select a row in the table above to edit, or fill details below to add a new product.')

		win.set_control_enabled('delete_row_btn', false)
		win.set_control_enabled('save_row_btn', false)
	}
}

// 5. Update database and file size statistics in the footer info bar
fn sync_stats_to_ui(mut win simplegui.SimpleWindow, mut state AppState) {
	count_prods := sql state.db {
		select count from Product
	} or { 0 }

	size := os.file_size(state.db_path)
	size_str := if size < 1024 {
		size.str() + ' Bytes'
	} else {
		(size / 1024).str() + ' KB'
	}

	stats_text := 'SQLite File: ${os.file_name(state.db_path)} (${size_str}) | Database Records: ${count_prods}'
	win.set_text('db_stats_label', stats_text)
}

fn main() {
	// Setup SQLite Database path in current workspace directory
	db_filename := 'sqlite_crud_demo.db'
	db_path := os.join_path(os.getwd(), db_filename)

	mut db := sqlite.connect(db_path) or { panic('Failed to connect to SQLite: ' + err.msg()) }

	// Create table if it doesn't exist
	sql db {
		create table Product
	} or { panic('Failed to initialize database tables: ' + err.msg()) }

	// Seed default dataset if database is empty
	initial_count := sql db {
		select count from Product
	} or { 0 }

	if initial_count == 0 {
		println('SQLite table is empty. Seeding default products...')
		p1 := Product{
			name:      'MacBook Pro M3'
			category:  'Electronics'
			stock:     45
			price:     1999.99
			in_stock:  true
			date_recv: '2026-07-01'
		}
		p2 := Product{
			name:      'Ergonomic Desk Chair'
			category:  'Furniture'
			stock:     15
			price:     299.50
			in_stock:  true
			date_recv: '2026-06-15'
		}
		p3 := Product{
			name:      'Wireless Bluetooth Mouse'
			category:  'Electronics'
			stock:     120
			price:     49.99
			in_stock:  true
			date_recv: '2026-07-02'
		}
		p4 := Product{
			name:      'Classic Leather Notebook'
			category:  'Books'
			stock:     80
			price:     18.00
			in_stock:  true
			date_recv: '2026-06-30'
		}
		p5 := Product{
			name:      'Ultra-light Running Shoes'
			category:  'Apparel'
			stock:     0
			price:     89.90
			in_stock:  false
			date_recv: '2026-05-20'
		}

		sql db {
			insert p1 into Product
			insert p2 into Product
			insert p3 into Product
			insert p4 into Product
			insert p5 into Product
		} or { panic('Failed to seed database: ' + err.msg()) }
	}

	mut state := AppState{
		db:      db
		db_path: db_path
	}

	// 6. Build the modern simplegui Cocoa desktop layout
	mut win := simplegui.new_simple_window('SQLite Database CRUD Explorer', 780, 620)
	win.set_theme('dracula')
	win.set_spacing(10)
	win.set_padding(15)

	// Heading details

	win.add_label('header', 'SQLite Inventory Manager')
		.bold(true)
		.font_size(20)
		.font_color('#8be9fd') // Dracula Cyan

	win.add_label('intro', 'Manage product records inside a local SQLite database in real-time. Changes persist across application runs.')
		.font_size(11)
		.font_color('#6272a4')

	// Real-time fuzzy filter bar
	win.begin_row('search_row')
	win.add_label('search_lbl', 'Fuzzy Search:').width(90).font_color('#f8f8f2')
	win.add_input('search_input', '').placeholder('Search product name or category in database...')
	win.end_row()

	// Multi-column table grid representing the database table
	win.add_table('products_table', ['ID', 'Product Name', 'Category', 'Stock Level', 'Unit Price',
		'In Stock?', 'Date Received'])
	win.set_control_height('products_table', 120)

	// Context description label

	win.add_label('info_label', 'Select a row in the table above to edit, or fill details below to add a new product.')
		.bold(true)
		.font_size(12)
		.font_color('#50fa7b') // Dracula Green

	win.add_separator()

	// Side-by-side edit form and operations panel
	win.begin_row('form_pane')

	// Column 1: Record Details form
	win.add_group_box('record_details_group', 'Product Details Form')
	win.begin_row('id_cat_row')
	win.add_label('lbl_id', 'ID:').font_size(11).width(30)
	win.add_input('id_input', 'AUTO-GENERATE').width(110)
	win.add_horizontal_spacer(10)
	win.add_label('lbl_category', 'Category:').font_size(11).width(60)

	win.add_dropdown('category_input', ['Electronics', 'Furniture', 'Apparel', 'Books', 'Other'],
		'Electronics').width(110)
	win.end_row()
	win.set_control_enabled('id_input', false) // ID is database auto-incremented

	win.begin_row('name_row')
	win.add_label('lbl_name', 'Name:').font_size(11).width(60)
	win.add_input('name_input', '')
	win.end_row()

	win.begin_row('stock_price_row')
	win.add_label('lbl_stock', 'Stock Qty:').font_size(11).width(60)
	win.add_number('stock_input', 0).width(80)
	win.add_horizontal_spacer(10)
	win.add_label('lbl_price', 'Price ($):').font_size(11).width(60)
	win.add_input('price_input', '').width(80)
	win.end_row()

	win.begin_row('in_stock_date_row')
	win.add_checkbox('in_stock_input', 'Active in Catalog', true).width(140)
	win.add_horizontal_spacer(10)
	win.add_label('lbl_date', 'Date:').font_size(11).width(40)
	win.add_date_picker('date_recv_input', '2026-07-05').width(120)
	win.end_row()

	// Column 2: CRUD Database Actions and Stats panel
	win.add_group_box('actions_group', 'Database Operations')

	win.add_label('act_desc', 'Perform CRUD operations on the SQLite connection:')
		.font_size(11)
		.font_color('#6272a4')

	win.add_vertical_spacer(5)

	win.add_button('save_row_btn', 'Save Product Changes')
		.tooltip('Update the selected product details in the database.')

	win.add_button('add_row_btn', 'Insert as New Product')
		.tooltip('Add a new product record to the SQLite database.')

	win.add_button('delete_row_btn', 'Delete Selected Product')
		.tooltip('Permanently remove the selected record from the database.')

	win.add_separator()

	win.add_label('stats_hdr', 'Database Metadata:').bold(true).font_size(12).font_color('#ffb86c')

	win.add_label('db_stats_label', 'Loading database information...')
		.font_size(10)
		.font_color('#f8f8f2')

	win.end_row()

	// Initial table population and statistics rendering
	rows := filter_and_format_rows(mut state)
	win.set_table_rows('products_table', rows)
	sync_selection_to_ui(mut win, mut state)
	sync_stats_to_ui(mut win, mut state)

	// --- 7. Event Handlers Configuration ---

	// Table Row Selection Callback
	win.on_change('products_table', fn [mut state] (mut w simplegui.SimpleWindow, value string) {
		selected := w.get_list_selected('products_table')
		state.selected_row_idx = selected
		sync_selection_to_ui(mut w, mut state)
		w.set_status('Row selected. Product ID: ' + w.get_text('id_input'))
	})

	// Fuzzy Search input handler
	win.on_change('search_input', fn [mut state] (mut w simplegui.SimpleWindow, value string) {
		state.filter_query = value
		state.selected_row_idx = -1 // Reset selection to prevent mismatch on search refresh

		filtered := filter_and_format_rows(mut state)
		w.set_table_rows('products_table', filtered)
		sync_selection_to_ui(mut w, mut state)
		sync_stats_to_ui(mut w, mut state)
		w.set_status('Filter matched ' + filtered.len.str() + ' records.')
	})

	// UPDATE: "Save Product Changes" button callback
	win.on_click('save_row_btn', fn [mut state] (mut w simplegui.SimpleWindow) {
		if state.selected_row_idx < 0 || state.selected_row_idx >= state.products.len {
			w.alert('Selection Required', 'Please select a product row from the table first.')
			return
		}

		prod_id := state.products[state.selected_row_idx].id

		name := w.get_text('name_input').trim_space()
		category := w.get_text('category_input').trim_space()
		stock := w.get_value_int('stock_input')
		price_str := w.get_text('price_input').trim_space()
		in_stock := w.get_checked('in_stock_input')
		date_recv := w.get_text('date_recv_input').trim_space()

		if name == '' || category == '' || date_recv == '' {
			w.alert('Validation Error', 'Name, Category, and Date Received fields are required.')
			return
		}

		price := price_str.f64()
		if price <= 0.0 {
			w.alert('Validation Error', 'Please enter a valid positive numeric price value.')
			return
		}

		// Perform SQL Update using parameters to avoid syntax errors with float literals
		sql state.db {
			update Product set name = name, category = category, stock = stock, price = price,
			in_stock = in_stock, date_recv = date_recv where id == prod_id
		} or {
			w.alert('Database Write Error', 'Failed to update record: ' + err.msg())
			return
		}

		// Refresh data list
		rows_list := filter_and_format_rows(mut state)
		w.set_table_rows('products_table', rows_list)

		// Find new row index in loaded results to maintain selection highlight
		mut new_idx := -1
		for i, p in state.products {
			if p.id == prod_id {
				new_idx = i
				break
			}
		}
		state.selected_row_idx = new_idx
		if new_idx >= 0 {
			w.set_list_selected('products_table', new_idx)
		}

		sync_selection_to_ui(mut w, mut state)
		sync_stats_to_ui(mut w, mut state)

		w.toast('Product updated in SQLite database!')
		w.set_status('Updated Product ID: ' + prod_id.str())
	})

	// CREATE: "Insert as New Product" button callback
	win.on_click('add_row_btn', fn [mut state] (mut w simplegui.SimpleWindow) {
		name := w.get_text('name_input').trim_space()
		category := w.get_text('category_input').trim_space()
		stock := w.get_value_int('stock_input')
		price_str := w.get_text('price_input').trim_space()
		in_stock := w.get_checked('in_stock_input')
		date_recv := w.get_text('date_recv_input').trim_space()

		if name == '' || category == '' || date_recv == '' {
			w.alert('Validation Error', 'Please complete the Name, Category, and Date fields first.')
			return
		}

		price := price_str.f64()
		if price <= 0.0 {
			w.alert('Validation Error', 'Price must be a valid positive float number.')
			return
		}

		// Create struct (id is auto-incremented by database)
		new_prod := Product{
			name:      name
			category:  category
			stock:     stock
			price:     price
			in_stock:  in_stock
			date_recv: date_recv
		}

		// SQL Insert using V's ORM
		sql state.db {
			insert new_prod into Product
		} or {
			w.alert('Database Write Error', 'Failed to insert new record: ' + err.msg())
			return
		}

		new_id := int(state.db.last_id())

		rows_list := filter_and_format_rows(mut state)
		w.set_table_rows('products_table', rows_list)

		mut new_idx := -1
		for i, p in state.products {
			if p.id == new_id {
				new_idx = i
				break
			}
		}
		state.selected_row_idx = new_idx
		if new_idx >= 0 {
			w.set_list_selected('products_table', new_idx)
		}

		sync_selection_to_ui(mut w, mut state)
		sync_stats_to_ui(mut w, mut state)

		w.toast('New product added to database successfully!')
		w.set_status('Inserted new product record.')
	})

	// DELETE: "Delete Selected Product" button callback
	win.on_click('delete_row_btn', fn [mut state] (mut w simplegui.SimpleWindow) {
		if state.selected_row_idx < 0 || state.selected_row_idx >= state.products.len {
			w.alert('Selection Required', 'Select a product to delete from the table.')
			return
		}

		prod := state.products[state.selected_row_idx]
		prod_id := prod.id

		if w.confirm('Confirm Deletion', 'Are you sure you want to permanently delete product "' +
			prod.name + '" from the database?')
		{
			// SQL Delete using V's ORM
			sql state.db {
				delete from Product where id == prod_id
			} or {
				w.alert('Database Deletion Error', 'Failed to delete record: ' + err.msg())
				return
			}

			state.selected_row_idx = -1 // Reset active selection

			rows_list := filter_and_format_rows(mut state)
			w.set_table_rows('products_table', rows_list)
			sync_selection_to_ui(mut w, mut state)
			sync_stats_to_ui(mut w, mut state)

			w.toast('Product deleted from database.')
			w.set_status('Deleted Product ID: ' + prod_id.str())
		}
	})

	// 8. Handle safe database disconnection on Window close
	win.on_close(fn [mut state] (mut w simplegui.SimpleWindow) {
		state.db.close() or {}
		println('SQLite Database connection closed safely.')
	})

	win.run()
}
