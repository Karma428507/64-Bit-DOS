main() {
    # handle different arguements
    for arg in "$@"; do
        echo "$arg"
    done

    compile kernel system/sys32/kernel.exc
    grub-file --is-x86-multiboot disk/system/sys32/kernel.exc

    disk_create
    install_disk
    emulate
}

compile() {
    # assembler
    ASM=/usr/bin/nasm
    # compiler
    CC=/usr/bin/gcc
    # linker
    LD=/usr/bin/ld
    
    # source directory
    SRC=./src/$1
    # linker file
    LINKER=./src/linker/$1.ld
    # target file
    TARGET=./disk/$2

    # assembler flags
    ASM_FLAGS="-f elf32"
    # compiler flags
    CC_FLAGS="-I./inc -m32 -std=gnu99 -ffreestanding -Wall -Wextra"
    # linker flags
    LD_FLAGS="-m elf_i386 -T $LINKER -nostdlib"

    # compiles all of the files for the directory
    find $SRC -type f -name "*.c" | while read FILE; do
        FIXED_FILE=${FILE#./}
        echo "[ Compiling '$(echo $FILE | sed 's|.*/||')' for '$(echo $TARGET | sed 's|.*/||')' ]" 
        OUT_NAME=$(printf '%s\n' "$FIXED_FILE" | sed 's/\.c$//' | tr '/' '_');
        echo $OUT_NAME
        $CC $CC_FLAGS -c "$FILE" -o "bin/$OUT_NAME.o"
    done

    # assembles all of the files for the directory
    find $SRC -type f -name "*.asm" | while read FILE; do
        FIXED_FILE=${FILE#./}
        echo "[ Assembling '$(echo $FILE | sed 's|.*/||')' for '$(echo $TARGET | sed 's|.*/||')' ]" 
        OUT_NAME=$(printf '%s\n' "$FIXED_FILE" | sed 's/\.asm$//' | tr '/' '_');
        echo $OUT_NAME
        $ASM $ASM_FLAGS "$FILE" -o "bin/$OUT_NAME.o"
    done

    # links the object files
    OBJECTS=$(find bin/ -name "$(printf '%s\n' "${SRC#./}" | tr '/' '_')"*.o)
    echo "[ linking '$(echo $TARGET | sed 's|.*/||')' ]"
	$LD $LD_FLAGS -o $TARGET $OBJECTS
}

disk_create() {
    # create a new disk with a bootable partition
    rm bin/disk.img
    dd if=/dev/zero of=bin/disk.img bs=1M count=91
    (echo n; echo p; echo 1; echo ""; echo ""; echo a; echo 1; echo w;) | fdisk bin/disk.img
}

install_disk() {
    # create the mounting space
    sudo losetup -D
    sudo losetup /dev/loop0 bin/disk.img
    sudo losetup /dev/loop1 bin/disk.img -o 1048576
    sudo mke2fs /dev/loop1

    # create mounting directory
    mkdir mnt
    sudo mount /dev/loop1 mnt
    sudo cp -r disk/. mnt

    # install grub
    sudo grub-install --modules="biosdisk part_msdos ext2 multiboot configfile" \
        --boot-directory=mnt/system/boot --target=i386-pc \
        /dev/loop0

    # remove mounting directory
    sudo umount mnt
    rmdir mnt

    sudo losetup -D
}

emulate() {
    qemu-system-x86_64 \
        -drive id=disk,file=bin/disk.img,if=none \
        -device ahci,id=ahci \
        -device ide-hd,drive=disk,bus=ahci.0 \
        -audiodev pa,id=Sound \
        -device intel-hda \
        -device hda-duplex,audiodev=Sound
}

# doing this for the sake of organization
main $@