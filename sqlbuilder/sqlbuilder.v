module sqlbuilder

import strings

// OrderDirection specifies ascending or descending sort order in an ORDER BY clause.
pub enum OrderDirection {
	asc
	desc
}

// -----------------------------------------------------------------------
// Safe string escaping for SQL injection defense
// -----------------------------------------------------------------------

// escape_string escapes a SQL string literal by wrapping it in single quotes, doubling embedded single quotes, and stripping NUL bytes.
pub fn escape_string(val string) string {
	mut sb := strings.new_builder(val.len + 8)
	sb.write_u8(`'`)
	for b in val {
		if b == `'` {
			sb.write_string("''")
		} else if b == `\x00` {
			// ignore null bytes
		} else {
			sb.write_u8(b)
		}
	}
	sb.write_u8(`'`)
	return sb.str()
}

// escape_identifier escapes a SQL table or column identifier by wrapping it in double quotes, doubling embedded double quotes, and stripping NUL bytes.
pub fn escape_identifier(name string) string {
	mut sb := strings.new_builder(name.len + 4)
	sb.write_u8(`"`)
	for b in name {
		if b == `"` {
			sb.write_string('""')
		} else if b == `\x00` {
			// ignore null bytes
		} else {
			sb.write_u8(b)
		}
	}
	sb.write_u8(`"`)
	return sb.str()
}

// -----------------------------------------------------------------------
// SELECT Builder
// -----------------------------------------------------------------------

// SelectBuilder constructs parameterized SQL SELECT queries using a fluent immutable API.
pub struct SelectBuilder {
pub:
	columns       []string
	table         string
	joins         []string
	wheres        []string
	where_params  []string
	having_params []string
	params        []string
	group_bys     []string
	havings       []string
	order_bys     []string
	limit_val     int = -1
	offset_val    int = -1
}

// select starts a new SelectBuilder for the specified columns (defaults to `*` when omitted).
pub fn select(columns ...string) SelectBuilder {
	mut cols := []string{}
	if columns.len == 0 {
		cols << '*'
	} else {
		for c in columns {
			cols << c
		}
	}
	return SelectBuilder{
		columns: cols
	}
}

// from sets the target table for the SELECT query.
pub fn (b SelectBuilder) from(table string) SelectBuilder {
	return SelectBuilder{
		...b
		table: table
	}
}

// join appends an INNER JOIN clause to the SELECT query.
pub fn (b SelectBuilder) join(table string, on_cond string) SelectBuilder {
	mut joins := b.joins.clone()
	joins << 'INNER JOIN ${table} ON ${on_cond}'
	return SelectBuilder{
		...b
		joins: joins
	}
}

// left_join appends a LEFT JOIN clause to the SELECT query.
pub fn (b SelectBuilder) left_join(table string, on_cond string) SelectBuilder {
	mut joins := b.joins.clone()
	joins << 'LEFT JOIN ${table} ON ${on_cond}'
	return SelectBuilder{
		...b
		joins: joins
	}
}

// right_join appends a RIGHT JOIN clause to the SELECT query.
pub fn (b SelectBuilder) right_join(table string, on_cond string) SelectBuilder {
	mut joins := b.joins.clone()
	joins << 'RIGHT JOIN ${table} ON ${on_cond}'
	return SelectBuilder{
		...b
		joins: joins
	}
}

// where appends an AND condition and its bound parameters to the WHERE clause.
pub fn (b SelectBuilder) where(cond string, params ...string) SelectBuilder {
	mut wheres := b.wheres.clone()
	wheres << cond
	mut wp := b.where_params.clone()
	for item in params {
		wp << item
	}
	mut all_p := wp.clone()
	all_p << b.having_params
	return SelectBuilder{
		...b
		wheres:       wheres
		where_params: wp
		params:       all_p
	}
}

// where_eq appends a `column = ?` equality condition to the WHERE clause.
pub fn (b SelectBuilder) where_eq(column string, val string) SelectBuilder {
	return b.where('${column} = ?', val)
}

// where_in appends a `column IN (?, ...)` condition to the WHERE clause (or `1 = 0` when values is empty).
pub fn (b SelectBuilder) where_in(column string, values []string) SelectBuilder {
	if values.len == 0 {
		return b.where('1 = 0')
	}
	placeholders := []string{len: values.len, init: '?'}.join(', ')
	return b.where('${column} IN (${placeholders})', ...values)
}

// where_not_in appends a `column NOT IN (?, ...)` condition to the WHERE clause.
pub fn (b SelectBuilder) where_not_in(column string, values []string) SelectBuilder {
	if values.len == 0 {
		return b
	}
	placeholders := []string{len: values.len, init: '?'}.join(', ')
	return b.where('${column} NOT IN (${placeholders})', ...values)
}

// where_null appends a `column IS NULL` condition to the WHERE clause.
pub fn (b SelectBuilder) where_null(column string) SelectBuilder {
	return b.where('${column} IS NULL')
}

// where_not_null appends a `column IS NOT NULL` condition to the WHERE clause.
pub fn (b SelectBuilder) where_not_null(column string) SelectBuilder {
	return b.where('${column} IS NOT NULL')
}

// or_where combines the previous WHERE condition with `cond` using an OR expression.
pub fn (b SelectBuilder) or_where(cond string, params ...string) SelectBuilder {
	mut wheres := b.wheres.clone()
	if wheres.len == 0 {
		wheres << cond
	} else {
		last_idx := wheres.len - 1
		wheres[last_idx] = '(${wheres[last_idx]}) OR (${cond})'
	}
	mut wp := b.where_params.clone()
	for item in params {
		wp << item
	}
	mut all_p := wp.clone()
	all_p << b.having_params
	return SelectBuilder{
		...b
		wheres:       wheres
		where_params: wp
		params:       all_p
	}
}

// group_by appends one or more columns to the GROUP BY clause.
pub fn (b SelectBuilder) group_by(columns ...string) SelectBuilder {
	mut group_bys := b.group_bys.clone()
	for c in columns {
		group_bys << c
	}
	return SelectBuilder{
		...b
		group_bys: group_bys
	}
}

// having appends a condition and its bound parameters to the HAVING clause.
pub fn (b SelectBuilder) having(cond string, params ...string) SelectBuilder {
	mut havings := b.havings.clone()
	havings << cond
	mut hp := b.having_params.clone()
	for item in params {
		hp << item
	}
	mut all_p := b.where_params.clone()
	all_p << hp
	return SelectBuilder{
		...b
		havings:       havings
		having_params: hp
		params:        all_p
	}
}

// order_by appends a column and sort direction to the ORDER BY clause.
pub fn (b SelectBuilder) order_by(column string, direction OrderDirection) SelectBuilder {
	mut order_bys := b.order_bys.clone()
	dir_str := match direction {
		.asc { 'ASC' }
		.desc { 'DESC' }
	}

	order_bys << '${column} ${dir_str}'
	return SelectBuilder{
		...b
		order_bys: order_bys
	}
}

// limit sets the maximum number of rows to return in the LIMIT clause.
pub fn (b SelectBuilder) limit(n int) SelectBuilder {
	return SelectBuilder{
		...b
		limit_val: n
	}
}

// offset sets the row offset in the OFFSET clause.
pub fn (b SelectBuilder) offset(n int) SelectBuilder {
	return SelectBuilder{
		...b
		offset_val: n
	}
}

// paginate sets LIMIT and OFFSET for 1-based page number `page` and page size `per_page`.
pub fn (b SelectBuilder) paginate(page int, per_page int) SelectBuilder {
	p := if page < 1 { 1 } else { page }
	pp := if per_page < 1 { 10 } else { per_page }
	off := (p - 1) * pp
	return b.limit(pp).offset(off)
}

// build returns the parameterized SQL SELECT string with `?` placeholders and the ordered parameter slice.
pub fn (b SelectBuilder) build() (string, []string) {
	mut query := 'SELECT ${b.columns.join(', ')}'
	if b.table.len > 0 {
		query += ' FROM ${b.table}'
	}
	for j in b.joins {
		query += ' ${j}'
	}
	if b.wheres.len > 0 {
		query += ' WHERE ' + b.wheres.join(' AND ')
	}
	if b.group_bys.len > 0 {
		query += ' GROUP BY ' + b.group_bys.join(', ')
	}
	if b.havings.len > 0 {
		query += ' HAVING ' + b.havings.join(' AND ')
	}
	if b.order_bys.len > 0 {
		query += ' ORDER BY ' + b.order_bys.join(', ')
	}
	if b.limit_val >= 0 {
		query += ' LIMIT ${b.limit_val}'
	}
	if b.offset_val >= 0 {
		query += ' OFFSET ${b.offset_val}'
	}
	mut ordered_params := b.where_params.clone()
	ordered_params << b.having_params
	return query, ordered_params
}

// to_sql builds the SQL SELECT statement with all parameter values safely escaped and inlined.
pub fn (b SelectBuilder) to_sql() string {
	query, params := b.build()
	return inline_params(query, params)
}

// -----------------------------------------------------------------------
// INSERT Builder
// -----------------------------------------------------------------------

// InsertBuilder constructs single-row or multi-row parameterized SQL INSERT statements.
pub struct InsertBuilder {
pub:
	table   string
	columns []string
	rows    [][]string
}

// insert_into starts a new InsertBuilder for the given table.
pub fn insert_into(table string) InsertBuilder {
	return InsertBuilder{
		table: table
	}
}

// columns sets the target column names for the INSERT statement.
pub fn (b InsertBuilder) columns(cols ...string) InsertBuilder {
	return InsertBuilder{
		...b
		columns: cols.clone()
	}
}

// values appends a row of column values to the INSERT statement.
pub fn (b InsertBuilder) values(vals ...string) InsertBuilder {
	mut new_row := []string{cap: vals.len}
	for v in vals {
		new_row << v
	}
	mut rows := [][]string{cap: b.rows.len + 1}
	for r in b.rows {
		rows << r
	}
	rows << new_row
	return InsertBuilder{
		...b
		rows: rows
	}
}

// row appends a row of column-name to value mappings to the INSERT statement.
pub fn (b InsertBuilder) row(row_map map[string]string) InsertBuilder {
	mut cols := b.columns.clone()
	if cols.len == 0 {
		for k, _ in row_map {
			cols << k
		}
	}
	mut new_row := []string{cap: cols.len}
	for col in cols {
		new_row << (row_map[col] or { '' })
	}
	mut rows := [][]string{cap: b.rows.len + 1}
	for r in b.rows {
		rows << r
	}
	rows << new_row
	return InsertBuilder{
		...b
		columns: cols
		rows:    rows
	}
}

// build returns the parameterized SQL INSERT string with `?` placeholders and the ordered parameter slice.
pub fn (b InsertBuilder) build() (string, []string) {
	if b.columns.len == 0 || b.rows.len == 0 {
		return '', []string{}
	}
	for row in b.rows {
		if row.len != b.columns.len {
			return '', []string{}
		}
	}
	mut query := 'INSERT INTO ${b.table} (${b.columns.join(', ')}) VALUES '
	mut placeholders := []string{}
	mut all_params := []string{}

	row_placeholder := '(' + []string{len: b.columns.len, init: '?'}.join(', ') + ')'
	for row in b.rows {
		placeholders << row_placeholder
		for v in row {
			all_params << v
		}
	}
	query += placeholders.join(', ')
	return query, all_params
}

// to_sql builds the SQL INSERT statement with all parameter values safely escaped and inlined.
pub fn (b InsertBuilder) to_sql() string {
	query, params := b.build()
	return inline_params(query, params)
}

// -----------------------------------------------------------------------
// UPDATE Builder
// -----------------------------------------------------------------------

// UpdateBuilder constructs parameterized SQL UPDATE statements.
pub struct UpdateBuilder {
pub:
	table        string
	sets         []string
	set_params   []string
	where_params []string
	params       []string
	wheres       []string
}

// update starts a new UpdateBuilder for the given table.
pub fn update(table string) UpdateBuilder {
	return UpdateBuilder{
		table: table
	}
}

// set appends a `column = ?` assignment to the UPDATE statement.
pub fn (b UpdateBuilder) set(column string, val string) UpdateBuilder {
	mut sets := b.sets.clone()
	sets << '${column} = ?'
	mut sp := b.set_params.clone()
	sp << val
	mut all_p := sp.clone()
	all_p << b.where_params
	return UpdateBuilder{
		...b
		sets:       sets
		set_params: sp
		params:     all_p
	}
}

// set_map appends multiple `column = ?` assignments from a map to the UPDATE statement.
pub fn (b UpdateBuilder) set_map(values map[string]string) UpdateBuilder {
	mut sets := b.sets.clone()
	mut sp := b.set_params.clone()
	for k, v in values {
		sets << '${k} = ?'
		sp << v
	}
	mut all_p := sp.clone()
	all_p << b.where_params
	return UpdateBuilder{
		...b
		sets:       sets
		set_params: sp
		params:     all_p
	}
}

// where appends an AND condition and its bound parameters to the UPDATE statement's WHERE clause.
pub fn (b UpdateBuilder) where(cond string, params ...string) UpdateBuilder {
	mut wheres := b.wheres.clone()
	wheres << cond
	mut wp := b.where_params.clone()
	for item in params {
		wp << item
	}
	mut all_p := b.set_params.clone()
	all_p << wp
	return UpdateBuilder{
		...b
		wheres:       wheres
		where_params: wp
		params:       all_p
	}
}

// build returns the parameterized SQL UPDATE string with `?` placeholders and the ordered parameter slice.
pub fn (b UpdateBuilder) build() (string, []string) {
	if b.sets.len == 0 {
		return '', []string{}
	}
	mut query := 'UPDATE ${b.table} SET ' + b.sets.join(', ')
	if b.wheres.len > 0 {
		query += ' WHERE ' + b.wheres.join(' AND ')
	}
	mut ordered_params := b.set_params.clone()
	ordered_params << b.where_params
	return query, ordered_params
}

// to_sql builds the SQL UPDATE statement with all parameter values safely escaped and inlined.
pub fn (b UpdateBuilder) to_sql() string {
	query, params := b.build()
	return inline_params(query, params)
}

// -----------------------------------------------------------------------
// DELETE Builder
// -----------------------------------------------------------------------

// DeleteBuilder constructs parameterized SQL DELETE statements.
pub struct DeleteBuilder {
pub:
	table  string
	wheres []string
	params []string
}

// delete_from starts a new DeleteBuilder for the given table.
pub fn delete_from(table string) DeleteBuilder {
	return DeleteBuilder{
		table: table
	}
}

// where appends an AND condition and its bound parameters to the DELETE statement's WHERE clause.
pub fn (b DeleteBuilder) where(cond string, params ...string) DeleteBuilder {
	mut wheres := b.wheres.clone()
	wheres << cond
	mut p := b.params.clone()
	for item in params {
		p << item
	}
	return DeleteBuilder{
		...b
		wheres: wheres
		params: p
	}
}

// build returns the parameterized SQL DELETE string with `?` placeholders and the ordered parameter slice.
pub fn (b DeleteBuilder) build() (string, []string) {
	mut query := 'DELETE FROM ${b.table}'
	if b.wheres.len > 0 {
		query += ' WHERE ' + b.wheres.join(' AND ')
	}
	return query, b.params.clone()
}

// to_sql builds the SQL DELETE statement with all parameter values safely escaped and inlined.
pub fn (b DeleteBuilder) to_sql() string {
	query, params := b.build()
	return inline_params(query, params)
}

// -----------------------------------------------------------------------
// Parameter Inlining
// -----------------------------------------------------------------------

fn inline_params(query string, params []string) string {
	mut sb := strings.new_builder(query.len + params.len * 16)
	mut param_idx := 0
	mut in_quote := false
	mut quote_char := u8(0)
	mut in_line_comment := false
	mut in_block_comment := false

	for i := 0; i < query.len; i++ {
		b := query[i]
		if in_line_comment {
			sb.write_u8(b)
			if b == `\n` {
				in_line_comment = false
			}
			continue
		}
		if in_block_comment {
			sb.write_u8(b)
			if b == `*` && i + 1 < query.len && query[i + 1] == `/` {
				sb.write_u8(query[i + 1])
				i++
				in_block_comment = false
			}
			continue
		}
		if !in_quote {
			if b == `-` && i + 1 < query.len && query[i + 1] == `-` {
				sb.write_u8(b)
				sb.write_u8(query[i + 1])
				i++
				in_line_comment = true
				continue
			}
			if b == `/` && i + 1 < query.len && query[i + 1] == `*` {
				sb.write_u8(b)
				sb.write_u8(query[i + 1])
				i++
				in_block_comment = true
				continue
			}
			if b == `'` || b == `"` || b == `\`` {
				in_quote = true
				quote_char = b
				sb.write_u8(b)
				continue
			}
			if b == `[` {
				in_quote = true
				quote_char = `]`
				sb.write_u8(b)
				continue
			}
		} else if b == quote_char {
			// Check for doubled quote escape '' or "" or ``
			if quote_char != `]` && i + 1 < query.len && query[i + 1] == quote_char {
				sb.write_u8(b)
				sb.write_u8(query[i + 1])
				i++
			} else {
				in_quote = false
				sb.write_u8(b)
			}
			continue
		}
		if !in_quote && b == `?` && param_idx < params.len {
			sb.write_string(escape_string(params[param_idx]))
			param_idx++
		} else {
			sb.write_u8(b)
		}
	}
	return sb.str()
}
