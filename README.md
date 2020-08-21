<h1 align="center">PentiumOS</h1>

<div align="center">
    A simple kernel written in assembly
</div>

## Features
- Basic input
- Colour support

## Prerequisites

Arch:
```sh
$ sudo pacman -S qemu
$ pamac install nasm
```

Ubuntu:
```sh
$ sudo apt-get install qemu-system nasm
```

Windows:
[QEMU](https://www.qemu.org/download/#windows)
[NASM](https://www.nasm.us/pub/nasm/releasebuilds/?C=M;O=D)

## Running

```sh
$ nasm -f bin main.asm -o out/pentiumos.bin
$ qemu-system-x86_64 out/pentiumos.bin
```