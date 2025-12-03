## Notes

### Compatability

Keep compatability if JavaScript and Locales, usage, GFX.

### Differences
Differeces from WordPress originals.

Symbols starting with `_` replaced with `X_`.

### File organization

- `base/` -
- `base/admin/` - Prefix `Adm_`
- `base/admin/include/` - Prefix `Adi_`
- `base/include/` - Prefic `Inc_`

### Translation

Variables do not have null values.

- Use "" for strings

Function return values can not be ignored.

- Procedure version of function call.
- Exceptions.

### To Do

- Fix XXX-000 and 100 others
- Remove deprecated stuff from old times.
- Remove `is_array`, `is_string` etc. They are known at compile time.
- Remove `instanceof`. They are known at compile time.
- Initialize global variables. Remove check of type and run-time initialization.
- Add subtypes of String and Array_Type with predicates.
- Move protected function declarations to private parts.
- Find out what to do with protected and private member variables.

### Not working

`Natural'Image` adds leading space. Use `Helper.Image`.

`Apply_Filters`

Callbacks

Modifying `As_Array` referenced
