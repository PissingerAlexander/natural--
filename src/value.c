#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "headers/value.h"

value_t *new_value_ptr() {
	value_t *value = (value_t *)malloc(sizeof(value_t));
	value->v.str = (char *)calloc(1, MAX_STR_LEN);
	value->type = -1;
	value->index = 0;
	value->is_array = 0;
	return value;
}

value_t *copy_value(value_t *value) {
	value_t *ret = new_value_ptr();
	ret->type = value->type;
	ret->index = value->index;
	ret->is_array = value->is_array;
	switch(value->type) {
		case T_INT: ret->v.int_num = value->v.int_num; break;
		case T_FL: ret->v.fl_num = value->v.fl_num; break;
		case T_STR: strcpy(ret->v.str, value->v.str); break;
		default: printf("Warning: Unknown type while copying value");
	}
	return ret;
}

void free_value_ptr(value_t *value) {
	if (value->v.str) free(value->v.str);
	free(value);
}

