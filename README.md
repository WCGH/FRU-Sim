# FRU-Sim

This is a solo/offline sim for FRU. It is currently in development and has modules for Light Rampant, Ultimate Relativity, Sextuple Apocalypse, Darklit Dragonsong, Crystallize Time and Phase 5.

If you have any questions, feel free to join us on [Discord](https://discord.gg/P9adFHADrX).


## Instructions
To download the sim, head to the ⁠[releases](https://github.com/WCGH/FRU-Sim/releases) page and download the latest zip file. Unzip and run fru_sim.exe.

## Building

FRU-Sim is a Godot 4.3 project. It does not contain native C/C++ sources, so there is no CMake or clang build target in this repository.

### Windows

Use the existing Windows Desktop export presets from Godot 4.3.

### macOS

Use Godot 4.3 with the official export templates installed, then export the `macOS` preset:

```sh
godot --headless --path . --export-release macOS builds/macos/fru_sim_macos.zip
```

The macOS preset exports a universal app bundle with a macOS 15.0 minimum version.


## Known Issues:
- The sim may not run on some laptop or Intel GPU's. Let me know if this is the case for you and I can send you a version that may work.
- Characters sometimes get stuck running in place.
- Crystallize Time: bots will sometimes get hit by waves or fail to find their soaks.
- UI Elements can get pushed off screen when changing window sizes/resolutions (Use Reset UI button).
