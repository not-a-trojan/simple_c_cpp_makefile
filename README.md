# Simple [`Makefile`](Makefile) for your C and C++ Projects
1. Copy the makefile to your project's base directory
2. Configure `INC_DIRS` and `SRC_DIRS` in the makefile
3. Run `make`

As simple as it should be :)

These 3 steps will provide you with a fully optimized release build and a separate debug-optimized debug build with address sanitizers (by default).

The [`Makefile`](Makefile) comes with a dedicated configuration section, but the default options should be perfectly fine for most small projects.

<details><summary> Changelog </summary>

### v1.3:
* Added option for autorun after build
* Binaries are now simply called 'debug' and 'release' by default
* Shortened readme
* Minor cleanup
* Improved documentation

### v1.2:
* Added support for multiple include and source directories (simply list them separated by space)
* Non-verbose mode now prints full relative paths
* Fixed bug that resulted in different behavior when switching from non-verbose to verbose mode (V=0 --> V=1)
* Added `-Wshadow` to default flags
* Improved documentation

### v1.1:
* Added the option to set the debug and release build directories to the same directory.\
In that case, the output binaries are suffixed with "_debug" and "_release".

### v1.0:
* Initial release
</details>
