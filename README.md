# Simple [`Makefile`](Makefile) for your C and C++ Projects
1. Copy the makefile to your project's base directory
2. Adjust the "GLOBAL CONFIGURATION" section in the makefile
3. Run `make`

As simple as it should be :)

The [`Makefile`](Makefile) comes with two premade build configurations, `debug` and `release`.
It supports adding arbitrary additional configurations in the "BUILD CONFIGURATIONS" section.
Simply run `make <config name>` to build the respective config.
Add `V=1` to run in verbose mode.

<details><summary> Changelog </summary>

### v2.0:
* Added support for arbitrary build configurations
* Added option to configure source file extensions
* Updated premade configurations

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
