module main

import simplecli

fn main() {
	mut app := simplecli.new_app('qalc-cli', '1.0.0')
	app.set_description('Qalculate! Advanced Multi-Purpose Calculator CLI')

	app.add_flag_string('expr', 'e', '',
		'Qalculate expression (e.g. "50 EUR to USD" or "solve(x^2 + 5x + 6 = 0, x)")')
	app.add_flag_bool('interactive', 'x', false, 'Launch interactive Qalculate session')

	app.parse_cli() or { return }

	app.banner('Qalc Studio CLI', 'v1.0.0 - Multi-Purpose Power Calculator')

	has_qalc := app.command_exists('qalc')
	if !has_qalc {
		app.warn('qalc binary not found in PATH. Install via "brew install libqalculate".')
	}

	if app.get_flag_bool('interactive') {
		run_interactive(mut app)
		return
	}

	expr := app.get_flag_string('expr')
	if expr.len == 0 {
		app.warn('No expression specified. Run with -e "100 USD in EUR" or -x for interactive mode.')
		app.print_help()
		return
	}

	eval_qalc(mut app, expr, has_qalc)
}

fn eval_qalc(mut app simplecli.SimpleCli, expr string, has_qalc bool) {
	app.reset_timer()
	if has_qalc {
		out, code := app.exec_safe('qalc', ['-t', expr])
		if code == 0 {
			app.success('Result (${app.elapsed_ms()} ms):')
			println(out)
		} else {
			app.error('Qalculate error:\n${out}')
		}
	} else {
		q_expr := simplecli.quote_arg('scale=6; ${expr}')
		mut out, code := app.exec('printf "%s\\n" ${q_expr} | bc -l 2>/dev/null')
		if code != 0 || out.trim_space().len == 0 {
			py_safe := 'import ast, math, operator as op, sys\nops={ast.Add:op.add,ast.Sub:op.sub,ast.Mult:op.mul,ast.Div:op.truediv,ast.Pow:op.pow,ast.Mod:op.mod,ast.USub:op.neg,ast.UAdd:op.pos}\ndef ev(n):\n if isinstance(n,ast.Expression): return ev(n.body)\n if isinstance(n,ast.Constant) and isinstance(n.value,(int,float)): return n.value\n if isinstance(n,ast.BinOp) and type(n.op) in ops: return ops[type(n.op)](ev(n.left),ev(n.right))\n if isinstance(n,ast.UnaryOp) and type(n.op) in ops: return ops[type(n.op)](ev(n.operand))\n if isinstance(n,ast.Name) and hasattr(math,n.id): return getattr(math,n.id)\n if isinstance(n,ast.Call) and isinstance(n.func,ast.Name) and hasattr(math,n.func.id): return getattr(math,n.func.id)(*[ev(a) for a in n.args])\n raise ValueError("unsupported expression")\nprint(ev(ast.parse(sys.argv[1], mode="eval")))'
			out, _ = app.exec_safe('python3', ['-c', py_safe, expr])
		}
		app.success('Calculated (fallback):\n${out}')
	}
}

fn run_interactive(mut app simplecli.SimpleCli) {
	app.panel('Qalculate! REPL', 'Power math, equation solving, unit and currency conversions.')
	has_qalc := app.command_exists('qalc')
	for {
		expr := app.prompt('qalc', 'integrate(x^2, x)')
		if expr == 'exit' || expr == 'q' {
			break
		}
		eval_qalc(mut app, expr, has_qalc)
	}
}
