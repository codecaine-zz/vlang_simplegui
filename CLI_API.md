# SimpleCLI: Headless Console & RAD Toolkit for V

> **📚 Master Documentation Navigation:**
> [🏠 Main README](README.md) • [📘 GUI API Reference (`docs/API.md`)](docs/API.md) • [🎨 Custom Themes Vault (`custom_themes/README.md`)](custom_themes/README.md) • [🖥️ 47 GUI Workstations (`applications/README.md`)](applications/README.md) • [⌨️ SimpleCLI Reference (`CLI_API.md`)](CLI_API.md) • [🛠️ 49 CLI Apps (`cli_apps/README.md`)](cli_apps/README.md) • [🧰 45 Utility Modules (`UTILS_API.md`)](UTILS_API.md) • [📝 Changelog](CHANGELOG.md)

`simplecli` is a comprehensive, lightweight, zero-window console utility framework and Rapid Application Development (RAD) toolkit for the V programming language. It brings all the cross-platform OS system calls, hardware resource monitoring, desktop notifications, speech synthesis, standard path resolvers, cryptography, HTTP, generic data structures, string similarity metrics, multi-level logging, CLI flag parsing, and stdlib wrappers directly to command-line utilities and automation scripts without requiring any graphical window backend (no `gg`/`sokol` GUI dependencies).

---

## Table of Contents

1. [Architecture & Application Lifecycle](#1-architecture--application-lifecycle)
2. [CLI Flags & Argument Parsing](#2-cli-flags--argument-parsing)
3. [Console UI & RAD Components](#3-console-ui--rad-components)
4. [Interactive Prompts, Menus & Input Validation](#4-interactive-prompts-menus--input-validation)
5. [Multi-Step Task Pipeline Runner](#5-multi-step-task-pipeline-runner)
6. [Structured Multi-Level Logging & File Logging](#6-structured-multi-level-logging--file-logging)
7. [Benchmark & Execution Timing](#7-benchmark--execution-timing)
8. [Reactive State Store & File Persistence](#8-reactive-state-store--file-persistence)
9. [Safe Process Execution & Subprocess Control](#9-safe-process-execution--subprocess-control)
10. [Hardware Telemetry & Resource Probing](#10-hardware-telemetry--resource-probing)
11. [Standard OS Directory Resolution & File System](#11-standard-os-directory-resolution--file-system)
12. [Network, Wi-Fi & TCP Port Diagnostics](#12-network-wi-fi--tcp-port-diagnostics)
13. [Desktop Notifications, Speech & Audio Utilities](#13-desktop-notifications-speech--audio-utilities)
14. [System Clipboard & Headless OS Native Dialogs](#14-system-clipboard--headless-os-native-dialogs)
15. [HTTP Client & REST APIs](#15-http-client--rest-apis)
16. [Cryptography, Hashing & Random Utilities](#16-cryptography-hashing--random-utilities)
17. [Encodings, Data Formats & Serialization](#17-encodings-data-formats--serialization)
18. [Validation Engine](#18-validation-engine)
19. [Generic Collections, Queues & String Metrics](#19-generic-collections-queues--string-metrics)
20. [Statistical Math Calculations](#20-statistical-math-calculations)
21. [Standalone Package Functions (1-Liners)](#21-standalone-package-functions-1-liners)
22. [Production Console Applications Suite](#22-production-console-applications-suite)

---

## 1. Architecture & Application Lifecycle

### Core Application Struct (`SimpleCli`)

```v
@[heap]
pub struct SimpleCli {
pub mut:
	app_name    string = 'SimpleCli Application'
	version     string = '1.0.0'
	author      string
	description string
	debug_mode  bool
	no_color    bool
	silent_mode bool
	log_level   LogLevel = .info
	log_file    string
	state       map[string]string
	flags_def   map[string]FlagOption
	flags_val   map[string]string
	pos_args    []string
	bench_start time.Time
}
```

### Constructors

```v
module main

import simplecli

fn main() {
	// Standard constructor with application name
	mut app1 := simplecli.new('MyTool')

	// Constructor with explicit application name and version
	mut app2 := simplecli.new_app('DeployPilot', '2.1.0')

	// Default constructor (initializes app_name to 'SimpleCli')
	mut app3 := simplecli.init_app()
}
```

### Configuration & Fluent Setup

```v
mut app := simplecli.new('Sentinel')
	.set_version('1.5.0')
	.set_author('DevOps Core Team')
	.set_description('High-performance endpoint guardian & telemetry reporter')
	.set_debug(true)
	.set_no_color(false)
	.set_silent(false)
	.set_log_level(.info)
	.set_log_file('/tmp/sentinel.log')
```

---

## 2. CLI Flags & Argument Parsing

### Flag Definition Struct (`FlagOption`)

```v
pub struct FlagOption {
pub:
	name        string
	short       string
	kind        string // 'string', 'int', 'bool', 'float'
	default_val string
	desc        string
}
```

### Registering & Parsing Flags

Define typed CLI flags with long names, short aliases, default values, and help descriptions:

```v
mut app := simplecli.new_app('Migrator', '2.0.0')

// Register typed flags
app.add_flag_string('config', 'c', 'app.config.json', 'Path to JSON configuration')
app.add_flag_int('port', 'p', 5432, 'Target database port')
app.add_flag_bool('dry-run', 'd', false, 'Simulate execution without modifying state')
app.add_flag_float('timeout', 't', 30.0, 'Network timeout in seconds')

// Parse os.args[1..]. Built-in --help/-h and --version/-v exit with status 0;
// invalid usage writes a diagnostic to stderr and exits with status 2.
app.parse_cli()!

// Access parsed flag values
cfg_file   := app.get_flag_string('config')
db_port    := app.get_flag_int('port')
is_dry_run := app.get_flag_bool('dry-run')
timeout    := app.get_flag_float('timeout')
extra_args := app.get_positional_args() // Non-flag positional arguments

// Explicitly display the generated help table on demand
app.print_help()
```

Custom argument slices can also be parsed directly with `app.parse_args(raw_args []string)`:

```v
app.parse_args(['--config', 'custom.json', '--port', '8080', 'deploy', 'target1'])!
```

`parse_args` returns an error for unknown options, options missing required values, and malformed `int`, `float`, or explicit `bool` values (`true`, `false`, `1`, `0`, `yes`, `no`). Long option values may use either `--name value` or `--name=value`; embedded equals signs are preserved. Built-in flags `--help`/`-h`, `--version`/`-v`, `--debug`, `--no-color`, and `--silent` are handled automatically.

---

## 3. Console UI & RAD Components

### Console Output & Terminal ANSI Styling

```v
// Print without or with a trailing newline (automatically suppressed in silent_mode)
app.print('Connecting... ')
app.println(app.green('connected!'))

// Apply custom ANSI styling function (respects app.no_color)
styled := app.colorize('Custom styled text', fn (s string) string {
	return s
})

// Built-in ANSI color and style helpers
app.println(app.bold('Bold headline text'))
app.println(app.dim('Muted debug commentary'))
app.println(app.green('✓ All 48 tests passed successfully'))
app.println(app.cyan('ℹ Connecting to database cluster...'))
app.println(app.yellow('⚠ High disk usage detected'))
app.println(app.red('✖ Fatal connection drop'))
app.println(app.blue('⚡ Initializing thread pool'))
app.println(app.magenta('◆ Deployment tag v2.4.0'))
```

### Steps, Dividers, Banners & Panels

```v
// Step indicator with number and title
app.step(1, 'Compiling Native Binaries')
app.step(2, 'Running Static Analysis Checks')

// Horizontal dividers
app.divider('─', 60)
app.divider('=', 80)

// Header banner with title and subtitle
app.banner('Sentinel Infrastructure Pilot', 'Production Node 04 - us-east-1')

// Framed panel with bordered title
app.panel('Cluster Health', 'All 12 nodes reporting healthy heartbeat (RTT < 4ms).')

// Card style panel (alias for panel)
app.card('Security Status', 'TLS 1.3 Strict Mode enforced. Certificates valid for 84 days.')
```

### Key-Value Pairs & Formatted Tables

```v
// Output aligned key-value status dictionary
app.print_kv({
	'Host Name':    'srv-prod-api-01'
	'IP Address':   '10.0.4.18'
	'Architecture': 'aarch64 (Apple Silicon)'
	'Uptime':       '14 days, 6 hours'
})

// Output formatted data grid with aligned column widths and borders
app.table(
	['Endpoint', 'Protocol', 'Latency', 'Status'],
	[
		['https://api.internal/v1', 'HTTP/2', '12.4 ms', '200 OK'],
		['https://auth.internal', 'HTTP/2', '8.1 ms', '200 OK'],
		['postgres://10.0.0.5:5432', 'TCP', '1.2 ms', 'CONNECTED'],
		['redis://10.0.0.9:6379', 'TCP', '0.4 ms', 'CONNECTED'],
	]
)
```

### Dynamic Progress Bars & Spinners

```v
// Render progress bars in long-running loops
total_items := 100.0
for i in 1 .. 101 {
	app.progress_bar(f64(i), total_items, 'Migrating database tables')
	time.sleep(20 * time.millisecond)
}

// Display animated terminal spinner during synchronous operations
app.spinner('Synchronizing repository submodules...', 1500)
```

### Unicode Sparklines

Render inline high-density trend visualizations using Unicode block elements (` ▂▃▄▅▆▇█`):

```v
latencies := [12.0, 15.0, 45.0, 90.0, 120.0, 80.0, 30.0, 14.0]
spark := app.sparkline(latencies)
app.info('Latency Trend (last 8 ticks): ${spark}')
// Output: Latency Trend (last 8 ticks):  ▂▄▆█▆▂ 
```

### Horizontal Bar Charts

Visualize distributions, resource utilization, or benchmark comparative results:

```v
app.bar_chart('Resource Allocation (%)', {
	'CPU Core 0': 42.5
	'CPU Core 1': 89.0
	'Memory':     64.2
	'Disk /':     23.8
}, 30) // 30-character max bar width
```

### Meter Gauges

Display single-metric gauges with automatic green/yellow/red threshold badges:

```v
app.gauge('PostgreSQL Connection Pool', 48.0, 50.0, 'conns')
// Output: PostgreSQL Connection Pool: [████████████████████░░] 48.0/50.0 conns (96.0%) [CRITICAL]

app.gauge('Storage Capacity', 34.2, 100.0, 'GB')
// Output: Storage Capacity: [██████░░░░░░░░░░░░░░] 34.2/100.0 GB (34.2%) [OK]
```

### Hierarchical Tree Visualizer (`TreeNode`)

Render nested dependency graphs, filesystem trees, or structured schemas with Unicode branch glyphs (`├──`, `└──`, `│   `):

```v
pub struct TreeNode {
pub mut:
	label    string
	children []TreeNode
}
```

```v
mut root := simplecli.new_tree_node('production-cluster')

// Add child nodes by label string
mut db := root.add_child('postgres-db')
db.add_child('replica-01 (read-only)')
db.add_child('replica-02 (standby)')
root.add_child('redis-cache')

// Or construct a TreeNode subtree and attach it with add_node()
mut api := simplecli.new_tree_node('api-gateway')
api.add_child('auth-service')
api.add_child('payment-service')
root.add_node(api)

app.tree(root)
```

### Colorized Line Diff Viewer

Generate and display unified line-by-line diffs with line numbering and colored change annotations:

```v
old_config := 'port: 8080\nworkers: 4\nenv: staging'
new_config := 'port: 8080\nworkers: 8\nenv: production\ntls: true'

// Output colorized line diff to console:
app.diff(old_config, new_config)

// Or retrieve formatted diff string:
diff_text := app.diff_text(old_config, new_config)
```

### Status Badges & Alert Callout Boxes (`AlertKind`)

```v
pub enum AlertKind {
	info
	success
	warning
	caution
	tip
	note
}
```

```v
// Bracketed status badges colored by LogLevel (.trace, .debug, .info, .warn, .error, .silent)
prod_badge := app.badge('ENV', 'PRODUCTION', .warn)
app.println('${prod_badge} Initializing migration sequence...')

// Styled alert callout boxes (.info, .success, .warning, .caution, .tip, .note)
app.alert(.info, 'Configuration Loaded', 'Loaded 42 rules from settings.json.')
app.alert(.success, 'Deployment Verified', 'All health checks returned 200 OK.')
app.alert(.warning, 'High Memory Threshold', 'Memory utilization exceeded 85%.')
app.alert(.caution, 'Destructive Action', 'Dropping database table `audit_logs`.')
app.alert(.tip, 'Pro Tip', 'Pass `--silent` to disable interactive output.')
app.alert(.note, 'Maintenance Window', 'Scheduled snapshot runs at 02:00 UTC.')
```

### Task Checklist Items (`TaskStatus`)

Format structured task execution checklists:

```v
pub enum TaskStatus {
	pending
	running
	done
	failed
	skipped
}
```

```v
app.task_item('Compile C sources', .done, 140)         // ✓ Compile C sources (140 ms)
app.task_item('Run static analysis', .running, 0)      // ⏳ Run static analysis...
app.task_item('Deploy image to registry', .pending, 0) // ○ Deploy image to registry
app.task_item('Run smoke tests', .failed, 55)          // ✖ Run smoke tests [FAILED] (55 ms)
app.task_item('Upload optional symbols', .skipped, 0)  // ↷ Upload optional symbols [SKIPPED]
```

### Table Data Format Exporters & Markdown Rendering

Convert table data structures to standard formats or render Markdown inside the terminal:

```v
headers := ['ID', 'Name', 'Role']
rows := [
	['1', 'Alice, VP', 'Admin'],
	['2', 'Bob', 'Developer'],
]

// Convert to CSV string:
csv_data := app.table_to_csv(headers, rows)

// Convert to Markdown table:
md_table := app.table_to_markdown(headers, rows)

// Convert to JSON array of objects:
json_data := app.table_to_json(headers, rows)

// Syntax-highlight JSON with ANSI colors in terminal:
app.println(app.json_highlight('{"status": "healthy", "uptime_sec": 86400, "debug": false}'))

// Render Markdown document to terminal with styled headings and lists:
app.render_markdown('# Release Notes\n## Improvements\n* Faster CLI startup\n* Zero-window RAD components\n> Ready for production.')
```

---

## 4. Interactive Prompts, Menus & Input Validation

### Text, Secret, Custom-Validated & Typed Prompts

```v
// Plain string prompt with default fallback
username := app.prompt('Enter admin username', 'admin')

// Sensitive password prompt
api_token := app.prompt_password('Enter secret API access token')

// Custom-validated prompt with retry loop until validator fn returns true
env_tag := app.prompt_validated(
	'Enter environment tag (dev/staging/prod)',
	'dev',
	fn (val string) bool {
		return val in ['dev', 'staging', 'prod']
	},
	'Environment must be one of: dev, staging, prod'
)

// Validated email prompt (re-prompts until a valid email syntax is entered)
email := app.prompt_email('Enter alert recipient email', 'dev@domain.com')

// Validated URL prompt (re-prompts until a valid http:// or https:// URL is entered)
webhook := app.prompt_url('Enter Slack Webhook URL', 'https://hooks.slack.com/services/T00/B00/X00')

// Constrained numeric prompt between min and max bounds [min, max]
threads := app.prompt_number('Worker thread concurrency', 8, 1, 64)

// Yes/No confirmation prompt (returns bool)
proceed := app.confirm('Do you want to apply migrations to production?', false)
```

### Single, Multi-Select & Fuzzy Search Menus

```v
// Single selection menu by index or exact option text
choice := app.select('Choose build target environment:', [
	'Local Development',
	'Staging Integration',
	'Production Release',
])

// Multi-select menu with comma-separated numbers (e.g. "1, 3")
selected := app.multi_select('Select deployment components to verify:', [
	'PostgreSQL Database',
	'Redis Cache',
	'Kafka Event Streams',
	'Elasticsearch Index',
])

// Interactive Fuzzy Selector with query substring and Levenshtein similarity fallback
branch := app.fuzzy_select('Search and checkout Git branch:', [
	'main',
	'feature/rad-components',
	'feature/graphql-api',
	'bugfix/state-persistence',
])
```

### Interactive Form / Wizard Builder (`FormField`, `FormFieldKind`)

Collect multi-field configuration forms inside a stylish framed console wizard:

```v
pub enum FormFieldKind {
	text
	number
	boolean
	password
}

pub struct FormField {
pub:
	key         string
	label       string
	kind        FormFieldKind = .text
	default_val string
	required    bool
}
```

```v
form_data := app.form('Deploy Microservice Wizard', [
	simplecli.FormField{
		key:      'name'
		label:    'Service Name'
		kind:     .text
		required: true
	},
	simplecli.FormField{
		key:         'port'
		label:       'Listen Port'
		kind:        .number
		default_val: '8080'
	},
	simplecli.FormField{
		key:      'secret'
		label:    'Master API Key'
		kind:     .password
		required: true
	},
])

service_name := form_data['name']
listen_port  := form_data['port']
```

### Path & Directory Validation Prompt (`PathMode`)

Prompt for user file paths with automatic `~` expansion and existence mode checks:

```v
pub enum PathMode {
	any
	must_exist
	file
	directory
}
```

```v
cert_path  := app.prompt_path('Enter path to TLS certificate', '~/.config/certs/app.pem', .file)
target_dir := app.prompt_path('Enter deployment directory', '/var/www/app', .directory)
```

---

## 5. Multi-Step Task Pipeline Runner

Execute multi-stage automation workflows with live step progress, step timers, and summary reporting:

### Pipeline Structs (`PipelineStep`, `Pipeline`)

```v
pub struct PipelineStep {
pub:
	name    string
	step_fn fn () bool @[required]
}

@[heap]
pub struct Pipeline {
pub mut:
	title string
	steps []PipelineStep
	cli   &SimpleCli
}
```

### Running a Multi-Step Pipeline

```v
mut pipeline := app.new_pipeline('Production Release Pipeline')

pipeline.add_step('Clean temporary build artifacts', fn () bool {
	os.rmdir_all('/tmp/build') or {}
	return true
})

pipeline.add_step('Compile native binaries', fn () bool {
	time.sleep(200 * time.millisecond)
	return true
})

pipeline.add_step('Run security vulnerability scan', fn () bool {
	time.sleep(150 * time.millisecond)
	return true
})

pipeline.add_step('Deploy container image to registry', fn () bool {
	time.sleep(300 * time.millisecond)
	return true
})

// Run pipeline: displays live checkmarks, per-step durations, and total duration summary
success := pipeline.run()
```

---

## 6. Structured Multi-Level Logging & File Logging

### Log Severity Threshold (`LogLevel`)

```v
pub enum LogLevel {
	trace  = 0
	debug  = 1
	info   = 2
	warn   = 3
	error  = 4
	silent = 5
}
```

### Console & File Logging

`simplecli` provides structured logging with timestamps, level tags, ANSI colors, and automatic file log streaming:

```v
mut app := simplecli.new('Runner')

// Configure log file path for persistent audit logs (expands '~' and creates parent dirs)
app.set_log_file('/var/log/mytool.log')

// Set minimum display log level (.trace, .debug, .info, .warn, .error, .silent)
app.set_log_level(.debug)

// Multi-level log calls
app.trace('Detailed execution trace dump')
app.debug('Loaded configuration from config.json with 14 keys')
app.info('Worker thread pool initialized with 8 threads')
app.success('Successfully provisioned staging environment')
app.warn('High memory usage detected (> 85%)')
app.error('Failed to connect to secondary database node')

// Fatal log call outputs error to stderr, writes to log file, and exits process with code 1
// app.fatal('Unrecoverable database corruption')
```

---

## 7. Benchmark & Execution Timing

Track execution duration with millisecond precision:

```v
// Reset the internal execution timer
app.reset_timer()

// Perform heavy computation or batch I/O
time.sleep(340 * time.millisecond)

// Read elapsed milliseconds since new() or reset_timer()
elapsed := app.elapsed_ms() // i64 (e.g. 340)
app.info('Task completed in ${elapsed} ms')

// Print formatted elapsed runtime ("⚡ Execution time: 340 ms")
app.print_elapsed()
```

---

## 8. Reactive State Store & File Persistence

Store key-value runtime configuration in memory, retrieve typed values with fallbacks, and persist state to JSON files:

```v
// Set memory-backed state values
app.set_state('last_sync', '2026-08-22T12:00:00Z')
app.set_state('active_profile', 'staging-us-east')
app.set_state('retry_limit', '5')
app.set_state('tls_verified', 'true')

// Retrieve string, int, and bool state values with fallback defaults
profile      := app.get_state('active_profile', 'default')
retry_limit  := app.get_state_int('retry_limit', 3)
tls_verified := app.get_state_bool('tls_verified', false)

// Save full key-value state to persistent JSON file on disk
state_dir  := simplecli.get_app_state_dir('deploybot')
state_path := '${state_dir}/state.json'
app.save_state(state_path)!

// Clear all in-memory state entries
app.clear_state()

// Restore state from JSON file on subsequent runs
app.load_state(state_path)!
```

---

## 9. Safe Process Execution & Subprocess Control

Execute system commands safely with strict POSIX argument quoting, timeouts, exponential backoff retries, and parallel background threads.

### Execution Result Struct (`ExecResult`)

```v
pub struct ExecResult {
pub:
	output      string
	exit_code   int
	duration_ms i64
	timed_out   bool
	attempts    int
}
```

### Execution Functions

```v
// Basic synchronous execution returning (trimmed_output, exit_code)
output, code := app.exec('uptime')

// Safe argument execution (quotes tool and every argument with POSIX single-quotes)
branch, _ := app.exec_safe('git', ['rev-parse', '--abbrev-ref', 'HEAD'])

// Fallback execution (returns fallback string if command fails or returns empty output)
git_tag := app.exec_or('git describe --tags', 'v0.0.0-dev')

// Execute inside a specific working directory (dir, command)
status, _ := app.exec_in_dir('/Users/developer/project', 'git status --short')

// Execute asynchronously in a background thread (non-blocking)
app.exec_bg('open https://github.com')

// Execute with a hard timeout in milliseconds -> returns (output, exit_code, timed_out)
ping_out, ping_code, timed_out := app.exec_timeout('ping -c 10 1.1.1.1', 2000)
if timed_out {
	app.warn('Ping timed out (code ${ping_code}): ${ping_out}')
}

// Execute with automatic retry logic and exponential backoff
// Signature: exec_retry(command string, max_retries int, initial_delay_ms int, backoff_factor f64) ExecResult
res_retry := app.exec_retry('curl -sf https://api.service.internal/health', 3, 500, 2.0)
app.info('Attempts: ${res_retry.attempts}, Exit Code: ${res_retry.exit_code}, Duration: ${res_retry.duration_ms} ms')

// Parallel concurrent command execution across background threads
results := app.parallel_exec([
	'git fetch origin',
	'npm --version',
	'v version',
])
for r in results {
	app.info('Exit: ${r.exit_code} | Duration: ${r.duration_ms} ms | Output: ${r.output}')
}
```

### Process Control, Readiness Probes & Environment Variables

```v
// Current process PID & system uptime in seconds
pid        := app.get_pid()
uptime_sec := app.get_uptime_seconds()

// Check if a process is running by executable name
is_alive := app.is_process_running('postgres')

// Terminate process by name or by exact PID
app.kill_process('worker_daemon')
app.kill_process_by_pid(12345)

// Process and open file descriptor counts
proc_count := app.get_running_process_count()
open_fds   := app.get_open_file_count()

// Executable PATH lookup and assertions
has_docker  := app.exists_in_path('docker') // Aliases: app.command_exists('docker'), app.has_command('docker')
exists_cmd  := app.command_exists('git')
has_cmd     := app.has_command('v')
docker_path := app.find_executable('docker')
git_bin     := app.require_command('git')! // Returns full path or error if missing

// Readiness probes: block until a file appears or a TCP port accepts connections
file_ready := app.wait_for_file('/tmp/worker.ready', 5000)
port_ready := app.wait_for_port('127.0.0.1', 5432, 5000)

// Process environment variables
app.set_env('APP_ENV', 'production')
current_env := app.get_env('APP_ENV')
app.unset_env('APP_ENV')

// Shell argument, path quoting, and filename sanitization helpers
safe_arg   := simplecli.quote_arg('unsafe input; rm -rf /')
safe_path  := simplecli.quote_path('~/My Documents/Report.pdf')
clean_name := simplecli.sanitize_filename('../../../etc/passwd') // returns '______etc_passwd'
```

---

## 10. Hardware Telemetry & Resource Probing

Monitor CPU, Memory, Swap, Load Averages, Battery, Disk utilization, and OS theme settings:

### Disk Usage Struct (`DiskStats`)

```v
pub struct DiskStats {
pub:
	total_bytes u64
	free_bytes  u64
	used_bytes  u64
	percent     f64
}
```

### Probing Hardware & OS Telemetry

```v
// CPU model, logical core count, architecture, and live usage percentage
cpu_model := app.get_cpu_info()          // e.g. "Apple M3 Max"
cpu_cores := app.get_cpu_cores()         // e.g. 16
cpu_arch  := app.get_cpu_architecture()  // e.g. "arm64"
cpu_usage := app.get_cpu_usage_percent() // Percentage 0.0 - 100.0
app.info('CPU: ${cpu_model} (${cpu_cores} cores, ${cpu_arch}) | Load: ${cpu_usage:.1f}%')

// System Load Averages (1 min, 5 min, 15 min)
load1, load5, load15 := app.get_load_average()
app.info('Load Average: ${load1:.2f}, ${load5:.2f}, ${load15:.2f}')

// Physical RAM & Swap summary strings
mem_info   := app.get_memory_info() // e.g. "64.0 GB RAM"
swap_usage := app.get_swap_usage()  // e.g. "total = 2048M  used = 128M  free = 1920M"

// Disk partition storage statistics
disk := app.get_disk_usage('/')!
app.info('Disk /: ${disk.used_bytes / 1073741824} GB used of ${disk.total_bytes / 1073741824} GB (${disk.percent:.1f}%)')

// Battery charge percentage (0-100, or -1 if no battery) & AC power state
battery_pct := app.get_battery_percent()
on_ac_power := app.is_on_ac_power()
if battery_pct >= 0 {
	app.info('Battery: ${battery_pct}% (AC Power: ${on_ac_power})')
}

// System Locale, OS Theme & Accent Color
locale := app.get_system_locale()       // e.g. "en_US"
theme  := app.get_system_theme()        // "dark" or "light"
accent := app.get_system_accent_color() // e.g. "blue"
```

---

## 11. Standard OS Directory Resolution & File System

### Standard OS Directories

Resolves standard paths across macOS, Linux, and Windows following Apple `Library` and XDG Base Directory guidelines:

```v
// Standalone standard directory resolvers
home_dir      := simplecli.get_user_home_dir()
app_cfg_dir   := simplecli.get_app_config_dir('DeployBot')
app_data_dir  := simplecli.get_app_data_dir('DeployBot')
app_cache_dir := simplecli.get_app_cache_dir('DeployBot')
app_state_dir := simplecli.get_app_state_dir('DeployBot')
app_log_dir   := simplecli.get_app_log_dir('DeployBot')

// Expand leading '~' or '~/' to the user's home directory
abs_path := simplecli.resolve_user_path('~/.config/myapp/settings.toml')

// Resolve system and app paths by keyword via SimpleCli instance:
// Supported keywords: 'home'/'user', 'temp'/'tmp', 'documents'/'docs', 'desktop',
// 'downloads', 'pictures'/'images', 'music', 'videos', 'config', 'data', 'state', 'cache', 'logs'
downloads_dir := app.get_system_path('downloads')
desktop_dir   := app.get_system_path('desktop')
documents_dir := app.get_system_path('documents')
pictures_dir  := app.get_system_path('pictures')
music_dir     := app.get_system_path('music')
videos_dir    := app.get_system_path('videos')
config_dir    := app.get_system_path('config')
```

### File Metadata Struct (`FileMetadata`)

```v
pub struct FileMetadata {
pub:
	path          string
	name          string
	size_bytes    u64
	is_dir        bool
	is_link       bool
	is_readable   bool
	is_writable   bool
	created_time  i64
	modified_time i64
}
```

### File System Utilities & Overwrite Options

`simplecli` provides built-in path resolution (expanding `~/`), automatic parent directory creation, and flexible file operations.

#### Overwrite & Persistence Behavior Matrix

| Method | Default Behavior | Parent Dirs Created? | Safe Non-Overwrite Alternative |
| :--- | :--- | :--- | :--- |
| `app.write_file(path, content)` | **Always Overwrites** (truncates target) | ✅ Yes | Guard with `if !app.file_exists(path)` |
| `app.append_file(path, content)` | **Appends** (preserves existing content) | ✅ Yes | N/A (non-destructive) |
| `app.copy_file(src, dst)!` | **Overwrites** destination if present | ✅ Yes | Guard with `if !app.file_exists(dst)` |
| `app.move_file(src, dst)!` | **Overwrites** / replaces destination | ❌ No | Guard with `if !app.file_exists(dst)` |
| `app.http_download(url, dst)!` | **Always Overwrites** destination | ✅ Yes | Guard with `if !app.file_exists(dst)` |
| `app.save_state(path)!` | **Always Overwrites** JSON state file | ✅ Yes | Check file existence or create backup |

---

#### 1. Default Overwrite vs. Safe Non-Overwrite Pattern

```v
file_path := simplecli.resolve_user_path('~/project/config.env')
content := 'API_KEY=secret_12345\nDEBUG=true\n'

// --- OPTION A: Direct Overwrite (Replaces entire content) ---
// Note: Automatically creates parent directories if they do not exist
app.write_file(file_path, content)
app.success('Wrote (overwrote) file: ${file_path}')

// --- OPTION B: Safe Non-Overwrite (Only write if file does NOT exist) ---
if !app.file_exists(file_path) {
	app.write_file(file_path, content)
	app.success('Created new file: ${file_path}')
} else {
	app.warn('File already exists: ${file_path}. Skipping write to prevent overwrite.')
}

// --- OPTION C: CLI Flag-Controlled Overwrite (--overwrite / -f) ---
overwrite_allowed := app.get_flag_bool('overwrite')

if !app.file_exists(file_path) || overwrite_allowed {
	app.write_file(file_path, content)
	app.info('File saved successfully (force/overwrite: ${overwrite_allowed})')
} else {
	app.error('File "${file_path}" exists. Pass --overwrite / -f to replace it.')
}

// --- OPTION D: Interactive Prompt Confirmation Before Overwrite ---
if app.file_exists(file_path) {
	if app.confirm('File "${file_path}" already exists. Overwrite?', false) {
		app.write_file(file_path, content)
		app.success('File overwritten by user confirmation.')
	} else {
		app.info('Operation aborted by user.')
	}
} else {
	app.write_file(file_path, content)
}

// --- OPTION E: Atomic Backup Before Overwrite ---
if app.file_exists(file_path) {
	bak_path := '${file_path}.bak'
	app.copy_file(file_path, bak_path)!
	app.info('Backed up existing file to ${bak_path}')
}
app.write_file(file_path, content)
```

---

#### 2. Appending to Files Without Overwriting

```v
log_file := '/tmp/audit.log'

// app.append_file appends a line without modifying existing contents:
app.append_file(log_file, '[2026-08-22 09:00:00] Worker started')
app.append_file(log_file, '[2026-08-22 09:01:00] Job completed successfully')

// Read back the complete file content:
full_log := app.read_file(log_file)
app.info('Log file size: ${full_log.len} bytes')
```

---

#### 3. Copy, Move, Directory, Metadata & Desktop Shell Operations

```v
src := '/tmp/source_data.csv'
dst := '/tmp/backups/target_data.csv'

// Copy with overwrite protection
if app.file_exists(dst) && !app.get_flag_bool('force') {
	app.warn('Destination already exists. Use --force to overwrite.')
} else {
	app.copy_file(src, dst)! // Automatically creates /tmp/backups/ if needed
	app.success('Copied ${src} -> ${dst}')
}

// Moving / Renaming files
app.move_file('/tmp/old_name.txt', '/tmp/new_name.txt')!

// Deleting files
app.delete_file('/tmp/temporary_cache.tmp')

// Directory management & checks
app.create_directory('/tmp/my_app/workspace/logs')
is_folder := app.is_dir('/tmp/my_app/workspace')
entries   := app.read_dir('/tmp/my_app')

// Recursive file listing by file extension (e.g. all '.v' files, or '' for all files)
v_files   := app.list_files_recursive('/path/to/project', '.v')
all_files := app.list_files_recursive('/path/to/project', '')

// Detailed File & Directory Metadata
if meta := app.get_file_metadata('/tmp/source_data.csv') {
	app.info('Path: ${meta.path} (Name: ${meta.name})')
	app.info('Size: ${meta.size_bytes} bytes | Symlink: ${meta.is_link}')
	app.info('Is Directory: ${meta.is_dir} | Modified: ${meta.modified_time}')
	app.info('Is Readable: ${meta.is_readable}, Is Writable: ${meta.is_writable}')
}

// Reveal a file in the native OS file manager (Finder / Explorer / xdg-open)
app.reveal_in_file_manager('/tmp/source_data.csv')

// Open a URL in the default desktop web browser
app.open_in_browser('https://vlang.io')
```

---

## 12. Network, Wi-Fi & TCP Port Diagnostics

Inspect local network interfaces, public IPs, Wi-Fi connectivity, DNS servers, and open listening ports:

```v
// Check Internet connectivity (checks DNS reachability on 1.1.1.1:53 or 8.8.8.8:53)
online := app.is_online()

// Fast TCP socket ping (returns true if port is listening and reachable)
is_pg_up    := app.ping_tcp_port('127.0.0.1', 5432, 500)
is_redis_up := app.ping_tcp_port('127.0.0.1', 6379, 500)

// IP addresses
local_ip  := app.get_local_ip()  // e.g. "192.168.1.42"
public_ip := app.get_public_ip() // e.g. "203.0.113.195" via https://api.ipify.org

// Hardware MAC Address & Wi-Fi SSID
mac_addr  := app.get_mac_address()
wifi_name := app.get_wifi_ssid()

// Default Gateway & Configured DNS Servers
gateway     := app.get_default_gateway()
dns_servers := app.get_dns_servers() // e.g. ["1.1.1.1", "8.8.8.8"]

// List active TCP listening ports on the local machine
listening_ports := app.get_listening_ports() // e.g. [22, 80, 443, 5432, 8080]
```

---

## 13. Desktop Notifications, Speech & Audio Utilities

```v
// Desktop notification banner (and its show_system_notification counterpart)
app.show_system_notification('Service Started', 'Worker pool is online.')
app.notify('Deployment Complete', 'Artifacts uploaded to S3 bucket.')

// macOS Dock attention bounce & icon text badge
app.bounce_dock()
app.set_dock_badge('3')

// Built-in OS sound effects (e.g. "Glass", "Ping", "Hero" on macOS)
app.play_system_sound('Glass')

// Text-to-Speech (TTS) voice synthesis
app.say('Deployment succeeded.')
app.speak_with_voice('Build failed on step 4.', 'Samantha')

// Terminal bell audio beep (single or repeated n times)
app.beep()
app.beep_n(3)

// System audio volume control (0-100) & mute state
app.set_volume(75)
vol := app.get_volume()

app.set_muted(true)
muted := app.is_muted()
app.set_muted(false)
```

---

## 14. System Clipboard & Headless OS Native Dialogs

Interact with the system clipboard and trigger native OS dialogs without GUI dependencies:

```v
// Copy, read, and clear system clipboard (supports Wayland/X11/pbcopy/PowerShell)
app.copy_to_clipboard('https://example.com/builds/123')
clip_text := app.get_clipboard_text()
app.clear_clipboard()

// Native OS confirmation dialog (returns true if user clicked OK / Yes)
confirmed := app.ask('Database Reset', 'Proceed with destructive database reset?')

// Native macOS text input dialog with default answer
passphrase := app.osascript_dialog('Please enter database migration passphrase:', '')

// Native macOS file and folder picker dialogs
selected_file   := app.osascript_choose_file()
selected_folder := app.osascript_choose_folder()
```

---

## 15. HTTP Client & REST APIs

### HTTP & URL Structs (`SimpleHttpResponse`, `SimpleURL`)

```v
pub struct SimpleHttpResponse {
pub:
	status_code int
	body        string
	url         string
}

pub struct SimpleURL {
pub:
	raw      string
	scheme   string
	host     string
	port     int
	path     string
	query    string
	fragment string
}
```

### HTTP Requests, URL Parsing & File Downloads

```v
// URL parsing
parsed_url := app.parse_url('https://api.github.com:443/repos/vlang/v?tab=tags#top')!
app.info('Scheme: ${parsed_url.scheme}, Host: ${parsed_url.host}, Port: ${parsed_url.port}, Path: ${parsed_url.path}')

// Quick synchronous HTTP GET and POST
body_get  := app.http_get('https://httpbin.org/get')
body_post := app.http_post('https://httpbin.org/post', '{"action": "ping"}')

// Full HTTP request with custom method (GET, POST, PUT, DELETE, PATCH, HEAD)
resp := app.http_request('GET', 'https://api.github.com/zen', '')!
app.info('Status: ${resp.status_code}, URL: ${resp.url}, Body: ${resp.body}')

// Direct remote file download to disk
app.http_download('https://example.com/assets.zip', '/tmp/assets.zip')!
```

---

## 16. Cryptography, Hashing & Random Utilities

### Hashing & Authentication

```v
// Standard cryptographic hashes
sha256_hash := app.crypto_sha256('secret message')
sha512_hash := app.crypto_sha512('secret message')
sha1_hash   := app.crypto_sha1('secret message')
md5_hash    := app.crypto_md5('secret message')

// HMAC-SHA256
hmac_sig := app.crypto_hmac_sha256('api_secret_key', 'payload_data')

// Bcrypt password hashing and verification
pw_hash  := app.crypto_bcrypt_hash('my_super_password')!
is_valid := app.crypto_bcrypt_verify('my_super_password', pw_hash)
```

### AES-256-CTR Symmetric Encryption

```v
key := 'my-secret-passphrase' // Hashed via SHA-256 into a 32-byte AES-256 key
plaintext := 'Confidential database connection string'

// Encrypt string to Base64 (prepends 16-byte random IV)
encrypted_b64 := app.crypto_aes_encrypt(key, plaintext)!

// Decrypt Base64 back to plaintext
decrypted := app.crypto_aes_decrypt(key, encrypted_b64)!
assert decrypted == plaintext
```

### Random Generation

```v
uuid_str := app.rand_uuid()          // e.g. "c4a8d09b-2a91-4c39-8b65-68041a87b1c2"
rand_tok := app.rand_string(32)      // 32-character alphanumeric token
rand_num := app.rand_int(1000, 9999) // Random integer in [1000, 9999)
rand_flt := app.rand_f64()           // Random float in [0.0, 1.0)
```

---

## 17. Encodings, Data Formats & Serialization

### Encodings

```v
// Base64 encode / decode
b64_str := app.base64_encode('Hello World')
decoded := app.base64_decode(b64_str)

// Hex encode / decode
hex_str := app.hex_encode('Hello World')
hex_raw := app.hex_decode(hex_str)
```

### JSON, CSV, TOML, Gzip, Regex & SemVer Helpers

```v
// Format flat key-value JSON with 2-space indentation
pretty_json := app.json_pretty('{"name":"Sentinel","env":"prod"}')

// Safe extraction of top-level properties from JSON strings with fallback defaults
raw_json := '{"name":"Sentinel","port":8080,"enabled":true}'
name    := app.json_get_string(raw_json, 'name', 'default_name')
port    := app.json_get_int(raw_json, 'port', 80)
enabled := app.json_get_bool(raw_json, 'enabled', false)

// Parse CSV content into 2D string grid
csv_rows := app.csv_parse('ID,Name,Role\n1,Alice,Admin\n2,Bob,Developer')

// Parse TOML document into toml.Doc
toml_doc := app.toml_parse('title = "Build Config"\nversion = 2')!

// GZIP string compression and decompression
compressed_bytes := app.gzip_compress('Large payload string to compress')!
uncompressed_str := app.gzip_decompress(compressed_bytes)!

// Regex matching
is_match := app.regex_match(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', 'user@domain.com')

// Semantic Version Comparison (-1 if v1 < v2, 0 if equal, 1 if v1 > v2)
cmp := app.semver_compare('1.2.4', '1.3.0')! // returns -1

// Placeholder text generator
sample_text := app.lorem_words(10)
```

---

## 18. Validation Engine

Validate inputs and values with built-in boolean validators:

```v
// Email validation
is_email := app.validate_email('developer@company.org') // true

// URL validation (http:// or https://)
is_url := app.validate_url('https://vlang.io') // true

// IPv4 validation
is_ip := app.validate_ip('192.168.1.1') // true

// Phone number validation (7-15 digits after stripping formatting)
is_phone := app.validate_phone('+1 (555) 234-5678') // true

// Alphanumeric validation
is_alpha := app.validate_alphanumeric('AdminUser123') // true

// Numeric range check [min, max]
in_range := app.validate_numeric_range(85.5, 0.0, 100.0) // true

// String length check [min_len, max_len]
len_valid := app.validate_length('secretpass', 8, 32) // true
```

---

## 19. Generic Collections, Queues & String Metrics

### Generic Stack (`SimpleStack[T]`)

```v
pub struct SimpleStack[T] {
pub mut:
	items []T
}
```

```v
import simplecli

mut stack := simplecli.new_stack[string]()
stack.push('first')
stack.push('second')
stack.push('third')

top   := stack.peek()     // ?string ('third')
val   := stack.pop()      // ?string ('third')
len   := stack.len()      // 2
empty := stack.is_empty() // false
```

### Generic Queue (`SimpleQueue[T]`)

```v
pub struct SimpleQueue[T] {
pub mut:
	items []T
}
```

```v
mut queue := simplecli.new_queue[int]()
queue.push(10)
queue.push(20)
queue.push(30)

next  := queue.peek()     // ?int (10)
out   := queue.pop()      // ?int (10)
len   := queue.len()      // 2
empty := queue.is_empty() // false
```

### Generic Fixed-Capacity Ring Buffer (`SimpleRingBuffer[T]`)

```v
pub struct SimpleRingBuffer[T] {
pub:
	capacity int
pub mut:
	items []T
	head  int
}
```

```v
// Circular buffer holding up to 5 items (overwrites oldest on overflow)
mut ring := simplecli.new_ring_buffer[string](5)
ring.push('log 1')
ring.push('log 2')
ring.push('log 3')

count   := ring.len()      // 3
ordered := ring.to_array() // ['log 1', 'log 2', 'log 3'] (oldest to newest)
oldest  := ring.pop()      // ?string ('log 1')
```

### Min-Heap Priority Queue (`SimpleMinHeap`)

```v
pub struct SimpleMinHeap {
pub mut:
	items []f64
}
```

```v
mut heap := simplecli.new_min_heap()
heap.push(42.0)
heap.push(12.5)
heap.push(99.0)
heap.push(5.0)

min_val := heap.pop() // ?f64 (5.0 - always extracts minimum)
```

### String Similarity & Levenshtein Distance

```v
// Compute minimum edit distance
dist := app.levenshtein_distance('kitten', 'sitting') // 3

// Compute similarity ratio between 0.0 (unrelated) and 1.0 (identical)
ratio := app.similarity_ratio('deploy', 'deploying') // ~0.667
```

---

## 20. Statistical Math Calculations

Calculate descriptive statistics across numeric arrays:

```v
latencies := [12.4, 15.1, 9.8, 14.2, 110.5, 13.0, 16.2]

mean      := app.stats_mean(latencies)           // Arithmetic average
median    := app.stats_median(latencies)         // Median value
std_dev   := app.stats_std_dev(latencies)        // Sample standard deviation
geo_mean  := app.stats_geometric_mean(latencies) // Geometric mean
harm_mean := app.stats_harmonic_mean(latencies)  // Harmonic mean
rms       := app.stats_rms(latencies)            // Root Mean Square
min_val   := app.stats_min(latencies)            // Minimum
max_val   := app.stats_max(latencies)            // Maximum
```

---

## 21. Standalone Package Functions (1-Liners)

`simplecli` exports standalone package-level functions across `simplecli.v`, `stdlib.v`, and `sys.v` for direct one-liner scripting without manually instantiating a `SimpleCli` instance:

```v
import simplecli

fn main() {
	// 1. RAD Console UI & Data Formatting 1-Liners (simplecli.v)
	spark := simplecli.sparkline([10.0, 25.0, 40.0, 80.0, 55.0])
	simplecli.bar_chart('Load Distribution', {'web-1': 65.0, 'web-2': 42.0}, 24)
	simplecli.gauge('Memory Pool', 6.4, 16.0, 'GB')

	mut root := simplecli.new_tree_node('service-mesh')
	root.add_child('ingress-proxy')
	simplecli.tree(root)

	simplecli.diff('version: 1.0', 'version: 1.1')
	tag := simplecli.badge('STAGE', 'CANARY', .info)
	simplecli.alert(.info, 'Canary Active', '${tag} Routing 10% of traffic (${spark})')
	simplecli.task_item('Health check passed', .done, 42)

	headers := ['Host', 'Status']
	rows := [['srv-01', 'ONLINE']]
	csv_str  := simplecli.table_to_csv(headers, rows)
	md_str   := simplecli.table_to_markdown(headers, rows)
	json_str := simplecli.table_to_json(headers, rows)
	_ = simplecli.json_highlight(json_str)
	simplecli.render_markdown('# Summary\n* CSV bytes: ${csv_str.len}\n* MD bytes: ${md_str.len}')

	// 2. HTTP, Crypto, UUID & Base64 1-Liners (stdlib.v)
	get_body  := simplecli.http_get('https://httpbin.org/get')
	post_body := simplecli.http_post('https://httpbin.org/post', '{"ping":true}')
	digest    := simplecli.crypto_sha256(get_body + post_body)
	req_id    := simplecli.rand_uuid()
	encoded   := simplecli.base64_encode('${req_id}:${digest}')
	_         := simplecli.base64_decode(encoded)

	// 3. Process, Path, Hardware & Notification 1-Liners (sys.v)
	out, code := simplecli.exec('uname -s')
	kernel    := simplecli.exec_or('uname -r', 'unknown-kernel')
	_ = out
	_ = code
	_ = kernel

	quoted_arg  := simplecli.quote_arg('hello world')
	quoted_path := simplecli.quote_path('~/Documents')
	safe_name   := simplecli.sanitize_filename('../report.txt')
	_ = quoted_arg
	_ = quoted_path
	_ = safe_name

	home_dir  := simplecli.get_user_home_dir()
	cfg_dir   := simplecli.get_app_config_dir('QuickScript')
	data_dir  := simplecli.get_app_data_dir('QuickScript')
	cache_dir := simplecli.get_app_cache_dir('QuickScript')
	state_dir := simplecli.get_app_state_dir('QuickScript')
	log_dir   := simplecli.get_app_log_dir('QuickScript')
	resolved  := simplecli.resolve_user_path('~/notes.txt')
	_ = [home_dir, cfg_dir, data_dir, cache_dir, state_dir, log_dir, resolved]

	cpu_brand := simplecli.cpu_info()
	ram_total := simplecli.memory_info()
	cores     := simplecli.cpu_cores()

	simplecli.notify('Hardware Probe', '${cpu_brand} (${cores} cores, ${ram_total})')
	simplecli.say('System check complete')
	simplecli.sys_beep()
}
```

---

## 22. Production Console Applications Suite

The repository includes a suite of **49 standalone, production-ready console applications** in [`cli_apps/`](cli_apps/README.md) built on `simplecli`. Every utility supports `--help`/`-h`, `--version`/`-v`, `--debug`, `--no-color`, and `--silent`, and exits with status `2` on invalid CLI flag usage.

See [`cli_apps/README.md`](cli_apps/README.md) for the full catalog and usage notes.

### 1. DevOps, Infrastructure & Automation

| Application | Source File | Supported Flags | Description |
| :--- | :--- | :--- | :--- |
| **DevOps Sentinel** | [`cli_apps/devops_sentinel.v`](cli_apps/devops_sentinel.v) | `--interval`/`-i`, `--alert`/`-a`, `--export`/`-e`, `--log`/`-l`, `--interactive`/`-x` | System health guardian & TCP port monitor |
| **Vault Backup Manager** | [`cli_apps/vault_backup_manager.v`](cli_apps/vault_backup_manager.v) | `--backup`/`-b`, `--restore`/`-r`, `--verify`/`-V`, `--src`/`-s`, `--dest`/`-d`, `--key`/`-k` | AES-256 encrypted directory backup vault |
| **API Stress Bench** | [`cli_apps/api_stress_bench.v`](cli_apps/api_stress_bench.v) | `--url`/`-u`, `--method`/`-m`, `--body`/`-b`, `--requests`/`-n`, `--concurrency`/`-c`, `--export`/`-e` | HTTP API throughput & latency benchmarker |
| **Git Workspace Pilot** | [`cli_apps/multirepo_git_pilot.v`](cli_apps/multirepo_git_pilot.v) | `--path`/`-p`, `--fetch`/`-f`, `--dirty-only`/`-d`, `--interactive`/`-i` | Multi-repository Git orchestrator & stash manager |
| **Docker Studio CLI** | [`cli_apps/docker_cli.v`](cli_apps/docker_cli.v) | `--ps`/`-p`, `--all`/`-a`, `--images`/`-i`, `--logs`/`-l`, `--stop`/`-s`, `--start`/`-u`, `--interactive`/`-x` | Docker container/image manager & log viewer |
| **Homebrew Studio CLI** | [`cli_apps/brew_cli.v`](cli_apps/brew_cli.v) | `--search`/`-s`, `--info`/`-i`, `--outdated`/`-o`, `--services`/`-S`, `--doctor`/`-d`, `--interactive`/`-x` | Package search, info, updates & services |
| **Launchd & Cron CLI** | [`cli_apps/launchd_cli.v`](cli_apps/launchd_cli.v) | `--filter`/`-f`, `--user`/`-u`, `--system`/`-s`, `--cron`/`-c`, `--interactive`/`-x` | macOS daemons, agents & crontab inspector |
| **Task Manager CLI** | [`cli_apps/task_manager_cli.v`](cli_apps/task_manager_cli.v) | `--search`/`-s`, `--top`/`-t`, `--sort`/`-o`, `--kill`/`-k`, `--interactive`/`-x` | Real-time process monitor with CPU/RAM tables |
| **Disk Space CLI** | [`cli_apps/disk_cli.v`](cli_apps/disk_cli.v) | `--path`/`-p`, `--mounts`/`-m`, `--large`/`-l`, `--interactive`/`-x` | Storage capacity, mounts & large file scanner |
| **App Bundler CLI** | [`cli_apps/app_bundler_cli.v`](cli_apps/app_bundler_cli.v) | `--bin`/`-b`, `--name`/`-n`, `--id`/`-i`, `--bundle-version`/`-V`, `--out`/`-o`, `--interactive`/`-x` | macOS native `.app` bundler & packager |

### 2. Security, Network Intelligence & API Tools

| Application | Source File | Supported Flags | Description |
| :--- | :--- | :--- | :--- |
| **API Studio CLI** | [`cli_apps/api_studio_cli.v`](cli_apps/api_studio_cli.v) | `--url`/`-u`, `--method`/`-m`, `--body`/`-b`, `--header`/`-H`, `--interactive`/`-x` | REST API client & HTTP request builder |
| **Nmap Port Scanner CLI** | [`cli_apps/nmap_cli.v`](cli_apps/nmap_cli.v) | `--host`/`-H`, `--ports`/`-p`, `--timeout`/`-t`, `--interactive`/`-x` | Fast TCP port scanner & service prober |
| **DNS & SSL Studio CLI** | [`cli_apps/dns_cli.v`](cli_apps/dns_cli.v) | `--domain`/`-d`, `--type`/`-t`, `--ssl`/`-s`, `--interactive`/`-x` | DNS record resolver (A/MX/TXT) & TLS certs |
| **Recon Studio CLI** | [`cli_apps/recon_cli.v`](cli_apps/recon_cli.v) | `--target`/`-t`, `--whois`/`-w`, `--headers`/`-H`, `--interactive`/`-x` | WHOIS lookup, HTTP headers & host OSINT |
| **Subfinder Studio CLI** | [`cli_apps/subfinder_cli.v`](cli_apps/subfinder_cli.v) | `--domain`/`-d`, `--probe`/`-p`, `--interactive`/`-x` | Certificate Transparency subdomain finder |
| **IFConfig Studio CLI** | [`cli_apps/ifconfig_cli.v`](cli_apps/ifconfig_cli.v) | `--all`/`-a`, `--wifi`/`-w`, `--routes`/`-r`, `--interactive`/`-x` | Network adapters, Wi-Fi SSID & IP diagnostics |
| **Crypto Studio CLI** | [`cli_apps/crypto_cli.v`](cli_apps/crypto_cli.v) | `--algo`/`-a`, `--text`/`-t`, `--file`/`-f`, `--encrypt`/`-e`, `--decrypt`/`-d`, `--key`/`-k`, `--interactive`/`-x` | Hashes (SHA256/512/MD5), AES-256 & BCrypt |

### 3. Data Engineering & Databases

| Application | Source File | Supported Flags | Description |
| :--- | :--- | :--- | :--- |
| **JQ Studio CLI** | [`cli_apps/jq_cli.v`](cli_apps/jq_cli.v) | `--filter`/`-f`, `--file`/`-i`, `--raw`/`-r`, `--compact`/`-c`, `--interactive`/`-x` | JQ JSON query engine & transformation REPL |
| **Data Convert CLI** | [`cli_apps/dataconvert_cli.v`](cli_apps/dataconvert_cli.v) | `--input`/`-i`, `--output`/`-o`, `--from`/`-f`, `--to`/`-t`, `--interactive`/`-x` | Tabular CSV/TSV to JSON/TOML converter |
| **SQLite Studio CLI** | [`cli_apps/sqlite_cli.v`](cli_apps/sqlite_cli.v) | `--db`/`-d`, `--query`/`-q`, `--schema`/`-s`, `--interactive`/`-x` | Database schema explorer & SQL query REPL |

### 4. Text Processing, Stream Editing & Search

| Application | Source File | Supported Flags | Description |
| :--- | :--- | :--- | :--- |
| **GAWK Studio CLI** | [`cli_apps/gawk_cli.v`](cli_apps/gawk_cli.v) | `--script`/`-e`, `--delimiter`/`-F`, `--input`/`-i`, `--interactive`/`-x` | AWK pattern scanner & column aggregator |
| **Sed Studio CLI** | [`cli_apps/sed_cli.v`](cli_apps/sed_cli.v) | `--expr`/`-e`, `--input`/`-i`, `--interactive`/`-x` | Stream editor & find-and-replace engine |
| **SD Studio CLI** | [`cli_apps/sd_cli.v`](cli_apps/sd_cli.v) | `--find`/`-f`, `--replace`/`-r`, `--input`/`-i`, `--text`/`-t`, `--interactive`/`-x` | Fast string & regex token replacement |
| **Cut Studio CLI** | [`cli_apps/cut_cli.v`](cli_apps/cut_cli.v) | `--delimiter`/`-d`, `--fields`/`-f`, `--input`/`-i`, `--interactive`/`-x` | Column delimiter & field extraction utility |
| **TR Studio CLI** | [`cli_apps/tr_cli.v`](cli_apps/tr_cli.v) | `--from`/`-f`, `--to`/`-t`, `--upper`/`-u`, `--lower`/`-l`, `--delete`/`-d`, `--input`/`-i`, `--interactive`/`-x` | Character translation, case shifting & deletion |
| **Regex Studio CLI** | [`cli_apps/regex_cli.v`](cli_apps/regex_cli.v) | `--pattern`/`-p`, `--text`/`-t`, `--interactive`/`-x` | Regular expression validator & matcher |
| **Ripgrep Studio CLI** | [`cli_apps/rg_cli.v`](cli_apps/rg_cli.v) | `--query`/`-q`, `--path`/`-p`, `--type`/`-t`, `--ignore-case`/`-i`, `--interactive`/`-x` | Fast codebase text & pattern search |
| **FD Studio CLI** | [`cli_apps/fd_cli.v`](cli_apps/fd_cli.v) | `--pattern`/`-p`, `--extension`/`-e`, `--path`/`-d`, `--interactive`/`-x` | Directory traversal & regex file finder |
| **Find Studio CLI** | [`cli_apps/find_cli.v`](cli_apps/find_cli.v) | `--path`/`-d`, `--name`/`-n`, `--type`/`-t`, `--interactive`/`-x` | POSIX hierarchy search & filter wrapper |
| **Text Editor CLI** | [`cli_apps/text_editor_cli.v`](cli_apps/text_editor_cli.v) | `--file`/`-f`, `--lines`/`-n`, `--stats`/`-s`, `--interactive`/`-x` | Line-numbered code/text viewer & stats |

### 5. Media, Graphics, Vision & Audio

| Application | Source File | Supported Flags | Description |
| :--- | :--- | :--- | :--- |
| **FFmpeg Media CLI** | [`cli_apps/ffmpeg_cli.v`](cli_apps/ffmpeg_cli.v) | `--input`/`-i`, `--output`/`-o`, `--scale`/`-s`, `--bitrate`/`-b`, `--audio-only`/`-a`, `--probe`/`-p`, `--interactive`/`-x` | Video/Audio transcoder, scaler & metadata probe |
| **ImageMagick CLI** | [`cli_apps/imagemagick_cli.v`](cli_apps/imagemagick_cli.v) | `--input`/`-i`, `--output`/`-o`, `--resize`/`-r`, `--quality`/`-q`, `--grayscale`/`-g`, `--interactive`/`-x` | Image resizing, WebP conversion & thumbnails |
| **yt-dlp Studio CLI** | [`cli_apps/yt_dlp_cli.v`](cli_apps/yt_dlp_cli.v) | `--url`/`-u`, `--format`/`-f`, `--audio-only`/`-a`, `--info`/`-i`, `--output`/`-o`, `--interactive`/`-x` | Web stream, video & audio track downloader |
| **Audio Tag Studio CLI** | [`cli_apps/audiotag_cli.v`](cli_apps/audiotag_cli.v) | `--input`/`-i`, `--title`/`-t`, `--artist`/`-a`, `--album`/`-l`, `--year`/`-y`, `--interactive`/`-x` | ID3 / FLAC metadata tag inspector |
| **ExifTool Studio CLI** | [`cli_apps/exif_cli.v`](cli_apps/exif_cli.v) | `--input`/`-i`, `--strip`/`-s`, `--gps`/`-g`, `--interactive`/`-x` | Image EXIF metadata reader & privacy stripper |
| **Tesseract OCR CLI** | [`cli_apps/ocr_cli.v`](cli_apps/ocr_cli.v) | `--input`/`-i`, `--lang`/`-l`, `--output`/`-o`, `--interactive`/`-x` | Optical Character Recognition on image documents |
| **Say Speech CLI** | [`cli_apps/say_cli.v`](cli_apps/say_cli.v) | `--text`/`-t`, `--voice`/`-V`, `--rate`/`-r`, `--output`/`-o`, `--list-voices`/`-l`, `--interactive`/`-x` | Text-to-Speech synthesizer & voiceover exporter |
| **Media Studio Hub CLI** | [`cli_apps/media_studio_cli.v`](cli_apps/media_studio_cli.v) | `--input`/`-i`, `--action`/`-a`, `--interactive`/`-x` | Unified audio/video/image master console |
| **Graphviz DOT CLI** | [`cli_apps/dot_cli.v`](cli_apps/dot_cli.v) | `--input`/`-i`, `--output`/`-o`, `--format`/`-f`, `--interactive`/`-x` | DOT graph diagram renderer (PNG, SVG, PDF) |

### 6. Math, Calculators & Scientific Tools

| Application | Source File | Supported Flags | Description |
| :--- | :--- | :--- | :--- |
| **Numbat Units CLI** | [`cli_apps/numbat_cli.v`](cli_apps/numbat_cli.v) | `--expr`/`-e`, `--interactive`/`-x` | Physical units & dimensional analysis solver |
| **Kalker Math CLI** | [`cli_apps/kalker_cli.v`](cli_apps/kalker_cli.v) | `--expr`/`-e`, `--interactive`/`-x` | High-precision scientific math expression evaluator |
| **Qalc Studio CLI** | [`cli_apps/qalc_cli.v`](cli_apps/qalc_cli.v) | `--expr`/`-e`, `--interactive`/`-x` | Qalculate! power calculator & unit converter |
| **Programmer Calc CLI** | [`cli_apps/calc_cli.v`](cli_apps/calc_cli.v) | `--val`/`-n`, `--op`/`-o`, `--val2`/`-w`, `--interactive`/`-x` | HEX/DEC/OCT/BIN bitwise operations & endian |
| **Statistics Studio CLI** | [`cli_apps/statistics_cli.v`](cli_apps/statistics_cli.v) | `--data`/`-d`, `--file`/`-f`, `--interactive`/`-x` | Central tendency, dispersion, RMS, std dev |
| **Graph Studio CLI** | [`cli_apps/graph_cli.v`](cli_apps/graph_cli.v) | `--data`/`-d`, `--labels`/`-l`, `--title`/`-t`, `--interactive`/`-x` | Terminal ASCII bar & distribution visualizer |

### 7. Document, Archive & Transfer Utilities

| Application | Source File | Supported Flags | Description |
| :--- | :--- | :--- | :--- |
| **Pandoc Studio CLI** | [`cli_apps/pandoc_cli.v`](cli_apps/pandoc_cli.v) | `--input`/`-i`, `--output`/`-o`, `--from`/`-f`, `--to`/`-t`, `--interactive`/`-x` | Markdown, HTML, PDF, Docx document converter |
| **Ouch Archive CLI** | [`cli_apps/ouch_cli.v`](cli_apps/ouch_cli.v) | `--compress`/`-c`, `--decompress`/`-d`, `--input`/`-i`, `--interactive`/`-x` | ZIP, TAR, GZ, 7Z, ZSTD compressor/extractor |
| **Rip Safe Deletion CLI** | [`cli_apps/rip_cli.v`](cli_apps/rip_cli.v) | `--bury`/`-b`, `--unbury`/`-u`, `--seance`/`-s`, `--decompose`/`-d`, `--graveyard`/`-g`, `--inspect`/`-i`, `--force`/`-f`, `--interactive`/`-x` | Safe `rm` alternative with graveyard & seance |
| **Wget2 Downloader CLI** | [`cli_apps/wget2_cli.v`](cli_apps/wget2_cli.v) | `--url`/`-u`, `--output`/`-o`, `--continue`/`-c`, `--interactive`/`-x` | Fast HTTP/HTTPS file download manager |
