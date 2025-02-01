#ifndef _SH
#define _SH

#include "value.h"
#include "ast.h"
#include "queue.h"

typedef struct value_struct value_t;
typedef struct param_queue_struct param_queue_t;
typedef struct ast_struct ast_t;

typedef struct var_struct {
	char *var_name;
	value_t *value;
} var_t;

typedef struct node_struct {
	struct var_struct *var;
	struct node_struct *prev;
} node_t;

typedef struct stack_struct {
	struct node_struct *top;
} stack_t;

var_t *new_variable(char *var_name, value_t *value);
node_t *new_node(var_t *var);

stack_t *new_stack();
void s_push(stack_t *s, char *var_name, value_t *value);
var_t *s_top(stack_t *s);
var_t *s_pop(stack_t *s);
void s_remove_one_node(stack_t *s);
var_t *s_lookup(stack_t *s, char *var_name);
int s_is_empty(stack_t *s);

void free_var_ptr(var_t *var);
void free_node_ptr(node_t *node);

void s_print(stack_t *s);

void s_clear_fn_stack(stack_t *s);

// #######################################################

typedef struct fn_struct {
	char *fn_name;
	ast_t *fn_root;
	param_queue_t *param_list;
	int return_type;
} fn_t;

typedef struct fn_node_struct {
	struct fn_struct *fun;
	struct fn_node_struct *prev;
} fn_node_t;

typedef struct fn_stack_struct {
	struct fn_node_struct *top;
} fn_stack_t;

fn_t *new_function(char *fn_name, ast_t *fun_root, param_queue_t *param_list, int return_type);
fn_node_t *new_fn_node(fn_t *fun_root);

fn_stack_t *new_fn_stack();
void s_push_fn(fn_stack_t *s, char *fn_name, ast_t *fn_root, param_queue_t *param_list, int return_type);
ast_t *s_top_fn(fn_stack_t *s);
ast_t *s_pop_fn(fn_stack_t *s);
void s_remove_fn(fn_stack_t *s);
fn_t *s_lookup_fn(fn_stack_t *s, char *fn_name);
int s_is_empty_fn(fn_stack_t *s);

#endif
