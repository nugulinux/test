CMAKE_MINIMUM_REQUIRED(VERSION 3.1)
PROJECT(nugu)

INCLUDE(GNUInstallDirs)
INCLUDE(FindPkgConfig)

# C++ standard: c++11 (not gnu++11)
SET(CMAKE_CXX_STANDARD 11)
SET(CMAKE_CXX_EXTENSIONS OFF)

# C standard: gnu99 (not c99)
SET(CMAKE_C_STANDARD 99)
SET(CMAKE_C_EXTENSIONS ON)

# build type: debug (default)
IF (NOT CMAKE_BUILD_TYPE)
	SET(CMAKE_BUILD_TYPE Debug)
ENDIF()

# Get CFLAGS and LDFLAGS from pkg-config
pkg_check_modules(pkgs REQUIRED
	glib-2.0
	gio-2.0
	gio-unix-2.0
	gthread-2.0
	openssl
	zlib)
FOREACH(flag ${pkgs_CFLAGS})
	ADD_COMPILE_OPTIONS(${flag})
ENDFOREACH(flag)

# Common compile options
ADD_COMPILE_OPTIONS(
	-g -Os
	-fPIC

	# Improved version of “-fstack-protector” since gcc 4.9
	-fstack-protector-strong

	# Non-executable stack
	-Wa,--execstack

	# Store the stack frame pointer in a register.
	-fno-omit-frame-pointer

	# Eliminate unused code and data (with --gc-sections link option)
	-fdata-sections -ffunction-sections

	# Increase reliability of backtraces
	-fasynchronous-unwind-tables

	# Turn on all warnings and treat all warnings as errors.
	-Werror -Wall -Wextra

	# Additional warnings
	-Wunreachable-code -Wpointer-arith
	-Wformat=2 -Wno-format-nonliteral

	# Not warnings
	-Wno-missing-field-initializers
	-Wno-unused-parameter)

IF ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug" AND "${CMAKE_LIBRARY_ARCHITECTURE}" MATCHES "x86")
	MESSAGE("Enable AddressSanitizer")
	# Apply AddressSanitizer
	# - https://github.com/google/sanitizers/wiki/AddressSanitizer
	ADD_COMPILE_OPTIONS(-fsanitize=address)
	LINK_LIBRARIES(-lasan)
ENDIF()

IF ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
	# Eliminate unused code and data (with --gc-sections link option)
	ADD_COMPILE_OPTIONS(-Wl,--gc-sections)

	IF (NOT ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
		# Link only needed libraries
		LINK_LIBRARIES(-Wl,--as-needed)

		# Enforces symbol resolution at build time
		LINK_LIBRARIES(-Wl,-z,defs)

		# Non-executable stack
		LINK_LIBRARIES(-Wl,-z,noexecstack)

		# RPATH is useful only for testing without installation. Please use the
		# '-DNO-RPATH' option for debian packaging.
		IF (NOT NO-RPATH)
			LINK_LIBRARIES(-Wl,--rpath=${CMAKE_BINARY_DIR})
		ENDIF()
	ENDIF()
ENDIF()

# Add __FILENAME__ macro to use path from source directory instead of full path
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__FILENAME__='\"$(subst $(realpath ${CMAKE_SOURCE_DIR})/,,$(abspath $<))\"'")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__FILENAME__='\"$(subst $(realpath ${CMAKE_SOURCE_DIR})/,,$(abspath $<))\"'")

# Global definitions
ADD_DEFINITIONS(
	# Run-time buffer overflow detection
	-D_FORTIFY_SOURCE=2

	# Turn on the colorful log message
	-DCONFIG_LOG_ANSICOLOR
)

INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR})
ADD_LIBRARY(libtest test.cpp)
TARGET_LINK_LIBRARIES(libtest PUBLIC ${pkgs_LDFLAGS} -ldl)
