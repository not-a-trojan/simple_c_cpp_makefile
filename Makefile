##################################################
##                                              ##
##      Simple Universal C/C++ Makefile         ##
##                                              ##
##   Targets:                                   ##
##   help      show usage information           ##
##   all       build debug and release          ##
##   release   build in release mode            ##
##   debug     build in debug mode              ##
##   clean     remove output directories        ##
##                                              ##
##################################################

##################################################
##                CONFIGURATION                 ##
##################################################

# Include directory with the .h files
INC_DIR = include

# Source directory with the .c and .cpp files
SRC_DIR = src

# Output directories
RELEASE_DIR = build-release
DEBUG_DIR = build-debug

# Compiler/Linker options
C_RELEASE_FLAGS   = -Wall -Wextra -pedantic -O3 -fomit-frame-pointer -std=c11
C_DEBUG_FLAGS     = -Wall -Wextra -pedantic -g3 -Og -fsanitize=address -std=c11

CXX_RELEASE_FLAGS = -Wall -Wextra -pedantic -O3 -fomit-frame-pointer -std=c++17
CXX_DEBUG_FLAGS   = -Wall -Wextra -pedantic -g3 -Og -fsanitize=address -std=c++17

RELEASE_LINK_FLAGS =
DEBUG_LINK_FLAGS = -fsanitize=address

# Output file name
OUTPUT = program

# Compilers. Change only if you need to
# CC  = clang
# CXX = clang++

#############################################
##          CORE (do not touch)            ##
#############################################

.PHONY: all release debug clean help compile directories check

HELP_MESSAGE = Simply use any combination of 'make {debug, release, help, clean}'. Just calling 'make' will build release and debug. By adding 'V=1' prints more verbose output.

# list all .c and .cpp files
C_LIST := $(shell find $(SRC_DIR) -name "*.c")
CXX_LIST := $(shell find $(SRC_DIR) -name "*.cpp")

# create object file names in the obj directory
OBJ_FILES := $(patsubst $(SRC_DIR)/%,$(OUTPUT_DIRECTORY)/obj/%, $(C_LIST:.c=.o)) $(patsubst $(SRC_DIR)/%,$(OUTPUT_DIRECTORY)/obj/%, $(CXX_LIST:.cpp=.o))

# Verbosity flag defaults to 0
V = 0

# if verbosity is set to 0, pipe outputs to null and supress command printing
ifeq ($(V),0)
	SUPPRESS_CMD := @
	PIPE := > /dev/null
endif

# if the debug flag is set, append debug options
ifeq ($(D),1)
	C_FLAGS = $(C_DEBUG_FLAGS)
	CXX_FLAGS = $(CXX_DEBUG_FLAGS)
	LINK_FLAGS = $(DEBUG_LINK_FLAGS)
else
	C_FLAGS = $(C_RELEASE_FLAGS)
	CXX_FLAGS = $(CXX_RELEASE_FLAGS)
	LINK_FLAGS = $(RELEASE_LINK_FLAGS)
endif

# clang/gcc options to generate dependency files
DEP_FLAGS = -MT $@ -MMD -MP -MF $(OUTPUT_DIRECTORY)/obj/$*.d

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

debug:
	@+make compile D=1 OUTPUT_DIRECTORY=$(DEBUG_DIR)

release:
	@+make compile D=0 OUTPUT_DIRECTORY=$(RELEASE_DIR)

clean:
	@echo  Removing build artifacts...
	$(SUPPRESS_CMD)rm -rf $(DEBUG_DIR)
	$(SUPPRESS_CMD)rm -rf $(RELEASE_DIR)
	$(SUPPRESS_CMD)rm -f *.stackdump

help:
	@echo $(HELP_MESSAGE)


######################################
# internal targets

# check whether the user used an internal command directly
check:
ifeq ($(OUTPUT_DIRECTORY),)
	$(info You used an unsupported command combination)
	$(info $(HELP_MESSAGE))
	$(error )
endif

# create obj directory and compile
compile: check directories $(OUTPUT_DIRECTORY)/$(OUTPUT)
ifeq ($(D), 1)
	@diff=$$(($(shell date +%s%3N) - $(START_TIME))); echo 'Debug build completed in '$$(($$diff / 1000))'.'$$(($$diff % 1000))'s'
else
	@diff=$$(($(shell date +%s%3N) - $(START_TIME))); echo 'Release build completed in '$$(($$diff / 1000))'.'$$(($$diff % 1000))'s'
endif
	@echo

# create the obj directory
directories: check
ifeq ($(D), 1)
	@echo  '_______Building Debug_______'
else
	@echo  '______Building Release______'
endif
	@mkdir -p $(OUTPUT_DIRECTORY)/obj/

# link output
$(OUTPUT_DIRECTORY)/$(OUTPUT): $(OBJ_FILES)
	@echo
ifeq ($(V), 0)
	@echo  -e 'LINK\t$(OUTPUT)'
endif
	$(SUPPRESS_CMD)$(LINK) -o $(OUTPUT_DIRECTORY)/$(OUTPUT) $(OBJ_FILES) -I $(INC_DIR) $(LINK_FLAGS) $(PIPE)
	@echo

# compile code files
$(OUTPUT_DIRECTORY)/obj/%.o: $(SRC_DIR)/%.c Makefile
ifeq ($(V), 0)
	@echo  -e 'CC\t$(notdir $<)'
endif
	@mkdir -p '$(dir $@)'
	$(SUPPRESS_CMD)$(CC) -c $< -o $@ $(PIPE) $(DEP_FLAGS) $(C_FLAGS) -I $(INC_DIR)
	@touch $@

$(OUTPUT_DIRECTORY)/obj/%.o: $(SRC_DIR)/%.cpp Makefile
ifeq ($(V), 0)
	@echo  -e 'CXX\t$(notdir $<)'
endif
	@mkdir -p '$(dir $@)'
	$(SUPPRESS_CMD)$(CXX) -c $< -o $@ $(PIPE) $(DEP_FLAGS) $(CXX_FLAGS) -I $(INC_DIR)
	@touch $@

#Pull in dependency info for *existing* .o files
-include $(OBJ_FILES:.o=.d)