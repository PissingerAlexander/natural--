#ifndef _QH
#define _QH

#include "value.h"
#include "stack.h"

typedef struct value_struct value_t;
typedef struct stack_struct stack_t;

typedef struct param_queue_node_struct {
	int param_type;
	char *param_name;
	struct param_queue_node_struct *next;
} param_node_t;

typedef struct param_queue_struct {
	param_node_t *head;
	param_node_t *tail;
	int size;
} param_queue_t;

param_node_t *new_param_node(int param_type, char *param_name);
param_queue_t *new_param_queue();
void q_enqueue_param(param_queue_t *q, int param_type, char *param_name);

// ##########################################################

typedef struct arg_queue_node_struct {
	value_t *value;
	struct arg_queue_node_struct *next;
} arg_node_t;

typedef struct arg_queue_struct {
	arg_node_t *head;
	arg_node_t *tail;
	int size;
} arg_queue_t;

arg_node_t *new_arg_node(value_t *value);
arg_queue_t *new_arg_queue();
void q_enqueue_arg(arg_queue_t *q, value_t *value);

void push_args_on_stack(stack_t *stack, param_queue_t *param_list, arg_queue_t *arg_list);
void free_arg_list(arg_queue_t *arg_list);

#endif
