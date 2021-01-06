# Simple Makefile for your C and C++ Projects
You want to start a new C or C++ project without complicated dependencies? \
You quickly want to prototype some C or C++ code?

But you want to avoid the pain of setting up one of the many build systems out there?

Well, look no further! This plug-n-play Makefile is perfect for you!

## Setup
1. Copy the makefile to your project's base directory
2. Place all your source files in a folder `src` (configurable in the makefile)
3. Place all your header files in a folder `include` (configurable in the makefile)
4. Run `make`

As simple as it should be :)

These 4 steps will provide you with a fully optimized release build and a separate debug-optimized debug build with address sanitizers (by default).

## Configuration
Of course you can adjust all options etc comfortably.\
Right at the beginning of the Makefile is a commented configuration section, where you can easily set compiler options etc.

The default options should be perfectly fine for most small projects though.


## Changelog
### 06.01.2021
* Added support for multiple include and source directories (simply list them separated by space)
* Non-verbose mode now prints full relative paths
* Fixed bug that resulted in different behavior when switching from non-verbose to verbose mode (V=0 --> V=1)
* Added `-Wshadow` to default flags
* Improved documentation

### 27.11.2020
* Added the option to set the debug and release build directories to the same directory.\
In that case, the output binaries are suffixed with "_debug" and "_release".

### 25.11.2020
* Initial release
