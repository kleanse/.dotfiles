# Names of the binaries to produce.
prod_target :=
debug_target := debug_$(prod_target)

# Type of the files to compile.
FT := cpp

# Consult Section 16.5 of the GNU "make" manual for more information about some
# of these variables.
prefix := .
exec_prefix := $(prefix)
bindir := $(exec_prefix)/.
srcdir := .
objdir := .
incdir := .

# Directory for Makefile prerequisite files (".d" files);
# mnemonic: Dependency Directory
depdir := .

deps := $(wildcard $(depdir)/*.d)
srcs := $(wildcard $(srcdir)/*.$(FT))
objs := $(patsubst $(srcdir)/%.$(FT), $(objdir)/%.o, $(srcs))

debug_flags := -O0 -g
prod_flags := -O2 -DNDEBUG
compiler_flags := -pedantic-errors -Wall -Wextra -Werror -I$(incdir)
linker_flags :=

# Use the correct compiler and compiler flags.
ifeq ($(FT), cpp)
compiler := $(CXX)
compiler_flags += -std=c++20 $(CXXFLAGS)
else
compiler := $(CC)
compiler_flags += $(CFLAGS)
endif

linker_flags += $(LDFLAGS) $(LDLIBS)

# Determine appropriate recipes for certain targets.
ifeq ($(bindir), ./.)
clean_recipe := rm -f $(debug_target) $(prod_target)
else
clean_recipe := rm -rf $(bindir)
endif

ifeq ($(objdir), .)
mostlyclean_recipe := rm -f $(notdir $(objs))
else
mostlyclean_recipe := rm -rf $(objdir)
endif

ifeq ($(depdir), .)
realclean_recipe := rm -f $(notdir $(deps))
else
realclean_recipe := rm -rf $(depdir)
endif

# Makefile rules.
.PHONY: all
all: debug

# Read the dependency (".d") files to get header prerequisites for object
# files. No rule is defined for these files: they are updated in the rule for
# object files.
-include $(patsubst $(srcdir)/%.$(FT), $(depdir)/%.d, $(srcs))

.PHONY: debug
debug: compiler_flags := $(debug_flags) $(compiler_flags)
debug: $(bindir)/$(debug_target)

.PHONY: prod
prod: mostlyclean
prod: compiler_flags := $(prod_flags) $(compiler_flags)
prod: $(bindir)/$(prod_target)

.PHONY: clean
clean:
	$(clean_recipe)

.PHONY: mostlyclean
mostlyclean: clean
	$(mostlyclean_recipe)

.PHONY: realclean
realclean: mostlyclean
	$(realclean_recipe)

ifneq ($(bindir), ./.)
$(bindir):
	@mkdir $@
endif

ifneq ($(objdir), .)
$(objdir):
	@mkdir $@
endif

ifneq ($(depdir), .)
$(depdir):
	@mkdir $@
endif

$(objdir)/%.o: $(srcdir)/%.$(FT) | $(objdir) $(depdir)
	$(compiler) -o $@ -MMD -MF $(depdir)/$*.d -c $(compiler_flags) $<

$(bindir)/$(debug_target): $(objs) | $(bindir)
	$(compiler) -o $@ $(linker_flags) $^

$(bindir)/$(prod_target): $(objs) | $(bindir)
	$(compiler) -o $@ $(linker_flags) $^
