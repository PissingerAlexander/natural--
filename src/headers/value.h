#ifndef _VH
#define _VH

#include "ast.h"

#define VAR_TYPE_COUNT 4
#define MAX_STR_LEN 256

typedef struct ast_struct ast_t;

enum value_types {
	T_INT,
	T_FL,
	T_STR,
	T_ARR,
	M_FN,
};

typedef struct value_struct {
	int type;
	int index;
	int is_array;
	union {
		long int_num;
		double fl_num;
		char *str;
		ast_t *fn;
	} v;
} value_t;

value_t *new_value_ptr();
value_t *copy_value(value_t *value);
void free_value_ptr(value_t *value);

#endif
