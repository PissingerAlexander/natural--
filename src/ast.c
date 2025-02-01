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
	printf(" ( %s ", getAstNodeTypeName(tree->type));
	for (int i = 0; i < MAX_CHILDREN; i++) {
		print_ast(tree->children[i]);
	}
	printf(" ) ");
}

char *getAstNodeTypeName(int typeId) {
	switch (typeId) {
		case CHAIN_RECURSION: return "Recursion";
		case FUNCTION: return "Function declaration";
		case PARAMETER: return "Parameter";
		case CALL: return "Function call";
		case ARGUMENT: return "Argument";
		case RETURN: return "Return";
		case STATEMENT: return "Statement";
		case TERM: return "Term";
		case RETRIVE_VAR: return "Identifier";
		case ADD: return "Addidtion";
		case SUB: return "Subtraction";
		case MUL: return "Multiplication";
		case DIV: return "Division";
		case assign: return "Assignment";
		case print: return "Print";
		case i64: return "Integer value";
		case f64: return "Float value";
		case string: return "String value";
		default: return "Unknown AST type id";
	}
}
