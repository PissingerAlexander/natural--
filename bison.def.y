%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "src/headers/stack.h"
#include "src/headers/value.h"
#include "src/headers/ast.h"

	extern FILE *yyin;

	int yydebug = 0;
	extern int yylineno;
	int yylex (void);
	void yyerror (const char *msg) {
		printf("Line %d: %s\n", yylineno, msg);
	}

	value_t *new_value_ptr();
	value_t *execute_tree(ast_t *tree);

	stack_t *stack;
	fn_stack_t *global_fn;

	int EXEC = 1;
	int EXIT_LOOP = 0;

	value_t *get_loop_condition(ast_t *child);
%}

%define parse.error verbose

%union {
	value_t *value;
	int operation;
	char *var_name;
	ast_t *ast;
	int arr_fun;
}

%token 	<value>			i64 
	<value>			f64 
	<value>			string escaped_string_part
	<value>			type
	<operation>		operation
	<var_name>		var_name

%token	end_statement lpar rpar lcur rcur comma type_separator
	function returns nothing call _return
	create_array push get set array_type
	print apply to assign random_num read_num read_line
	_if then _else greater_than less_than equal
	repeat infinite times stepsize condition exit_loop 
	and or

%type 	<ast>		FUNCTIONS	FUNCTION
			PARAMETERS	PARAMETER
			ARGUMENTS	ARGUMENT
			STATEMENTS	STATEMENT
			ELSE		TERM
			AMOUNT		STEPSIZE
			CONDITION	OR

%type	<value>		RET_VAL

%start program

%left _return
%right _if _else
%right assign
%left or
%left and
%left equal
%left less_than greater_than

%%

program: FUNCTIONS { 
	// printf("  ###################################  \n");
	// print_ast($1);
	// printf("\n  ###################################  \n\n\n");
	fn_t * fun = s_lookup_fn(global_fn, "main");
	execute_tree(fun->fn_root);
}

FUNCTIONS: FUNCTIONS FUNCTION { $$ = node2(CHAIN_RECURSION, $1, $2); }
	 | %empty { $$ = NULL; }

FUNCTION: function var_name returns RET_VAL lpar PARAMETERS rpar lcur STATEMENTS rcur {
		  $$ = node2(FUNCTION, $6, $9);
		  $$->var_name = $2;
		  $$->value = $4;
		  execute_tree($$);
	}

RET_VAL: type { $$ = $1; }
       | nothing { $$ = NULL; }

PARAMETERS: PARAMETERS comma PARAMETER { $$ = node2(CHAIN_RECURSION, $1, $3); }
	  | PARAMETER { $$ = node1(PARAMETER, $1); }
	  | %empty { $$ = NULL; }

PARAMETER: var_name type_separator type {
		$$ = node0(PARAMETER);
		$$->var_name = $1;
		$$->value = $3;
	 }
	 | var_name type_separator array_type {
		$$ = node0(PARAMETER);
		$$->var_name = $1;
		$$->value = new_value_ptr();
		$$->value->type = T_ARR;
	 }

STATEMENTS: STATEMENTS STATEMENT { $$ = node2(CHAIN_RECURSION, $1, $2); }
	  | %empty { $$ = NULL; }

STATEMENT: TERM end_statement { $$ = node1(TERM, $1); }
	 | var_name type_separator type assign TERM end_statement { 
		 $$ = node1(INIT_VAR, $5);
		 $$->var_name = $1;
		 $$->value = $3;
	 }
	 | var_name type_separator type end_statement {
		 $$ = node0(DECLARE_VAR);
		 $$->var_name = $1;
		 $$->value = $3;
	 }
	 | var_name assign create_array i64 type_separator type end_statement { 
		 $$ = node0(create_array); 
		 $$->var_name = $1;
		 $$->value = $6;
		 $$->value->v.int_num = $4->v.int_num;
	 }
	 | var_name push lpar TERM rpar end_statement { 
		 $$ = node1(PUSH, $4);
		 $$->var_name = $1;
	 }
	 | var_name assign random_num TERM end_statement { 
		 $$ = node1(random_num, $4);
		 $$->var_name = $1;
	 }
	 | var_name assign read_num end_statement {
		 $$ = node0(read_num);
		 $$->var_name = $1;
	 }
	 | var_name assign read_line end_statement { 
		 $$ = node0(read_line);
		 $$->var_name = $1;
	 }
	 | print lpar TERM rpar end_statement { $$ = node1(print, $3); }
	 | _if lpar TERM rpar then lcur STATEMENTS rcur { $$ = node2(IF, $3, $7); }
	 | _if lpar TERM rpar then lcur STATEMENTS rcur ELSE { $$ = node3(IF, $3, $7, $9); }
	 | repeat AMOUNT times STEPSIZE CONDITION lcur STATEMENTS rcur OR { $$ = node5(LOOP, $2, $4, $5, $7, $9); }
	 | exit_loop end_statement { $$ = node0(exit_loop); }

AMOUNT: TERM { $$ = node1(LOOP_AMOUNT, $1); }
      | infinite { $$ = node0(LOOP_AMOUNT); }

STEPSIZE: stepsize TERM { $$ = node1(LOOP_STEP, $2); }
	| %empty { $$ = NULL; }

CONDITION: condition TERM { $$ = node1(LOOP_CONDITION, $2); }
	 | %empty { $$ = NULL; }

OR: or lcur STATEMENTS rcur { $$ = node1(LOOP_ELSE, $3); }
  | %empty { $$ = NULL; }



ELSE: _else lcur STATEMENTS rcur { $$ = node1(ELSE, $3); }
    | _else _if lpar TERM rpar then lcur STATEMENTS rcur { $$ = node2(ELSE_IF, $4, $8); }
    | _else _if lpar TERM rpar then lcur STATEMENTS rcur ELSE { $$ = node3(ELSE_IF, $4, $8, $10); }

TERM: var_name assign TERM {
		$$ = node1(ASSIGN_VAR, $3);
		$$->var_name = $1;
    }
    | i64 { 
		$$ = node0(i64);
		$$->value = $1;
    }
    | f64 { 
		$$ = node0(f64);
		$$->value = $1;
    }
    | string {
		$$ = node0(string);
		$$->value = $1;
    }
    | TERM greater_than TERM { $$ = node2(greater_than, $1, $3); }
    | TERM less_than TERM { $$ = node2(less_than, $1, $3); }
    | TERM equal TERM { $$ = node2(equal, $1, $3); }
    | TERM or TERM { $$ = node2(or, $1, $3); }
    | TERM and TERM { $$ = node2(and, $1, $3); }
    | lpar TERM rpar { $$ = $2; }
    | apply operation to lpar TERM and TERM rpar { $$ = node2($2, $5, $7); }
    | var_name {
		$$ = node0(RETRIVE_VAR);
		$$->var_name = $1;
    }
    | var_name get lpar TERM rpar {
		$$ = node1(GET, $4);
		$$->var_name = $1;
    }
    | call var_name lpar ARGUMENTS rpar {
		$$ = node1(CALL, $4);
		$$->var_name = $2;
    }
    | _return TERM { $$ = node1(RETURN, $2); }
    | _return { $$ = node0(RETURN); }

ARGUMENTS: ARGUMENTS comma ARGUMENT { $$ = node2(CHAIN_RECURSION, $1, $3); }
	 | ARGUMENT { $$ = node1(ARGUMENT, $1); }
	 | %empty { $$ = NULL; }

ARGUMENT: TERM {
		$$ = node1(ARGUMENT, $1);
	}

%%

value_t *execute_tree(ast_t *tree) {
	if(!tree) return 0;
	switch(tree->type) {
		case CHAIN_RECURSION: {
			if (tree->param_list) {
				tree->children[0]->param_list = tree->param_list;
				tree->children[1]->param_list = tree->param_list;
			}
			if (tree->arg_list) {
				tree->children[0]->arg_list = tree->arg_list;
				tree->children[1]->arg_list = tree->arg_list;
			}
			value_t *res = execute_tree(tree->children[0]);
			if (EXEC == 1)
				res = execute_tree(tree->children[1]);
			return res;
		}
		case FUNCTION: {
			if (s_lookup_fn(global_fn, tree->var_name)) {
				printf("Error: function with name %s already exists\n", tree->var_name);
				exit(1);
			}
			if (tree->children[0]) {
				tree->param_list = new_param_queue();
				tree->children[0]->param_list = tree->param_list;
				execute_tree(tree->children[0]);
			}
			if (!tree->value) tree->value = new_value_ptr();
			s_push_fn(global_fn, tree->var_name, tree->children[1], tree->param_list, tree->value->type);
			tree->param_list = NULL;
			return 0;
		}
		case PARAMETER: {
			if (tree->children[0]) {
				tree->children[0]->param_list = tree->param_list;
				execute_tree(tree->children[0]);
			} else {
				q_enqueue_param(tree->param_list, tree->value->type, tree->var_name);
			}
			return 0;
		}
		case CALL: {
			fn_t *fun = s_lookup_fn(global_fn, tree->var_name);
			if (!fun) {
				printf("Error: function with name %s does not exist\n", tree->var_name);
				exit(1);
			}
			// push function marker on stack
			value_t *fn_marker = new_value_ptr();
			fn_marker->type = M_FN;
			s_push(stack, tree->var_name, fn_marker);

			// create arg list if arguments exist
			if (tree->children[0]) {
				arg_queue_t *arg_list = new_arg_queue();
				tree->children[0]->arg_list = arg_list;

				// get arguemnt values and push them on the stack
				execute_tree(tree->children[0]);
				push_args_on_stack(stack, fun->param_list, arg_list);
				free_arg_list(arg_list);
			}

			value_t *res = execute_tree(fun->fn_root);
			EXEC = 1;
			s_clear_fn_stack(stack);
			if (fun->return_type == -1) return 0;
			if (!res || res->type != fun->return_type) {
				printf("Error: return value type does not match for function %s\n", fun->fn_name);
				exit(1);
			}
			return res;
		}
		case ARGUMENT: {
			tree->children[0]->arg_list = tree->arg_list;
			value_t *value = execute_tree(tree->children[0]);
			if (!value) return 0;
			q_enqueue_arg(tree->arg_list, value);
			return 0;
		}
		case RETURN: {
			value_t *res = NULL;
			if (tree->children[0])  res = execute_tree(tree->children[0]);
			EXEC = 0;
			return res;
		}
		case IF: {
			value_t *term = execute_tree(tree->children[0]);
			value_t *res;
			if (term->v.int_num) {
				res = execute_tree(tree->children[1]);
			} else if (tree->children[2]) {
				res = execute_tree(tree->children[2]);
			} else {
				res = 0;
			}
			return res;
		}
		case ELSE: {
			return execute_tree(tree->children[0]);
		}
		case ELSE_IF: {
			value_t *term = execute_tree(tree->children[0]);
			value_t *res;
			if (term->v.int_num) {
				res = execute_tree(tree->children[1]);
			} else if (tree->children[2]) {
				res = execute_tree(tree->children[2]);
			} else {
				res = 0;
			}
			return res;
		}
		case LOOP: {
			value_t *condition = get_loop_condition(tree->children[2]);
			if (!condition->v.int_num) {
				if (tree->children[4]) {
					execute_tree(tree->children[4]);
				}
				return 0;
			}
			value_t *amount = execute_tree(tree->children[0]);
			value_t *stepsize;
			if (tree->children[1]) {
				stepsize = execute_tree(tree->children[1]);
			}
			else {
				stepsize = new_value_ptr();
				stepsize->type = T_INT;
				stepsize->v.int_num = 1;
			}		
			if (amount) {
				if (amount->type != T_INT) {
					printf("Error: loop amount must be of type int\n");
					exit(1);
				}
				if (stepsize->type != T_INT) {
					printf("Error: stepsize of loop must be of type int\n");
					exit(1);
				}
				for (int i = 0; i < amount->v.int_num; i += stepsize->v.int_num) {
					if (EXIT_LOOP) break;
					condition = get_loop_condition(tree->children[2]);
					if (!condition->v.int_num) return 0;
					execute_tree(tree->children[3]);

				}
				EXIT_LOOP = 0;
			} else {
				while (!EXIT_LOOP) {
					condition = get_loop_condition(tree->children[2]);
					if (!condition->v.int_num) return 0;
					execute_tree(tree->children[3]);
				}
				EXIT_LOOP = 0;
			}
			return 0;
		}
		case LOOP_AMOUNT: {
			if (!tree->children[0]) return NULL;
			return execute_tree(tree->children[0]);
		}
		case LOOP_STEP: {
			return execute_tree(tree->children[0]);
		}
		case LOOP_CONDITION: {
			return execute_tree(tree->children[0]);
		}
		case exit_loop: {
			EXIT_LOOP = 1;
			return 0;
		}
		case PUSH: {
			var_t *arr_var = s_lookup(stack, tree->var_name);
			value_t *arr = arr_var->value;
			if (!arr[0].is_array) {
				printf("Error: cannot use array function on non array type\n");
				exit(1);
			}
			value_t *val = execute_tree(tree->children[0]);
			int index = arr[0].index++;
			if (index < 0 || index >= arr[0].v.int_num) {
				printf("Error: index %d out of bounds for array %s\n", index, tree->var_name);
				exit(1);
			}
			arr[index + 1] = *val;
			return 0;
		}
		case GET: {
			var_t *var = s_lookup(stack, tree->var_name);
			if (!var) {
				printf("Error: variable with name %s is not decalred\n", tree->var_name);
				exit(1);
			}
			value_t *value = var->value;
			if (!value) {
				printf("Error: variable %s is not initialized\n", tree->var_name);
				exit(1);
			}
			value_t *index_val = execute_tree(tree->children[0]);
			if (index_val->type != T_INT) {
				printf("Error: invalid type for indexing array %s\n", tree->var_name);
				exit(1);
			}
			int index = index_val->v.int_num;
			value_t *ret;
			switch (value->is_array) {
				case 1: {
					if (index < 0 || index >= value[0].v.int_num) {
						printf("Error: index %d out of bounds for array %s\n", index, tree->var_name);
						exit(1);
					}
					ret = &value[index + 1];
					break;
				}
				default: {
					if (value->type != T_STR) {
						printf("Error: invalid get operation on type %d\n", value->type);
						exit(1);
					}
					if (index < 0 || index >= MAX_STR_LEN) {
						printf("Error: index %d out of bounds for string %s\n", index, tree->var_name);
						exit(1);
					}
					char ch = value->v.str[index];
					ret = new_value_ptr();
					ret->type = T_STR;
					ret->v.str[0] = ch;
					ret->v.str[1] = '\0';
				}
			}
			return ret;
		}
		case TERM: {
			return execute_tree(tree->children[0]);
		}
		case i64: {
			value_t *value = new_value_ptr();
			value->type = T_INT;
			value->v.int_num = tree->value->v.int_num;
			return value;
		}
		case f64: {
			printf("Error: floats not implemented yet\n");
			exit(0);
		}
		case string: {
			value_t *value = new_value_ptr();
			value->type = T_STR;
			value->v.str = strdup(tree->value->v.str);
			value->v.int_num = tree->value->v.int_num;
			return value;
		}
		case create_array: {
			value_t *arr = (value_t *)malloc(sizeof(value_t) * (tree->value->v.int_num + 1));
			arr[0].v.int_num = tree->value->v.int_num;
			arr[0].is_array = 1;
			arr[0].type = tree->value->type;
			s_push(stack, tree->var_name, arr);
			return 0;
		}
		case DECLARE_VAR: {
			if (s_lookup(stack, tree->var_name)) {
				printf("Error: variable with name %s already declared.\n", tree->var_name);
				exit(1);
			}
			s_push(stack, tree->var_name, NULL);
			return 0;
		}
		case INIT_VAR: {
			if (s_lookup(stack, tree->var_name)) {
				printf("Error: variable with name %s already declared.\n", tree->var_name);
				exit(1);
			}
			value_t *value = execute_tree(tree->children[0]);
			s_push(stack, tree->var_name, value);
			return 0;
		}
		case ASSIGN_VAR: {
			var_t *var = s_lookup(stack, tree->var_name);
			if (!var) {
				printf("Error: Cannot assign value to %s, variable does not exist.\n", tree->var_name);
				exit(1);
			}
			value_t *value = execute_tree(tree->children[0]);
			if (value->type != var->value->type) {
				printf("Error: variable types do not match\n");
				exit(1);
			}
			switch (var->value->type) {
				case T_INT: var->value->v.int_num = value->v.int_num; break;
				case T_STR: strcpy(var->value->v.str, value->v.str); break;
				default: {
					printf("Error cannot assing var\n");
					exit(1);
				}
			}
			return 0;
		}
		case RETRIVE_VAR: {
			var_t *var = s_lookup(stack, tree->var_name);
			if (!var) {
				printf("Error: Variable with name %s does not exist\n", tree->var_name);
				exit(1);
			}
			if (!var->value) {
				printf("Error: Variable with name %s is NULL pointer\n", tree->var_name);
				exit(1);
			}
			return var->value;
		}
		case ADD: {
			value_t *value = new_value_ptr();
			value_t *child_one = execute_tree(tree->children[0]);
			value_t *child_two = execute_tree(tree->children[1]);
			value->type = child_one->type;
			value->v.int_num = child_one->v.int_num + child_two->v.int_num;
			return value;
		}
		case SUB: {			
			value_t *value = new_value_ptr();
			value_t *child_one = execute_tree(tree->children[0]);
			value_t *child_two = execute_tree(tree->children[1]);
			value->type = child_one->type;
			value->v.int_num = child_one->v.int_num - child_two->v.int_num;
			return value;
		}
		case MUL: {
			value_t *value = new_value_ptr();
			value_t *child_one = execute_tree(tree->children[0]);
			value_t *child_two = execute_tree(tree->children[1]);
			value->type = child_one->type;
			value->v.int_num = child_one->v.int_num * child_two->v.int_num;
			return value;

		}
		case DIV: {
			value_t *value = new_value_ptr();
			value_t *child_one = execute_tree(tree->children[0]);
			value_t *child_two = execute_tree(tree->children[1]);
			value->type = child_one->type;
			value->v.int_num = child_one->v.int_num / child_two->v.int_num;
			return value;

		}
		case greater_than: {
			value_t *val1 = execute_tree(tree->children[0]);
			value_t *val2 = execute_tree(tree->children[1]);
			if (val1->type != T_INT && val1->type != val2->type) {
				printf("Error: Can only compare %d to %d, but got %d and %d\n", i64, i64, val1->type, val2->type);
				exit(1);
			}
			value_t *value = new_value_ptr();
			value->v.int_num = val1->v.int_num > val2->v.int_num;
			return value;
		}
		case less_than: {
			value_t *val1 = execute_tree(tree->children[0]);
			value_t *val2 = execute_tree(tree->children[1]);
			if (val1->type != T_INT && val1->type != val2->type) {
				printf("Error: Can only compare %d to %d, but got %d and %d\n", i64, i64, val1->type, val2->type);
				exit(1);
			}
			value_t *value = new_value_ptr();
			value->v.int_num = val1->v.int_num < val2->v.int_num;
			return value;
		}
		case equal: {
			value_t *val1 = execute_tree(tree->children[0]);
			value_t *val2 = execute_tree(tree->children[1]);
			if ((val1->type != T_INT || val1->type != T_STR) && val1->type != val2->type) {
				printf("Error: Can only compare %d to %d, but got %d and %d\n", i64, i64, val1->type, val2->type);
				exit(1);
			}
			value_t *value = new_value_ptr();
			switch (val1->type) {
				case T_INT: value->v.int_num = val1->v.int_num == val2->v.int_num; break;
				case T_STR: value->v.int_num = strcmp(val1->v.str, val2->v.str) ? 0 : 1; break;
			}
			return value;
		}
		case or: {
			value_t *val1 = execute_tree(tree->children[0]);
			value_t *val2 = execute_tree(tree->children[1]);
			if (val1->type != T_INT && val1->type != val2->type) {
				printf("Error: Can only compare %d to %d, but got %d and %d\n", i64, i64, val1->type, val2->type);
				exit(1);
			}
			value_t *value = new_value_ptr();
			value->v.int_num = val1->v.int_num || val2->v.int_num;
			return value;
		}
		case and: {
			value_t *val1 = execute_tree(tree->children[0]);
			value_t *val2 = execute_tree(tree->children[1]);
			if (val1->type != T_INT && val1->type != val2->type) {
				printf("Error: Can only compare %d to %d, but got %d and %d\n", i64, i64, val1->type, val2->type);
				exit(1);
			}
			value_t *value = new_value_ptr();
			value->v.int_num = val1->v.int_num && val2->v.int_num;
			return value;
		}
		case print: {
			value_t *value = execute_tree(tree->children[0]);
			switch(value->type) {
				case T_INT: {
					printf("%ld", value->v.int_num);
					break;
				}
				case T_STR: {
					printf("%s", value->v.str);
					break;
				}
				default: {
					printf("Error: Unsupported type %d\n", value->type);
					exit(1);
				}
			}
			return 0;
		}
		case random_num: {
			value_t *limit = execute_tree(tree->children[0]);
			if (limit->type != T_INT) {
				printf("Error: Limit must be of type i64\n");
				exit(1);
			}
			var_t *var = s_lookup(stack, tree->var_name);
			if (!var) {
				printf("Error: Variable %s is not declared\n", tree->var_name);
				exit(1);
			}
			value_t *value = var->value;
			if (!value) {
				value = new_value_ptr();
				value->type = T_INT;
			}
			if (value->type != T_INT) {
				printf("Error: Variable %s is not of type i64\n", tree->var_name);
				exit(1);
			}
			value->v.int_num = (rand() % limit->v.int_num);
			if (!var->value) var->value = value;
			return 0;
		}
		case read_num: {
			var_t *var = s_lookup(stack, tree->var_name);
			if (!var) {
				printf("Error: Variable %s is not declared", tree->var_name);
				exit(1);
			}
			value_t *value = var->value;
			if (!value) {
				value = new_value_ptr();
				value->type = T_INT;
			}	
			if (value->type != T_INT) {
				printf("Error: Variable %s is not of type i64", tree->var_name);
				exit(1);
			}
			scanf("%ld", &(value->v.int_num));
			getchar();
			if (!var->value) var->value = value;
			return 0;
		}
		case read_line: {
			var_t *var = s_lookup(stack, tree->var_name);
			if (!var) {
				printf("Error: Variable %s is not declared", tree->var_name);
				exit(1);
			}
			value_t *value = var->value;
			if (!value) {
				value = new_value_ptr();
				value->type = T_STR;
			}
			if (value->type != T_STR) {
				printf("Error: Variable %s is not of type string", tree->var_name);
				exit(1);
			}
			scanf("%[^\n]s", value->v.str);
			getchar();
			if (!var->value) var->value = value;
			return 0;
		}
		default: {
			printf("Unsupported node type %s\n", getAstNodeTypeName(tree->type));
			break;
		}
	}
	return 0;
}

value_t *get_loop_condition(ast_t *child) {
	if (child) return execute_tree(child);
	value_t *res = new_value_ptr();
	res->v.int_num = 1;
	return res;
}

int main(int argc, char **argv) {
	srand(time(NULL));
	yyin = fopen(argv[1], "r");

	stack = new_stack();
	global_fn = new_fn_stack();
	
	yylval.value = new_value_ptr();

	yyparse();
	return 0;
}
