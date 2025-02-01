# natural--
> [!CAUTION]
> You should defenetly NOT use this compiler/interpreter, because of memory leaks and bugs!

# Introduction
This project provides a complete toolchain for interpreting programs written in my own programming language `natural--`, a language designed to be insecure, buggy, leaking memory and much more bad stuff (but it kinda gets the job done sometimes).

# Installation
## Prerequesits
Ensure you have the following installed:
* gcc
* flex
* bison

## Building from source
```bash
# Clone the repository
git clone https://github.com/PissingerAlexander/natural--.git
cd natural--

# Build the compiler
make

# Optional: clean the project folder
make clean

# To delete clean the whole project
make purge
```

# Usage
## Running a natural-- script
`./proj script`

# Example Code
```
function main returns nothing() {
	print(str(Hello World!));
}
```

There are more examples in the `exec/` directory.

