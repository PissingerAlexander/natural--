#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "headers/queue.h"

param_node_t *new_param_node(int param_type, char *param_name) {
	param_node_t *node = (param_node_t *)malloc(sizeof(param_node_t *));
	node->param_type = param_type;
	node->param_name = param_name;
	return node;
}

param_queue_t *new_param_queue() {
	param_queue_t *queue = (param_queue_t *)malloc(sizeof(param_queue_t));
	queue->head = NULL;
	queue->tail = NULL;
	queue->size = 0;
	return queue;
}

void q_enqueue_param(param_queue_t *q, int param_type, char *param_name) {
	param_node_t *node = new_param_node(param_type, param_name);
	if (q->head == NULL) {
		q->head = node;
		q->tail = node;
	} else {
		q->tail->next = node;
		q->tail = node;
	}
	q->size++;
}

arg_node_t *new_arg_node(value_t *value) {
	arg_node_t *node = (arg_node_t *)malloc(sizeof(arg_node_t));
	node->value = value;
	node->next = NULL;
	return node;
}

arg_queue_t *new_arg_queue() {
	arg_queue_t *queue = (arg_queue_t *)malloc(sizeof(arg_queue_t));
	queue->head = NULL;
	queue->tail = NULL;
	return queue;
}

void q_enqueue_arg(arg_queue_t *q, value_t *value) {
	arg_node_t *node = new_arg_node(value);
	if (q->head == NULL) {
		q->head = node;
		q->tail = node;
	} else {
		q->tail->next = node;
		q->tail = node;
	}
	q->size++;
}

void push_args_on_stack(stack_t *stack, param_queue_t *param_list, arg_queue_t *arg_list) {
	if (param_list->size != arg_list->size) {
		printf("Error: invalid amount of arguments\n");
		exit(0);
	}
	param_node_t *param_node = param_list->head;
	arg_node_t *arg_node = arg_list->head;

	while (param_node != NULL && arg_node != NULL) {
		switch (param_node->param_type) {
			case T_ARR: {
				if (!arg_node->value->is_array) {
					printf("Error: types do not match\n");
					exit(0);
				}

				value_t *value = (value_t *)malloc(sizeof(value_t) * (arg_node->value[0].v.int_num + 1));
				memcpy(value, arg_node->value, sizeof(value_t) * (arg_node->value[0].v.int_num + 1));

				s_push(stack, param_node->param_name, value);

				param_node = param_node->next;
				arg_node = arg_node->next;
				break;
			}
			default: {
				if (param_node->param_type != arg_node->value->type) {
					printf("Error: types do not match\n");
					exit(0);
				}
				value_t *value = copy_value(arg_node->value);
				s_push(stack, param_node->param_name, value);
				param_node = param_node->next;
				arg_node = arg_node->next;
				break;
			}
		}
	}
}

void free_arg_list(arg_queue_t *arg_list) {
	arg_node_t *head = arg_list->head;
	arg_node_t *tmp;
	while (head != NULL) {
		tmp = head;
		head = head->next;
		free(tmp);
	}
}

