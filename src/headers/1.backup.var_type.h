#ifndef _VTH
#define _VTH

#define VAR_TYPE_COUNT 7

#ifndef _VTN
#define _VTN
static char *var_type_names[] = {
	"i32", "i64",
	"f32", "f64",
	"char", "string",
	"array"
};
#endif

typedef enum var_type_enum {
	I32, I64,
	F32, F64,
	CHAR, STRING,
	ARRAY
} var_type;

#endif
