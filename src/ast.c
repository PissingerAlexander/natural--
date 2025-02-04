#include <stdio.h>
#include <stdlib.h>

#include "headers/ast.h"

#include "../bison.def.tab.h"

ast_t *node0(int type) {
	ast_t *ret = (ast_t *)calloc(MAX_CHILDREN, sizeof(ast_t));
	ret->type = type;
	return ret;
}

ast_t *node1(int type, ast_t *child) {
	ast_t *ret = node0(type);
	ret->children[0] = child;
	return ret;
}

ast_t *node2(int type, ast_t *child_one, ast_t *child_two) {
	ast_t *ret = node1(type, child_one);
	ret->children[1] = child_two;
	return ret;
}

ast_t *node3(int type, ast_t *child_one, ast_t *child_two, ast_t *child_three) {
	ast_t *ret = node2(type, child_one, child_two);
	ret->children[2] = child_three;
	return ret;
}

ast_t *node4(int type, ast_t *child_one, ast_t *child_two, ast_t *child_three, ast_t *child_four) {
	ast_t *ret = node3(type, child_one, child_two, child_three);
	ret->children[3] = child_four;
	return ret;
}

ast_t *node5(int type, ast_t *child_one, ast_t *child_two, ast_t *child_three, ast_t *child_four, ast_t *child_five) {
	ast_t *ret = node4(type, child_one, child_two, child_three, child_four);
	ret->children[4] = child_five;
	return ret;
}

void print_ast(ast_t *tree) {
	if (!tree) return;
	printf(" ( %s", get_ast_node_type_name(tree->type));
	switch (tree->type) {
		case FUNCTION:
		case CALL:
		case DECLARE_VAR:
		case INIT_VAR:
		case ASSIGN_VAR:
		case RETRIVE_VAR:
		case GET:
		case PUSH: printf(": %s ", tree->var_name); break;
		case i64: printf(": %ld ", tree->value->v.int_num); break;
		case string: printf(": \"%s\" ", tree->value->v.str); break;
		default: printf(" ");
	}
	for (int i = 0; i < MAX_CHILDREN; i++) {
		print_ast(tree->children[i]);
	}
	printf(" ) ");
}

char *get_ast_node_type_name(int typeId) {
	switch (typeId) {
		case CHAIN_RECURSION: return "Recursion";
		case FUNCTION: return "Declare function";
		case PARAMETER: return "Parameter";
		case CALL: return "Call function";
		case ARGUMENT: return "Argument";
		case RETURN: return "Return";
		case IF: return "If";
		case ELSE: return "Else";
		case ELSE_IF: return "Else if";
		case LOOP: return "Loop";
		case LOOP_AMOUNT: return "Loop amount";
		case LOOP_STEP: return "Loop step size";
		case LOOP_CONDITION: return "Loop condition";
		case LOOP_ELSE: return "Loop else";
		case TERM: return "Term";
		case DECLARE_VAR: return "Declare varibale";
		case INIT_VAR: return "Declare and initialize variable";
		case ASSIGN_VAR: return "Assing variable";
		case RETRIVE_VAR: return "Identifier";
		case PUSH: return "Push";
		case GET: return "Get";
		case ADD: return "Addidtion";
		case SUB: return "Subtraction";
		case MUL: return "Multiplication";
		case DIV: return "Division";
		case i64: return "Integer value";
		case string: return "String value";
		case create_array: return "Create array";
		case greater_than: return "Greater than";
		case less_than: return "Less than";
		case equal: return "equal to";
		case or: return "or";
		case and: return "and";
		case print: return "Print";
		case random_num: return "Random number";
		case read_num: return "Read number";
		case read_line: return "Read line";
		default: return "Unknown AST type id";
	}
}
