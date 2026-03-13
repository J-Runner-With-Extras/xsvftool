# LibXSVF Windows Port

This is a Windows port of the LibXSVF JTAG SVF/XSVF player for FTDI chips.

## Build Files Included


- `build_x86.bat` - Explicitly builds 32-bit version 
- `build_x64.bat` - Explicitly builds 64-bit version
- `Makefile` - For manual nmake builds

## Prerequisites

1. **LibUSB + FTDI D2XX Drivers and Library**
   - Download from: https://ftdichip.com/drivers/d2xx-drivers/
   - Download from: https://github.com/libusb/libusb/releases
   - Install the CDM drivers
   - Create a `ftdilib` folder in your project directory
   - Copy these files from the CDM package into `ftdilib`:
     - `ftd2xx.h` (and `WinTypes.h` if present)
     - `i386` folder (for 32-bit builds)
     - `amd64` folder (for 64-bit builds)

2. **Compiler** (one of the following):
   - Visual Studio (any recent version) with C++ support
   - MinGW-w64 (recommended: https://www.mingw-w64.org/)
   - MSYS2 with mingw-w64 toolchain

## Building

### Important: Architecture Matching

**You MUST match the architecture of:**
1. The FTDI library (i386 = 32-bit, amd64 = 64-bit)
2. Your compiler target (x86 = 32-bit, x64 = 64-bit)
3. The ftd2xx.dll at runtime

### Quick Build (Auto-detect architecture)

1. Ensure you have the `ftdilib` folder set up with the FTDI libraries
2. Run the correct batch file from the appropriate Visual Studio command prompt:
   - For 32-bit: Use "x86 Native Tools Command Prompt for VS"
   - For 64-bit: Use "x64 Native Tools Command Prompt for VS"

### Manual Build with Visual Studio

For 32-bit:
1. Open "x86 Native Tools Command Prompt for VS"
2. Navigate to the source directory
3. Run: `nmake /f Makefile`

For 64-bit:
1. Open "x64 Native Tools Command Prompt for VS"
2. Navigate to the source directory
3. Run: `nmake /f Makefile`

### Manual Build with MinGW

1. Open a command prompt
2. Navigate to the source directory
3. Run:
   ```cmd
   mingw32-make USE_MINGW=1
   ```

## Changes Made for Windows Port

1. **Threading**: Disabled pthread-based background reading (can be re-enabled with Windows threads if needed)
2. **Time Functions**: Added Windows implementations for `gettimeofday()` and `usleep()`
3. **getopt**: Added a simple getopt implementation for command-line parsing
4. **File I/O**: Set binary mode for stdin/stdout to handle binary files correctly
5. **Headers**: Replaced Unix-specific headers with Windows equivalents
6. **Control Port**: Was removed entirely as it's not needed for J-Runner functionality

## Usage

The usage is the same as the Linux version:

```cmd
xsvftool-ftd2xx.exe -s file.svf        # Play SVF file
xsvftool-ftd2xx.exe -x file.xsvf       # Play XSVF file
xsvftool-ftd2xx.exe -c                 # Scan JTAG chain
xsvftool-ftd2xx.exe -l                 # List FTDI devices
```

Common options:
- `-v` : Verbose output (repeat for more verbosity)
- `-f 1M` : Set frequency to 1 MHz
- `-p` : Show progress
- `-J "Device Name"` : Specify JTAG port by name
- `-j 0` : Specify JTAG port by index

## Troubleshooting

1. **"library machine type 'x64' conflicts with target machine type 'x86'"**
   - You're mixing 32-bit and 64-bit components
   - Solution: Use the correct Visual Studio command prompt:
     - For 32-bit: "x86 Native Tools Command Prompt"
     - For 64-bit: "x64 Native Tools Command Prompt"
   - Make sure the FTDI library matches (i386 for 32-bit, amd64 for 64-bit)

2. **"FTDI device not found"**
   - Ensure FTDI drivers are installed
   - Check device name with `-l` option
   - Try running as Administrator

3. **"ftd2xx.dll not found"**
   - Copy the correct ftd2xx.dll to the same directory as the .exe:
     - For 32-bit exe: use 32-bit ftd2xx.dll
     - For 64-bit exe: use 64-bit ftd2xx.dll
   - Or add the FTDI driver directory to your PATH

4. **Build errors**
   - Verify the `ftdilib` folder exists and contains the required files
   - Ensure you have the correct architecture (x64/x86) libraries
   - Check that `ftd2xx.h` is in the `ftdilib` folder

## Performance Notes

- The Windows port has background reading disabled by default
- For better performance with large files, consider enabling BLOCK_WRITE in the source
- Synchronous mode (`-S`) is more reliable but slower

## Known Limitations

1. Background reading with threads is not implemented (can be added using Windows threads)
2. Some timing precision may be reduced compared to Linux
3. USB performance may vary depending on Windows USB driver stack
