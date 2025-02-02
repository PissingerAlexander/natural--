# My Programming Language

## Entry Point
The entry point of a program is a function called `main`, which serves as the starting point for execution. It is defined as follows:

```plaintext
function main returns nothing() {
  STATEMENTS
}
```

Example:
```plaintext
function main returns nothing () {
    print(str(Hello, World!));
}
```
This function must always be present in a program, and it does not return any value.

## Data Types
There are three fundamental data types supported in this language:

- **i64**: Represents a 64-bit integer, suitable for numerical calculations.
- **string**: Represents a sequence of characters, enclosed within `str(...)` syntax.
- **array**: A collection of elements of the same type, which can either contain integer or string values.

Example:
```plaintext
num as i64 = b(X)42;
text as string = str(Example);
numbers as array;
numbers = create array of size b(X)5 as i64;
```

## Variables
### Declaration
Variables must be declared before use with an explicit type:
```plaintext
VAR_NAME as TYPE;
```

### Initialization
A variable can be initialized at the time of declaration:
```plaintext
VAR_NAME as TYPE = VALUE;
```

### Reassignment
Once declared, a variable's value can be reassigned:
```plaintext
VAR_NAME = NEW_VALUE;
```

## Number Representation
Numbers can be represented in various bases, using a special syntax:

### Decimal (Base 10)
```plaintext
var as i64 = b(X)4;
```

### Binary (Base 2)
```plaintext
bin as i64 = b(II)1101;
```

### Hexadecimal (Base 16)
```plaintext
hex as i64 = b(XVI)1af3;
```
The notation `b(BASE)value` specifies the numerical base using a Roman numerals.

## Strings
Strings are sequences of characters, which can include escape sequences:
```plaintext
str as string = str(Test${0x0a});
```
Example:
```plaintext
message as string = str(Hello, ${0x0a}World!);
```
Explanation:
- `str( ... )` marks the beginning of a string.
- `${ ... }` is an escape sequence representing any character. These are defined using hexadecimal values.

### Accessing Characters
Individual characters within a string can be accessed using their index:
```plaintext
STR_VAR.get(INDEX)
```
Example:
```plaintext
first_letter = message.get(0);
```

## Arrays
### Declaration
An array is created with a specific size and type:
```plaintext
VAR_NAME = create array of size SIZE as TYPE;
```
Example:
```plaintext
scores = create array of size 10 as i64;
```

### Adding Values
Values can be appended dynamically at the end of the array, but the size of an array cannot change:
```plaintext
VAR_NAME.push(VALUE)
```
Example:
```plaintext
scores.push(b(X)95);
```
Attempting to push beyond the defined size will result in an error.

### Accessing Elements
Elements within an array can be accessed using their index:
```plaintext
VAR_NAME.get(INDEX)
```
Example:
```plaintext
first_score = scores.get(b(X)0);
```
Attempting to access an index out of bounds will result in an error.

## Control Structures
### Conditional Statements
```plaintext
if (CONDITION) then { STATEMENTS } else if (CONDITION2) / else { STATEMENTS }
```
Example:
```plaintext
if (age is greater than b(X)18) then {
  print(str(Adult));
} else {
  print(str(Minor));
}
```

### Loops
```plaintext
repeat NUMBER / infinite times as long as (CONDITION) { STATEMENTS }
```
Example:
```plaintext
repeat b(X)5 times {
  print(str(Hello, World!${0x0a));
}
```

## Logical Operations
### Comparison Functions
- `is equal to`: Checks if two values are the same.
- `is less than`: Checks if one value is smaller than another.
- `is greater than`: Checks if one value is larger than another.

Example:
```plaintext
if (score is greater than b(X)50) then {
  print(str(Passed));
}
```

### Logical Operators
- `or`: Evaluates as true if at least one condition is met.
- `and`: Evaluates as true only if both conditions are met.

Example:
```plaintext
if (age is greater than 18 and has_id is equal to b(X)1) then {
  print(str(Allowed));
}
```

## Arithmetic Operations
```plaintext
VAR_NAME = apply OPERATION_TYPE to (VAR_NAME/constant value and VAR_NAME/constant value)
```
Example:
```plaintext
result = apply addition to (b(X)5 and b(X)10);
```

## Functions
### Definition
```plaintext
function FUNCTION_NAME returns TYPE/nothing (PARAMETER_LIST) { STATEMENTS }
```
Example:
```plaintext
function add returns i64 (a as i64, b as i64) {
    return apply addition to (a and b);
}
```

### Execution
```plaintext
call FUNCTION_NAME(ARGUMENTS);
```
Example:
```plaintext
sum = call add(10, 20);
```

