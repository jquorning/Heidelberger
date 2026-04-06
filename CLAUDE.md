# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Heidelberger is a translation of WordPress (PHP) into Ada 2022. It reimplements the WordPress codebase as an Ada HTTP server that produces equivalent HTML output to the original PHP.

## Build & Run

```bash
alr build                        # Build (output: bin/heidelberger)
./bin/heidelberger               # Start server on localhost:8080
```

Press `Q` in the terminal to stop the server. Build profiles: `development` (default), `validation`, `release`.

## Source Layout

```
source/
├── php/           # PHP standard library in Ada (Php.Strings, Php.Preg, Php.Arrays, …)
├── class/         # WordPress OOP classes (Class_Styles, Class_Scripts, Class_WpDB, …)
├── include/       # WordPress includes (Inc_Functions, Inc_Formatting, Inc_Options, …)
├── admin/         # /wp-admin/ pages (Adm_Install, Adm_Plugins, …)
│   └── include/   # /wp-admin/include/ (Adi_Misc, Adi_Templates, …)
└── bind/          # Database adapters (ADO/MySQL/SQLite)
```

Top-level files: `heidelberger.adb` (main), `hb_server.adb` (AWS HTTP server), `binder.adb` (HTTP↔PHP bridge), `globals.ads` (all WP global state), `arrays.adb` (core data structure).

## Naming Conventions

WordPress symbols are renamed to be valid Ada identifiers:

| WordPress         | Ada prefix |
|-------------------|------------|
| `wp_*` functions  | `Inc_*` or `Wp_*` |
| `/wp-admin/`      | `Adm_` |
| `/wp-admin/include/` | `Adi_` |
| `/wp-includes/`   | `Inc_` |
| `class-*.php`     | `Class_` |
| Leading `_`       | `X_` (e.g. `_construct` → `X_Construct`) |
| Trailing `__`     | `_XX` |

## Core Data Structures

**`Array_Type`** (in `arrays.ads`) — the central dynamic-typing container. Implements PHP's associative arrays using an ordered map of `String → Multi_Type`. `Multi_Type` is a variant record with discriminant `Kind_Type`:
- `Kind_String`, `Kind_Integer`, `Kind_Boolean`, `Kind_Null`
- `Kind_Array` (nested `Array_Type`), `Kind_List` (`Lists.List_Type`), `Kind_Callable`

**`UString`** — `Ada.Strings.Unbounded.Unbounded_String`. Prefix `+` converts `String → UString`, prefix `-` converts back.

**`List_Type`** — `Ada.Containers.Indefinite_Vectors` of `String`. Used where PHP uses indexed arrays of strings (e.g. queue, done lists in dependency system).

## PHP-to-Ada Patterns

- PHP superglobals (`$_GET`, `$_POST`, `$_SERVER`, etc.) live in `Binder` as `Array_Type`.
- WordPress hooks (`add_filter`, `do_action`, etc.) are in `Wp_Common` — `Apply_Filters` and `Do_Action`.
- Output buffering mirrors PHP: `Echo`, `Printf` in `Php.Echoing`; `OB_Start`/`OB_Get_Clean` for buffered output.
- `Preg_Replace`/`Preg_Match`/`Preg_Split` use `GNAT.Regpat`. Patterns include PHP delimiters (`#…#`, `|…|`).
- PHP `empty()` → `Php.Strings.Empty(String)` (true iff zero length).
- `Strpos` / `Stripos` return 1-based position (via `Ada.Strings.Fixed.Index`), return 0 when not found.

## Dispatch Gotchas

Ada dispatching is static by default. To dispatch to an overriding method (e.g., call `Wp_Styles.Do_Item` from code operating on `Wp_Dependencies`):
```ada
-- Wrong (static dispatch — calls base class):
This.Do_Item (Handle, Group);
-- Correct (dynamic dispatch):
Wp_Dependencies'Class (This).Do_Item (Handle, Group);
```

For a non-dispatching parent call from an overriding method:
```ada
-- Calls parent directly, no dispatch:
Do_Item (Wp_Dependencies (This), Handle);
```

## Known Stubs / Incomplete Areas

Many functions return placeholder values (e.g. `"XXX-000"`). The database layer reads options from MySQL via `Bind_ADO`. During development, `inc_options.adb` has a hardcoded hack that appends `:8080` to the siteurl option so URLs resolve to the local server.

`Wp_Parse_Str` is a stub (does nothing); query string parsing in `Add_Query_Arg` relies on the URL being well-formed rather than parsing existing query params.
