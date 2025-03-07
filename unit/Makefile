###############################################################################
################### MOOSE Application Standard Makefile #######################
###############################################################################
#
# Required Environment variables (one of the following)
# PACKAGES_DIR  - Location of the MOOSE redistributable package
#
# Optional Environment variables
# MOOSE_DIR     - Root directory of the MOOSE project
# FRAMEWORK_DIR - Location of the MOOSE framework
#
###############################################################################
# Use the MOOSE submodule if it exists and MOOSE_DIR is not set
MOOSE_SUBMODULE    := $(CURDIR)/../moose
ifneq ($(wildcard $(MOOSE_SUBMODULE)/framework/Makefile),)
  MOOSE_DIR        ?= $(MOOSE_SUBMODULE)
else
  MOOSE_DIR        ?= $(shell dirname `pwd`)/../moose
endif
FRAMEWORK_DIR      ?= $(MOOSE_DIR)/framework
###############################################################################

# framework
include $(FRAMEWORK_DIR)/build.mk
include $(FRAMEWORK_DIR)/moose.mk

################################## MODULES ####################################
# To use certain physics included with MOOSE, set variables below to
# yes as needed.  Or set ALL_MODULES to yes to turn on everything (overrides
# other set variables).

ALL_MODULES                 := no

CHEMICAL_REACTIONS          := yes
CONTACT                     := no
EXTERNAL_PETSC_SOLVER       := no
FLUID_PROPERTIES            := yes # this module is activated by THERMAL_HYDRAULICS
FUNCTIONAL_EXPANSION_TOOLS  := no
HEAT_TRANSFER               := yes
LEVEL_SET                   := no
MISC                        := yes # this module is activated by THERMAL_HYDRAULICS
NAVIER_STOKES               := yes # this module is activated by THERMAL_HYDRAULICS
PHASE_FIELD                 := yes
POROUS_FLOW                 := no
RAY_TRACING                 := yes # this module is activated by THERMAL_HYDRAULICS
RDG                         := yes # this module is activated by THERMAL_HYDRAULICS
RICHARDS                    := no
SCALAR_TRANSPORT            := yes
SOLID_PROPERTIES            := yes
STOCHASTIC_TOOLS            := yes
SOLID_MECHANICS             := yes
THERMAL_HYDRAULICS          := yes
XFEM                        := no

include $(MOOSE_DIR)/modules/modules.mk
###############################################################################

# Extra stuff for GTEST
ADDITIONAL_INCLUDES := -I$(FRAMEWORK_DIR)/contrib/gtest
ADDITIONAL_LIBS     := $(FRAMEWORK_DIR)/contrib/gtest/libgtest.la

# dep apps
CURRENT_DIR        := $(shell pwd)
APPLICATION_DIR    := $(CURRENT_DIR)/..
APPLICATION_NAME   := tmap8
include            $(FRAMEWORK_DIR)/app.mk

APPLICATION_DIR    := $(CURRENT_DIR)
APPLICATION_NAME   := tmap8-unit
BUILD_EXEC         := yes

DEP_APPS    ?= $(shell $(FRAMEWORK_DIR)/scripts/find_dep_apps.py $(APPLICATION_NAME))
include $(FRAMEWORK_DIR)/app.mk

# Find all the TMAP unit test source files and include their dependencies.
tmap_unit_srcfiles := $(shell find $(CURRENT_DIR)/src -name "*.C")
tmap_unit_deps := $(patsubst %.C, %.$(obj-suffix).d, $(tmap_unit_srcfiles))
-include $(tmap_unit_deps)

###############################################################################
# Additional special case targets should be added here
