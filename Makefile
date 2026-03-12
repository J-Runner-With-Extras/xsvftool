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

# DirtyJTAG object files (Windows nmake target uses libusb-1.0)
DIRTYJTAG_OBJS = \
	xsvfplay_dirtyjtag$(OBJEXT) \
	$(LIBXSVF_OBJS)

# libusb-1.0 paths - using local VS2022 folder (MS32 for x86, MS64 for x64)
LIBUSB_DIR = VS2022
LIBUSB_INCLUDE = include
!IF "$(ARCH)" == "x86"
LIBUSB_ARCH = MS32
!ELSE
LIBUSB_ARCH = MS64
!ENDIF

# Libraries for DirtyJTAG build (requires libusb-1.0)
!IFDEF USE_MINGW
DIRTYJTAG_LIBS = -L$(LIBUSB_DIR)\$(LIBUSB_ARCH)\dll -lusb-1.0
!ELSE
DIRTYJTAG_LIBS = $(LIBUSB_DIR)\$(LIBUSB_ARCH)\dll\libusb-1.0.lib
!ENDIF

LIBUSB_INCLUDES = /I$(LIBUSB_INCLUDE)

# Combined single-exe object files
COMBINED_OBJS = \
	xsvftool$(OBJEXT) \
	$(LIBXSVF_OBJS)

# Targets
# 'all' builds the combined tool + both standalone tools
all: check-ftdilib xsvftool$(EXEEXT) xsvftool-ftd2xx$(EXEEXT) xsvftool-dirtyjtag$(EXEEXT)

# Build only the combined tool (requires both ftdilib and libusb)
combined: check-ftdilib xsvftool$(EXEEXT)

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

xsvftool-dirtyjtag$(EXEEXT): $(DIRTYJTAG_OBJS)
!IFDEF USE_MINGW
	$(CC) $(CFLAGS) -o $@ $(DIRTYJTAG_OBJS) $(DIRTYJTAG_LIBS)
!ELSE
	$(CC) $(CFLAGS) $(DIRTYJTAG_OBJS) /Fe$@ $(LDFLAGS) $(DIRTYJTAG_LIBS)
!ENDIF

xsvftool$(EXEEXT): $(COMBINED_OBJS)
!IFDEF USE_MINGW
	$(CC) $(CFLAGS) -o $@ $(COMBINED_OBJS) $(LIBS) $(DIRTYJTAG_LIBS)
!ELSE
	$(CC) $(CFLAGS) $(COMBINED_OBJS) /Fe$@ $(LDFLAGS) $(LIBS) $(DIRTYJTAG_LIBS)
!ENDIF

# Build only the DirtyJTAG standalone tool (no ftdilib required)
dirtyjtag: xsvftool-dirtyjtag$(EXEEXT)

# Compilation rules (inference rules for shared libxsvf sources)
!IFDEF USE_MINGW
.c$(OBJEXT):
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@
!ELSE
.c$(OBJEXT):
	$(CC) $(CFLAGS) $(INCLUDES) /c $< /Fo$@
!ENDIF

# Explicit rules for the two main files so their unique flags are always applied.
# The DirtyJTAG file needs -DDIRTYJTAG_STANDALONE to emit main(); this cannot
# be left to the generic inference rule which has no way to add per-file flags.
!IFDEF USE_MINGW
xsvfplay_ftd2xx$(OBJEXT): xsvfplay_ftd2xx.c libxsvf.h
	$(CC) $(CFLAGS) $(INCLUDES) -c xsvfplay_ftd2xx.c -o xsvfplay_ftd2xx$(OBJEXT)

xsvfplay_dirtyjtag$(OBJEXT): xsvfplay_dirtyjtag.c libxsvf.h
	$(CC) $(CFLAGS) -I. $(LIBUSB_INCLUDES) -DDIRTYJTAG_STANDALONE -c xsvfplay_dirtyjtag.c -o xsvfplay_dirtyjtag$(OBJEXT)

xsvftool$(OBJEXT): xsvftool.c xsvfplay_ftd2xx.c xsvfplay_dirtyjtag.c libxsvf.h
	$(CC) $(CFLAGS) $(INCLUDES) $(LIBUSB_INCLUDES) -DCOMBINED_BUILD -c xsvftool.c -o xsvftool$(OBJEXT)
!ELSE
xsvfplay_ftd2xx$(OBJEXT): xsvfplay_ftd2xx.c libxsvf.h
	$(CC) $(CFLAGS) $(INCLUDES) /c xsvfplay_ftd2xx.c /Foxsvfplay_ftd2xx$(OBJEXT)

xsvfplay_dirtyjtag$(OBJEXT): xsvfplay_dirtyjtag.c libxsvf.h
	$(CC) $(CFLAGS) /I. $(LIBUSB_INCLUDES) /DDIRTYJTAG_STANDALONE /c xsvfplay_dirtyjtag.c /Foxsvfplay_dirtyjtag$(OBJEXT)

xsvftool$(OBJEXT): xsvftool.c xsvfplay_ftd2xx.c xsvfplay_dirtyjtag.c libxsvf.h
	$(CC) $(CFLAGS) $(INCLUDES) $(LIBUSB_INCLUDES) /DCOMBINED_BUILD /c xsvftool.c /Foxsvftool$(OBJEXT)
!ENDIF

# Dependencies for shared libxsvf sources
memname$(OBJEXT): memname.c libxsvf.h
play$(OBJEXT): play.c libxsvf.h
scan$(OBJEXT): scan.c libxsvf.h
statename$(OBJEXT): statename.c libxsvf.h
svf$(OBJEXT): svf.c libxsvf.h
tap$(OBJEXT): tap.c libxsvf.h
xsvf$(OBJEXT): xsvf.c libxsvf.h

# Clean
clean:
	-$(RM) *.obj *.o xsvftool-ftd2xx.exe xsvftool-dirtyjtag.exe xsvftool.exe

# Install target (optional)
install:
	@echo Copy xsvftool-ftd2xx.exe and xsvftool-dirtyjtag.exe to your desired location
	@echo For FTDI: ensure ftd2xx.dll is in the same directory or on PATH
	@echo For DirtyJTAG: ensure libusb-1.0.dll is in the same directory or on PATH