# Makefile for Windows - Use with MinGW or Visual Studio nmake
# For MinGW: mingw32-make
# For Visual Studio: nmake

# Detect architecture
!IF "$(VSCMD_ARG_TGT_ARCH)" == "x86"
ARCH = x86
FTDI_ARCH = i386
!ELSEIF "$(VSCMD_ARG_TGT_ARCH)" == "x64"
ARCH = x64
FTDI_ARCH = amd64
!ELSEIF "$(Platform)" == "x86"
ARCH = x86
FTDI_ARCH = i386
!ELSEIF "$(Platform)" == "x64"
ARCH = x64
FTDI_ARCH = amd64
!ELSE
# Default to x64
ARCH = x64
FTDI_ARCH = amd64
!ENDIF

!MESSAGE Building for $(ARCH) architecture

# Compiler selection
!IFDEF USE_MINGW
CC = gcc
CFLAGS = -Wall -O2 -DFORWIN
LDFLAGS = 
OBJEXT = .o
EXEEXT = .exe
RM = del /Q
!ELSE
# Visual Studio
CC = cl
CFLAGS = /W3 /O2 /DFORWIN /D_CRT_SECURE_NO_WARNINGS
LDFLAGS = /link
OBJEXT = .obj
EXEEXT = .exe
RM = del /Q
!ENDIF

# FTDI D2XX library paths - using local ftdilib folder
FTDI_DIR = ftdilib
FTDI_INCLUDE = $(FTDI_DIR)
FTDI_LIB = $(FTDI_DIR)\$(FTDI_ARCH)\ftd2xx.lib

# For MinGW, you might need to use the .a import library instead:
# FTDI_LIB = $(FTDI_DIR)\$(FTDI_ARCH)\ftd2xx.a

# Include paths
INCLUDES = -I. -I$(FTDI_INCLUDE)

# Libraries
!IFDEF USE_MINGW
LIBS = -L$(FTDI_DIR)\amd64 -lftd2xx -lws2_32
!ELSE
LIBS = $(FTDI_LIB) ws2_32.lib
!ENDIF

# Object files
LIBXSVF_OBJS = \
	memname$(OBJEXT) \
	play$(OBJEXT) \
	scan$(OBJEXT) \
	statename$(OBJEXT) \
	svf$(OBJEXT) \
	tap$(OBJEXT) \
	xsvf$(OBJEXT)

XSVFTOOL_OBJS = \
	xsvfplay_ftd2xx$(OBJEXT) \
	$(LIBXSVF_OBJS)

# Targets
all: check-ftdilib xsvftool-ftd2xx$(EXEEXT)

check-ftdilib:
!IF !EXIST(ftdilib\ftd2xx.h)
	@echo ERROR: ftdilib\ftd2xx.h not found!
	@echo Please create ftdilib folder and copy FTDI D2XX files.
	@exit 1
!ENDIF

xsvftool-ftd2xx$(EXEEXT): $(XSVFTOOL_OBJS)
!IFDEF USE_MINGW
	$(CC) $(CFLAGS) -o $@ $(XSVFTOOL_OBJS) $(LIBS)
!ELSE
	$(CC) $(CFLAGS) $(XSVFTOOL_OBJS) /Fe$@ $(LDFLAGS) $(LIBS)
!ENDIF

# Compilation rules
!IFDEF USE_MINGW
.c$(OBJEXT):
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@
!ELSE
.c$(OBJEXT):
	$(CC) $(CFLAGS) $(INCLUDES) /c $< /Fo$@
!ENDIF

# Dependencies
xsvfplay_ftd2xx$(OBJEXT): xsvfplay_ftd2xx.c libxsvf.h
memname$(OBJEXT): memname.c libxsvf.h
play$(OBJEXT): play.c libxsvf.h
scan$(OBJEXT): scan.c libxsvf.h
statename$(OBJEXT): statename.c libxsvf.h
svf$(OBJEXT): svf.c libxsvf.h
tap$(OBJEXT): tap.c libxsvf.h
xsvf$(OBJEXT): xsvf.c libxsvf.h

# Clean
clean:
	-$(RM) *.obj *.o xsvftool-ftd2xx.exe

# Install target (optional)
install:
	@echo Copy xsvftool-ftd2xx.exe to your desired location
	@echo Don't forget to have ftd2xx.dll in your PATH or in the same directory

.PHONY: all clean install check-ftdilib