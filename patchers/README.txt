Patcher for Detective Conan - Legacy of the British Empire
==========================================================

This patcher patches Detective Conan - Legacy of the British Empire with an English Translation.
It produces the file CONAN_PS2_ENGLISH_PATCHED_1.0.0.iso (sha1sum: f0d5f07f74d2357c3da174fa5d43c671489b269f)

English translation v1.0.0

Prerequisites
-------------

- ISO dump of the original game disc (sha1sum: 0b083120da3565d649f3e27c328f89c33a9c05c1)
- More than 1 GB of memory (for decompression)
- More than 4 GB available disk space (for temporary files and resulting file)

Windows: you do not need anything special. 7zip and zstd are provided for your convenience in `patching_utils`.
Linux: you need zstd. Install it using your package manager.

How to use this patcher
-----------------------

Windows:
  Drag and drop your CONAN ISO file onto WINDOWS_DROP_CONAN_PS2_ISO_HERE.bat.
  The patched file "CONAN_PS2_ENGLISH_PATCHED_1.0.0.iso" will appear in this directory.
  Alternative: Manual patching using command line
    .\WINDOWS_DROP_CONAN_PS2_ISO_HERE.bat conan.iso

Linux:
  Drag and drop your CONAN ISO file onto LINUX_DROP_CONAN_PS2_ISO_HERE.sh.
  LINUX_DROP_CONAN_PS2_ISO_HERE.sh must have executable permission (chmod +x LINUX_DROP_CONAN_PS2_ISO_HERE.sh).
  The patched file "CONAN_PS2_ENGLISH_PATCHED_1.0.0.iso" will appear in this directory.
  Alternative: Manual patching using command line
    bash LINUX_DROP_CONAN_PS2_ISO_HERE.sh conan.iso

For more information and credits, please visit https://github.com/conan-patches/ps2
