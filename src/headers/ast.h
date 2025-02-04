#ifndef _AH
#define _AH

#include "value.h"
#include "queue.h"

#define MAX_CHILDREN 4

typedef struct value_struct value_t;
typedef struct param_queue_struct param_queue_t;
typedef struct arg_queue_struct arg_queue_t;

enum {
	CHAIN_RECURSION = 10000,
	FUNCTION,
	PARAMETER,
	CALL,
	ARGUMENT,
	RETURN,
	IF,
	ELSE,
	ELSE_IF,
	LOOP,
	LOOP_AMOUNT,
	LOOP_STEP,
	LOOP_CONDITION,
	LOOP_ELSE,
	TERM,
	DECLARE_VAR,
	INIT_VAR,
	ASSIGN_VAR,
	RETRIVE_VAR,
	PUSH,
	GET,
	ADD,
	SUB,
	MUL,
	DIV
};

typedef struct ast_struct {
	int type;
	value_t *value;
	char *var_name;
	param_queue_t *param_list;
	arg_queue_t *arg_list;
	struct ast_struct *children[MAX_CHILDREN];
} ast_t;

ast_t *node0(int type);
ast_t *node1(int type, ast_t *child);
ast_t *node2(int type, ast_t *child_one, ast_t *child_two);
ast_t *node3(int type, ast_t *child_one, ast_t *child_two, ast_t *child_three);
ast_t *node4(int type, ast_t *child_one, ast_t *child_two, ast_t *child_three, ast_t *child_four);
ast_t *node5(int type, ast_t *child_one, ast_t *child_two, ast_t *child_three, ast_t *child_four, ast_t *child_five);

void print_ast(ast_t *tree);

char *get_ast_node_type_name(int typeId);

#endif
