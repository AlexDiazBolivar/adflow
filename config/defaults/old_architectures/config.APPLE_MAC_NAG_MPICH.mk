#      ******************************************************************
#      *                                                                *
#      * File:          config.APPLE_MAC_NAG_MPICH.mk                   *
#      * Author:        Edwin van der Weide                             *
#      * Starting date: 01-08-2004                                      *
#      * Last modified: 02-23-2006                                      *
#      *                                                                *
#      ******************************************************************

#      ******************************************************************
#      *                                                                *
#      * Description: Defines the compiler settings and other commands  *
#      *              to have "make" function correctly. This file      *
#      *              defines the settings for a parallel Mac           *
#      *              executable using the NAG f95 and the gcc          *
#      *              compilers in combination with mpich.              *
#      *                                                                *
#      ******************************************************************

#      ==================================================================

#      ******************************************************************
#      *                                                                *
#      * Possibly overrule the make command to allow for parallel make. *
#      *                                                                *
#      ******************************************************************

#MAKE = make -j 2

#      ******************************************************************
#      *                                                                *
#      * Suffix of the executable such that binaries of multiple        *
#      * platforms can be stored in the bin directory.                  *
#      *                                                                *
#      ******************************************************************

EXEC_SUFFIX = _apple_mac_nag_mpich

#      ******************************************************************
#      *                                                                *
#      * F90 and C compiler definitions.                                *
#      *                                                                *
#      ******************************************************************

FF90 = /usr/local/mpich-nag/bin/mpif90
CC   = /usr/local/mpich-nag/bin/mpicc

#      ******************************************************************
#      *                                                                *
#      * CGNS include and linker flags.                                 *
#      *                                                                *
#      ******************************************************************

CGNS_INCLUDE_FLAGS = -I$(HOME)/CGNS2.3/include
CGNS_LINKER_FLAGS  = -L$(HOME)/CGNS2.3/lib -lcgns.DARWIN

#      ******************************************************************
#      *                                                                *
#      * Precision flags. When nothing is specified 4 byte integer and  *
#      * and 8 byte real types are used. The flag -DUSE_LONG_INT sets   *
#      * the 8 byte integer to the standard integer type. The flag      *
#      * -DUSE_SINGLE_PRECISION sets the 4 byte real to the standard    *
#      * real type and -DUSE_QUADRUPLE_PRECISION will make 16 byte      *
#      * reals the default type. The latter option may not work on all  *
#      * platforms.                                                     *
#      *                                                                *
#      ******************************************************************

#FF90_INTEGER_PRECISION_FLAG = -DUSE_LONG_INT
#CC_INTEGER_PRECISION_FLAG   = -DUSE_LONG_INT

#FF90_REAL_PRECISION_FLAG = -DUSE_SINGLE_PRECISION
#FF90_REAL_PRECISION_FLAG = -DUSE_QUADRUPLE_PRECISION
#CC_REAL_PRECISION_FLAG   = -DUSE_SINGLE_PRECISION
#CC_REAL_PRECISION_FLAG   = -DUSE_QUADRUPLE_PRECISION

FF90_PRECISION_FLAGS = $(FF90_INTEGER_PRECISION_FLAG) \
		       $(FF90_REAL_PRECISION_FLAG)
CC_PRECISION_FLAGS   = $(CC_INTEGER_PRECISION_FLAG) \
		       $(CC_REAL_PRECISION_FLAG)

#      ******************************************************************
#      *                                                                *
#      * Compiler flags.                                                *
#      *                                                                *
#      ******************************************************************

COMMAND_SEARCH_PATH_MODULES = -I

FF90_GEN_FLAGS = -fpp -kind=byte -mismatch_all -Wc,-fno-common
CC_GEN_FLAGS   =  -fno-common

FF90_OPTFLAGS   = -O4
#CC_OPTFLAGS     = -O3 -fexpensive-optimizations -frerun-cse-after-loop \
		  -fthread-jumps -funroll-loops -finline-functions
CC_OPTFLAGS     = -O

#FF90_DEBUGFLAGS = -g -ieee=stop -nan -C -gline
#CC_DEBUGFLAGS   = -g -Wall -pedantic

FF90_FLAGS = $(FF90_GEN_FLAGS) $(FF90_OPTFLAGS) $(FF90_DEBUGFLAGS)
CC_FLAGS   = $(CC_GEN_FLAGS)   $(CC_OPTFLAGS)   $(CC_DEBUGFLAGS)

#      ******************************************************************
#      *                                                                *
#      * pV3 and pvm3 linker flags.                                     *
#      *                                                                *
#      ******************************************************************

#PV3_FLAGS          = -DUSE_PV3
#PV3_LINKER_FLAGS   = -L/usr/local/pV3/clients/LINUX -lpV3
#PVM3_LINKER_FLAGS  = -L/usr/local/pvm3/lib/LINUX -lgpvm3 -lpvm3
#PV3_INT_SRC_DIR    = src/pv3Interface

#      ******************************************************************
#      *                                                                *
#      * Archiver and archiver flags.                                   *
#      *                                                                *
#      ******************************************************************

AR       = ar
AR_FLAGS = -rvs

#      ******************************************************************
#      *                                                                *
#      * Linker and linker flags.                                       *
#      *                                                                *
#      ******************************************************************

LINKER       = $(FF90)
LINKER_FLAGS = $(FF90_OPTFLAGS)
