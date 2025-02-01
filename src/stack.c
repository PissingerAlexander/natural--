#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "headers/stack.h"
#include "headers/queue.h"

var_t *new_variable(char *var_name, value_t *value) {
	var_t *var = (var_t *)malloc(sizeof(var_t));
	var->var_name = var_name;
	var->value = value;
	return var;
}

node_t *new_node(var_t *var) {
	node_t *node = (node_t *)malloc(sizeof(node_t));
	node->var = var;
	node->prev = NULL;
	return node;
}

stack_t *new_stack() {
	stack_t *stack = (stack_t *)malloc(sizeof(stack_t));
	stack->top = NULL;
	return stack;
}

void s_push(stack_t *s, char *var_name, value_t *value) {
	var_t *var = new_variable(var_name, value);
	node_t *node = new_node(var);
	node->prev = s->top;
	s->top = node;
}

var_t *s_top(stack_t *s) {
	if (s->top == NULL) return NULL;
	return s->top->var;
}

var_t *s_pop(stack_t *s) {
	if (s->top == NULL) return NULL;
	node_t *node = s->top;
	s->top = s->top->prev;
	var_t *var = node->var;
	free(node);
	return var;
}

void s_remove_one_node(stack_t *s) {
	if (s->top == NULL) return;
	node_t *node = s->top;
	s->top = s->top->prev;
	free_node_ptr(node);
}

var_t *s_lookup(stack_t *s, char *var_name) {
	if (s->top == NULL) return NULL;
	node_t *node = s->top;
	while (node != NULL) {
		if (!strcmp(node->var->var_name, var_name)) {
			return node->var;
		}
		node = node->prev;
	}
	return NULL;
}

int s_is_empty(stack_t *s) {
	return s->top == NULL;
}

void s_print(stack_t *s) {
	if (s_is_empty(s)) return;
	node_t *node = s->top;
	while (node != NULL) {
		switch(node->var->value->type) {
			case T_INT: printf("%s with value %ld\n", node->var->var_name, node->var->value->v.int_num); break;
			case T_FL: printf("%s with value %f\n", node->var->var_name, node->var->value->v.fl_num);
			case T_STR: printf("%s with value %s\n", node->var->var_name, node->var->value->v.str);
		}
		node = node->prev;
	}
}

void free_var_ptr(var_t *var) {
	free_value_ptr(var->value);
	free(var);
}

void free_node_ptr(node_t *node) {
	free_var_ptr(node->var);
	free(node);
}

void s_clear_fn_stack(stack_t *s) {
	if (s_is_empty(s)) return;
	var_t *var = s_pop(s);
	while (var->value->type != M_FN) {
		var = s_pop(s);
	}
	return;
}

// #########################################################

fn_t *new_function(char *fn_name, ast_t *fun_root, param_queue_t *param_list, int return_type) {
	fn_t *fun = (fn_t *)malloc(sizeof(fn_t));
	fun->fn_name = fn_name;
	fun->fn_root = fun_root;
	fun->param_list = param_list;
	fun->return_type = return_type;
	return fun;
}

fn_node_t *new_fn_node(fn_t *fun_root) {
	fn_node_t *node = (fn_node_t *)malloc(sizeof(fn_node_t));
	node->fun = fun_root;
	node->prev = NULL;
	return node;
}

fn_stack_t *new_fn_stack() {
	fn_stack_t *stack = (fn_stack_t *)malloc(sizeof(fn_stack_t));
	stack->top = NULL;
	return stack;
}

void s_push_fn(fn_stack_t *s, char *fn_name, ast_t *fn_root, param_queue_t *param_list, int return_type) {
	fn_t *fun = new_function(fn_name, fn_root, param_list, return_type);
	fn_node_t *node = new_fn_node(fun);
	node->prev = s->top;
	s->top = node;
}

fn_t *s_lookup_fn(fn_stack_t *s, char *fn_name) {
	if (s->top == NULL) return NULL;
	fn_node_t *node = s->top;
	while (node != NULL) {
		if (!strcmp(node->fun->fn_name, fn_name)) {
			return node->fun;
		}
		node = node->prev;
	}
	return NULL;
}
