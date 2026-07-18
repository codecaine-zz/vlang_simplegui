module main

import simplegui
import rand

struct GameState {
mut:
	secret_number   int
	max_attempts    int
	attempts_left   int
	difficulty_star int
	game_over       bool
	min_val         int
	max_val         int
}

fn (mut state GameState) reset(difficulty int) {
	state.difficulty_star = difficulty
	state.game_over = false
	state.min_val = 1
	match difficulty {
		1 {
			state.max_val = 20
			state.max_attempts = 5
		}
		2 {
			state.max_val = 50
			state.max_attempts = 6
		}
		3 {
			state.max_val = 100
			state.max_attempts = 7
		}
		4 {
			state.max_val = 250
			state.max_attempts = 8
		}
		else {
			state.max_val = 500
			state.max_attempts = 10
		}
	}
	state.attempts_left = state.max_attempts
	state.secret_number = rand.int_in_range(state.min_val, state.max_val + 1) or { 42 }
}

fn main() {
	mut state := GameState{}
	state.reset(3) // Default difficulty: Medium (3 Stars, 1-100, 7 attempts)

	mut win := simplegui.new_simple_window('Guessing Game Studio', 520, 520)
	win.set_theme('dracula')
	win.set_padding(18)
	win.set_spacing(12)

	win.add_label('header', '🎯 Guessing Game Studio')
		.bold(true)
		.font_size(22)
		.font_color('#ff79c6') // Dracula Pink

	win.add_label('sub_header', 'Select a difficulty, adjust your guess, and submit to test your luck!')
		.font_size(12)
		.font_color('#6272a4')

	win.add_separator()

	// Difficulty stars rating
	win.begin_row('diff_row')
	win.add_label('lbl_diff', 'Difficulty (1-5 Stars):').width(150)
	win.add_rating('rating_diff', state.difficulty_star)
	win.end_row()

	win.add_label('status_info', 'Difficulty: Medium | Range: 1 - 100 | Attempts Left: 7')
		.bold(true)
		.font_color('#50fa7b')

	// Closeness / Warmth thermometer level indicator
	win.begin_row('warmth_row')
	win.add_label('lbl_warmth', 'Warmth Meter:').width(100)
	// Continuous level indicator (style = 1, min = 0, max = 100, val = 0)
	win.add_level_indicator('lvl_warmth', 1, 0, 100, 0)
	win.end_row()

	// Attempts left discrete level indicator
	win.begin_row('attempts_row')
	win.add_label('lbl_attempts', 'Attempts Left:').width(100)
	// Discrete capacity indicator (style = 2, min = 0, max = 10, val = 7)
	win.add_level_indicator('lvl_attempts', 2, 0, 10, state.attempts_left)
	win.end_row()

	win.add_separator()

	// Color feedback indicator & Guess Input
	win.begin_row('input_row')
	win.add_label('lbl_guess', 'Your Guess:').width(90)
	win.add_number('num_guess', 50)
	win.add_color_well('color_feedback', '#6272a4')
	win.end_row()

	// Slider control synced with guess
	win.begin_row('slider_row')
	win.add_label('lbl_slider', 'Slide to Guess:').width(100)
	win.add_slider('slider_guess', 50)
	win.end_row()

	// History log
	win.add_label('lbl_log', 'Guess History:')
	win.add_textarea('txt_log', 'Game started! Good luck.\n')
	win.set_control_height('txt_log', 100)

	// Action buttons
	win.begin_row('actions')
	win.add_button('btn_submit', 'Submit Guess')
	win.add_button('btn_reset', 'Reset / New Game')
	win.end_row()

	// Event handling

	// Diff rating change resets the game
	win.on_change('rating_diff', fn [mut state] (mut w simplegui.SimpleWindow, val string) {
		stars := val.int()
		if stars == state.difficulty_star {
			return
		}
		if stars >= 1 && stars <= 5 {
			state.reset(stars)
			update_ui(mut w, state)
			w.set_text('txt_log', 'Difficulty changed to ${stars} stars. New game started!\n')
			w.set_status('New game loaded.')
		}
	})

	// Sync number field with slider
	win.on_change('num_guess', fn [mut state] (mut w simplegui.SimpleWindow, val string) {
		guess_val := val.int()
		if guess_val >= state.min_val && guess_val <= state.max_val {
			if w.get_value_int('slider_guess') != guess_val {
				w.set_value_int('slider_guess', guess_val)
			}
		}
	})

	win.on_change('slider_guess', fn (mut w simplegui.SimpleWindow, val string) {
		guess_val := val.int()
		if w.get_value_int('num_guess') != guess_val {
			w.set_value_int('num_guess', guess_val)
		}
	})

	// Submit guess
	win.on_click('btn_submit', fn [mut state] (mut w simplegui.SimpleWindow) {
		if state.game_over {
			w.alert('Game Over', 'The game has ended. Click Reset to play again!')
			return
		}
		guess := w.get_value_int('num_guess')
		if guess < state.min_val || guess > state.max_val {
			w.alert('Invalid Guess', 'Please enter a number between ${state.min_val} and ${state.max_val}.')
			return
		}

		state.attempts_left--

		mut log_entry := 'Guess #${state.max_attempts - state.attempts_left}: ${guess} -> '
		mut color := '#6272a4'
		mut warmth := 0

		diff := abs(guess - state.secret_number)
		max_diff := state.max_val - state.min_val

		// Calculate warmth percentage: closer is higher warmth
		if diff == 0 {
			warmth = 100
		} else {
			warmth = int(100.0 * (1.0 - f64(diff) / f64(max_diff)))
			if warmth < 5 {
				warmth = 5
			}
			// At least a tiny bit
		}

		if guess == state.secret_number {
			state.game_over = true
			log_entry += 'CORRECT! 🎉 You won!\n'
			color = '#50fa7b' // Dracula Green
			w.set_text('status_info', 'You Won! Secret was indeed ${state.secret_number}.')
			w.alert('Winner!', 'Congratulations! You guessed the secret number ${state.secret_number}!')
			w.set_status('Winner!')
		} else if state.attempts_left <= 0 {
			state.game_over = true
			log_entry += 'Game Over! Secret was ${state.secret_number}.\n'
			color = '#ff5555' // Dracula Red
			w.set_text('status_info', 'Game Over! The secret number was ${state.secret_number}.')
			w.alert('Game Over', 'You ran out of attempts! The secret number was ${state.secret_number}.')
			w.set_status('Game over.')
		} else {
			if guess < state.secret_number {
				log_entry += 'Too Low 📉\n'
				color = '#8be9fd' // Dracula Cyan (Cold)
				w.set_text('status_info', 'Too low! Attempts left: ${state.attempts_left}')
			} else {
				log_entry += 'Too High 📈\n'
				color = '#ffb86c' // Dracula Orange (Warm)
				w.set_text('status_info', 'Too high! Attempts left: ${state.attempts_left}')
			}
		}

		// Update indicator values
		w.set_value_int('lvl_warmth', warmth)
		w.set_value_int('lvl_attempts', state.attempts_left)
		w.set_text('color_feedback', color)

		// Append to history log
		curr_log := w.get_text('txt_log')
		w.set_text('txt_log', curr_log + log_entry)
	})

	// Reset Game
	win.on_click('btn_reset', fn [mut state] (mut w simplegui.SimpleWindow) {
		stars := w.get_value_int('rating_diff')
		state.reset(if stars > 0 { stars } else { 3 })
		update_ui(mut w, state)
		w.set_text('txt_log', 'Game reset. New secret number generated!\n')
		w.set_status('Game reset.')
	})

	win.run()
}

fn update_ui(mut w simplegui.SimpleWindow, state GameState) {
	// Sync rating control
	w.set_value_int('rating_diff', state.difficulty_star)

	// Update status label
	diff_name := match state.difficulty_star {
		1 { 'Easy' }
		2 { 'Normal' }
		3 { 'Medium' }
		4 { 'Hard' }
		else { 'Expert' }
	}
	w.set_text('status_info', 'Difficulty: ${diff_name} | Range: ${state.min_val} - ${state.max_val} | Attempts Left: ${state.attempts_left}')

	// Update levels
	w.set_value_int('lvl_warmth', 0)
	w.set_value_int('lvl_attempts', state.attempts_left)

	// Set guess values to midpoint
	mid := (state.min_val + state.max_val) / 2
	w.set_value_int('num_guess', mid)
	w.set_value_int('slider_guess', mid)

	// Reset color well
	w.set_text('color_feedback', '#6272a4')
}

fn abs(x int) int {
	return if x < 0 { -x } else { x }
}
