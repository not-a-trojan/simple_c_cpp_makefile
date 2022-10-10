########################################################
##                                                    ##
##       Simple Universal C/C++ Makefile v1.3         ##
##                                                    ##
##   Targets:                                         ##
##   help      show usage information                 ##
##   all       build 'debug' and 'release'            ##
##   re        force rebuild 'debug' and 'release'    ##
##   release   build in release mode                  ##
##   debug     build in debug mode                    ##
##   clean     remove output directories              ##
##                                                    ##
########################################################

########################################################
##                   CONFIGURATION                    ##
########################################################

# Include directories with .h files. Separate multiple directories with a space.
INC_DIRS = include

# Source directories with the .c and .cpp files. Separate multiple directories with a space.
SRC_DIRS = src

# Output file name. If undefined/empty, output binaries are named 'debug' and 'release'.
# OUTPUT = my_executable

# Output directories for release and debug configurations.
# If both point to the same directory and OUTPUT is specified, the final binaries will be suffixed with "_release" and "_debug".
DEBUG_DIR = build
RELEASE_DIR = build

# Compiler options
C_DEBUG_FLAGS     = -Wall -Wextra -Wshadow -pedantic -g3 -Og -fsanitize=address -std=c11
C_RELEASE_FLAGS   = -Wall -Wextra -Wshadow -pedantic -O3 -fomit-frame-pointer -std=c11

CXX_DEBUG_FLAGS   = -Wall -Wextra -Wshadow -pedantic -g3 -Og -fsanitize=address -std=c++17
CXX_RELEASE_FLAGS = -Wall -Wextra -Wshadow -pedantic -O3 -fomit-frame-pointer -std=c++17

# Linker options. Add libraries you want to link against here.
DEBUG_LINK_FLAGS = -fsanitize=address
RELEASE_LINK_FLAGS =

# Compilers
# CC  = clang
# CXX = clang++

# Autorun. If defined, run binaries after building.
RUN_AFTER_BUILD = 1

# Verbose mode. If V is defined, make prints commands and options before execution.
# V = 1

#############################################
##          CORE (do not touch)            ##
#############################################

.PHONY: all re release debug clean help compile print_start

HELP_MESSAGE = "Simply use any combination of 'make {debug, release, re, help, clean}'.\n" \
               "Plain 'make' is equivalent to 'make debug release', i.e., build both configurations.\n" \
               "'make re' is equivalent to 'make clean debug release', i.e., forces a rebuild.\n" \
			   "If 'RUN_AFTER_BUILD' is not empty, each binary built is also executed.\n" \
			   "By adding 'V=1' every executed command is printed."

ifeq ($(OUTPUT),)
	DEBUG_OUTPUT := debug
else
ifeq ($(RELEASE_DIR), $(DEBUG_DIR))
	DEBUG_OUTPUT := $(basename $(OUTPUT))_debug$(suffix $(OUTPUT))
endif
endif
ifeq ($(OUTPUT),)
	RELEASE_OUTPUT := release
else
ifeq ($(RELEASE_DIR), $(DEBUG_DIR))
	RELEASE_OUTPUT := $(basename $(OUTPUT))_release$(suffix $(OUTPUT))
endif
endif

# switch between debug and release config
ifeq ($(D),1)
	C_FLAGS = $(C_DEBUG_FLAGS)
	CXX_FLAGS = $(CXX_DEBUG_FLAGS)
	LINK_FLAGS = $(DEBUG_LINK_FLAGS)
	OBJ_DIR = obj_debug
else
	C_FLAGS = $(C_RELEASE_FLAGS)
	CXX_FLAGS = $(CXX_RELEASE_FLAGS)
	LINK_FLAGS = $(RELEASE_LINK_FLAGS)
	OBJ_DIR = obj_release
endif

# list all .c and .cpp files
C_LIST := $(foreach dir,$(SRC_DIRS),$(patsubst $(dir)/%,$(OUTPUT_DIRECTORY)/$(OBJ_DIR)/$(dir)/%,$(shell find $(dir) -name "*.c")))
CXX_LIST := $(foreach dir,$(SRC_DIRS),$(patsubst $(dir)/%,$(OUTPUT_DIRECTORY)/$(OBJ_DIR)/$(dir)/%,$(shell find $(dir) -name "*.cpp")))

# create object file names in the obj directory
OBJ_FILES := $(C_LIST:.c=.o) $(CXX_LIST:.cpp=.o)

# if verbosity is set to 'empty', supress command printing
ifndef V
	SUPPRESS_CMD := @
endif

# clang/gcc options to generate dependency files
DEP_FLAGS = -MT $@ -MMD -MP -MF $(OUTPUT_DIRECTORY)/$(OBJ_DIR)/$*.d

# select appropriate linker
ifeq ($(CXX_LIST),)
	LINK := $(CC)
else
	LINK := $(CXX)
endif

# store make invocation time
START_TIME := $(shell date +%s%3N)

# tell make to not print spam on recursive calls
MAKEFLAGS += --no-print-directory

######################################
# targets for the user

all: debug release
re: clean all

debug:
	$(eval EXECUTE_DEBUG := 1)
	@+make compile D=1 OUTPUT_DIRECTORY=$(DEBUG_DIR) OUTPUT=$(DEBUG_OUTPUT)

release:
	$(eval EXECUTE_RELEASE := 1)
	@+make compile D=0 OUTPUT_DIRECTORY=$(RELEASE_DIR) OUTPUT=$(RELEASE_OUTPUT)

clean:
	@echo  Removing build artifacts...
	$(SUPPRESS_CMD)rm -rf $(DEBUG_DIR) $(RELEASE_DIR)
	$(SUPPRESS_CMD)rm -f *.stackdump

help:
	@echo $(HELP_MESSAGE)


######################################
# internal targets

# printing for pretty output
print_start:
ifneq ($(D),0)
ifneq ($(D),1)
	$(error Internal Error. Use 'make help' for usage instructions.)
endif
endif
ifeq ($(D), 1)
	@echo  '_______Building Debug_______'
else
	@echo  '______Building Release______'
endif

# create obj directory and compile, execute if requested
compile: $(OUTPUT_DIRECTORY)/$(OUTPUT)
ifeq ($(D), 1)
	@diff=$$(($(shell date +%s%3N) - $(START_TIME))); echo 'Debug build completed in '$$(($$diff / 1000))'.'$$(($$diff % 1000))'s'
else
	@diff=$$(($(shell date +%s%3N) - $(START_TIME))); echo 'Release build completed in '$$(($$diff / 1000))'.'$$(($$diff % 1000))'s'
endif
	@echo
ifdef RUN_AFTER_BUILD
ifeq ($(D), 1)
	@echo '_______Running Debug_______'
else
	@echo '______Running Release______'
endif
	$(SUPPRESS_CMD)$(OUTPUT_DIRECTORY)/$(OUTPUT)
endif
	@echo

# link output
$(OUTPUT_DIRECTORY)/$(OUTPUT): $(OBJ_FILES)
	@echo
ifndef V
	@echo  -e 'LINK\t$(OUTPUT)'
endif
	$(SUPPRESS_CMD)$(LINK) -o $(OUTPUT_DIRECTORY)/$(OUTPUT) $(OBJ_FILES) $(LINK_FLAGS)
	@echo

# compile C files
$(OUTPUT_DIRECTORY)/$(OBJ_DIR)/%.o: %.c Makefile | print_start
ifndef V
	@echo  -e 'CC\t$<'
endif
	@mkdir -p '$(dir $@)'
	$(SUPPRESS_CMD)$(CC) -c $< -o $@ $(DEP_FLAGS) $(C_FLAGS) $(foreach dir,$(INC_DIRS),-I $(dir))

# compile C++ files
$(OUTPUT_DIRECTORY)/$(OBJ_DIR)/%.o: %.cpp Makefile | print_start
ifndef V
	@echo  -e 'CXX\t$<'
endif
	@mkdir -p '$(dir $@)'
	$(SUPPRESS_CMD)$(CXX) -c $< -o $@ $(DEP_FLAGS) $(CXX_FLAGS) $(foreach dir,$(INC_DIRS),-I $(dir))

#Pull in dependency info for *existing* .o files
-include $(OBJ_FILES:.o=.d)
