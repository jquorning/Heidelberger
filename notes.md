## Notes

### Compatability

- URL: Keep `.php` extensions.
- JavaScript scripts.
- Locales: Keep texts in printout.
- CSS.
- GFX looks.

### Symbol Differences
Differeces from WordPress originals.

- Symbols starting with `_` replaced with `X_`.
- `XX_Get` was `_Get`.
- Ending in `__` is `_XX`.

### File organization

- `base/` -
- `base/admin/` - Prefix `Adm_`
- `base/admin/include/` - Prefix `Adi_`
- `base/admin/class/` - Prefix `Class_`
- `base/include/` - Prefix `Inc_`
- `base/class/` - Prefix `Class_`

### Translation

Variables do not have null values.

- Use "" for strings

Function return values can not be ignored.

- Procedure version of function call.
- Exceptions.

#### Bad toes
- `Do_Action` -
- `Apply_Filters` -
- Cache stuff
- Options

### To Do

- Fix XXX-000 and 100 others
- Remove deprecated stuff from old times.
- Remove `is_array`, `is_string` etc. They are known at compile time.
- Remove `instanceof`. They are known at compile time.
- Initialize global variables. Remove check of type and run-time initialization.
- Add subtypes of `String` and `Array_Type` with predicates.
- Move protected function declarations to private parts.
- Find out what to do with protected and private member variables.

### Not working

- `Natural'Image` adds leading space. Use `Helper.Image`.
- `Apply_Filters`
- Callbacks
- Modifying `As_Array` referenced

### Optimizations

There are som low-hanging fruits:
- Build with release profile. (done)
- Add flag for stubbing of Logging. (done)
- Preallocate echoing buffer. (done)
- Return `UString` from echoing buffer (`Get_Echo`).
- Look at `Array_Type` and copying
- Use variant record in `Array_Type`.
- Switch off container checks. (done)
