%{
#include <stdio.h>
#include <string.h>

#include "src/headers/stack.h"
#include "src/headers/value.h"
#include "src/headers/ast.h"
#include "src/headers/value_names.h"

#include "bison.def.tab.h"

	typedef struct ast_struct ast_t;

	int get_type(char *str);
	char *extractRomanNumerals(char *str);
	int convertRomanToInt(char *str);
	char *extractNumber(char *str);
	int get_operation(char *str);
	void append_to_string_buffer(char *buffer, char ch);

%}

%option noyywrap noinput nounput yylineno stack

%x LINE_COMMENT
%x BLOCK_COMMENT
%x STRING

LPAR		"("
RPAR		")"
LCUR		"{"
RCUR		"}"
COMMA		","

LINE_COMMENT	"//"
BLOCK_COMMENT	"/*"
END_COMMENT	"*/"

TYPE_SEPARATOR	as
TYPE		(i64|string|array)
ASSIGN		"="
END_STATEMENT	";"

ARRAY_TYPE	array
CREATE_ARRAY	"create array of size"
PUSH		.push
GET		.get
SET		.set

BASE		b\([IVX]+\)
INT		[0-9a-fA-F]*

HEX		0x[0-9a-fA-F]+

FLOAT		{INT}\.{INT}

APPLY		apply
OPERATION	(addition|subtraction|multiplication|division)
TO		to

AND		and
OR		or

IF		if
THEN		then
ELSE		else

GT		"is greater than"
LT		"is less than"
EQ		"is equal to"

REPEAT		repeat
TIMES		times
STEPSIZE	"in steps of"
CONDITION	"as long as"
EXIT		"exit loop"

INFINITE	infinite

START_STRING	str{LPAR}
END_STRING	{RPAR}
ESCAPED_CHAR	\${LCUR}{HEX}{RCUR}

FUNCTION	function
RETURNS		returns
NOTHING		nothing
RETURN		return

CALL		call

PRINT		print
RANDOM_NUM	"random i64 up to"
READ_LINE	"read line"
READ_NUM	"read number"

VAR_NAME	[a-zA-Z_][a-zA-Z0-9_]*

%%

{ESCAPED_CHAR}		{ printf("Recognized Escape"); }

{LPAR}			{ return lpar; }
{RPAR}			{ return rpar; }
{LCUR}			{ return lcur; }
{RCUR}			{ return rcur; }

{TYPE_SEPARATOR}	{ return type_separator; }
{TYPE}			{ 
				yylval.value = new_value_ptr();
				yylval.value->type = get_type(yytext);
				return type;
			}
{ASSIGN}		{ return assign; }
{END_STATEMENT}		{ return end_statement; }

{ARRAY_TYPE}		{ return array_type; }
{CREATE_ARRAY}		{ return create_array; }
{PUSH}			{ return push; }
{GET}			{ return get; }
{SET}			{ return set; }

{BASE}[ \t]*{INT}	{
				char *romanStr = extractRomanNumerals(strdup(yytext));
				int base = convertRomanToInt(romanStr);
				char *number = extractNumber(strdup(yytext));
				long val = strtol(number, NULL, base);
				yylval.value = new_value_ptr();
				yylval.value->v.int_num = val;
				return i64;
			}

{APPLY}			{ return apply; }
{OPERATION}		{ 
				yylval.operation = get_operation(yytext);
				return operation;
			}
{TO}			{ return to; }

{AND}			{ return and; }
{OR}			{ return or; }

{IF}			{ return _if; }
{THEN}			{ return then; }
{ELSE}			{ return _else; }

{GT}			{ return greater_than; }
{LT}			{ return less_than; }
{EQ}			{ return equal; }

{REPEAT}		{ return repeat; }
{INFINITE}		{ return infinite; }
{TIMES}			{ return times; }
{STEPSIZE}		{ return stepsize; }
{CONDITION}		{ return condition; }
{EXIT}			{ return exit_loop; }

{START_STRING}		{ 
	yy_push_state(YYSTATE); 
	BEGIN(STRING); 
	yylval.value = new_value_ptr(); 
	yylval.value->v.str = (char *)calloc(1, MAX_STR_LEN);
			}
<STRING>{
	{ESCAPED_CHAR}	{
				char *cp = strdup(yytext);
				char *hex_part = cp + 2;
				char *hex_part_end = yytext + strlen(hex_part) - 1;
				hex_part_end = '\0';
				long ch_val = strtol(hex_part, NULL, 16);
				char ch = ch_val;
				append_to_string_buffer(yylval.value->v.str, ch);
	}
	{END_STRING}	{ 
				yy_pop_state(); 
				return string; 
	}

	.		{
				// add char to value->v.str
				char *ch = strdup(yytext);
				append_to_string_buffer(yylval.value->v.str, ch[0]);
	}

}

{FUNCTION}		{ return function; }
{RETURNS}		{ return returns; }
{NOTHING}		{ return nothing; }
{COMMA}			{ return comma; }
{RETURN}		{ return _return; }

{CALL}			{ return call; }

{PRINT}			{ return print; }
{RANDOM_NUM}		{ return random_num; }
{READ_NUM}		{ return read_num; }
{READ_LINE}		{ return read_line; }

{LINE_COMMENT}		{ yy_push_state(YYSTATE); BEGIN(LINE_COMMENT); }
<LINE_COMMENT>{
	\n		{ yy_pop_state(); }
	[^\n]*
}
{BLOCK_COMMENT}		{ yy_push_state(YYSTATE); BEGIN(BLOCK_COMMENT); }
<BLOCK_COMMENT>{
	{END_COMMENT}	{ yy_pop_state(); }
	(.|\n)
}

{VAR_NAME}		{ yylval.var_name = strdup(yytext); return var_name; }
[ \t\n]

%%

int get_type(char *str) {
	for (int i = 0; i < VAR_TYPE_COUNT; i++) {
		if (strcmp(str, var_type_names[i]) == 0) {
			return i;
		}
	}
	printf("Error: Unknown type %s\n", str);
	exit(0);
}

char *extractRomanNumerals(char *str) {
	int offset = 0;
	char *romanStr = (char *)malloc(sizeof(char) * 4);

	str += 2;
	while(*str != ')') {
		romanStr[offset++] = *str;
		str++;
	}
	romanStr[offset] = 0;
	return romanStr;
}

int convertRomanToInt(char *str) {
	int result = 0;
	int current = 0;
	int next = 0;

	while(*str != 0) {
		switch(*str) {
			case 'I': current = 1; break;
			case 'V': current = 5; break;
			case 'X': current = 10; break;
		}
		switch(*(str+1)) {
			case 'I': next = 1; break;
			case 'V': next = 5; break;
			case 'X': next = 10; break;
		}
		if (next > current) {
			result += next - current;
			str++;
		} else result += current;
		str++;
	}
	if(result > 16) {
		printf("Error: Base too large\n");
		exit(0);
	}
	return result;
}

char *extractNumber(char *str) {
	int offset = 0;
	char *val = malloc(sizeof(char) * 65);
	
	while(*str != 0) {
		if(*str < 48 || *str > 57) {
			str++;
			continue;
		}
		val[offset++] = *str;
		str++;
	}
	return val;
}

int get_operation(char *str) {
	if (strcmp(str, "addition") == 0) return ADD;
	if (strcmp(str, "subtraction") == 0) return SUB;
	if (strcmp(str, "multiplication") == 0) return MUL;
	if (strcmp(str, "division") == 0) return DIV;
	printf("Error: Invalid operation %s\n", str);
	exit(1);
}

void append_to_string_buffer(char *buffer, char ch) {
	int pos = strlen(buffer);
	if (pos >= MAX_STR_LEN) {
		printf("Error: String to long\n");
		exit(1);
	}
	buffer[pos] = ch;
	buffer[pos + 1] = '\0';
}
