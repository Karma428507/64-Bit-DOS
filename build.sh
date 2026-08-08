# assembler
ASM=/usr/bin/nasm
# compiler
CC=/usr/bin/gcc
# linker
LD=/usr/bin/ld

FAIL_REASON="unknown"

main() {
    # handle different arguements
    for arg in "$@"; do
        echo "$arg"
    done

    # Compile libc for 32-bit R0, 64-bit R0 and 64-bit R>0

    compile loader32 system/boot/sysldr.exc -32 -Dk || fail;
    grub-file --is-x86-multiboot disk/system/boot/sysldr.exc

    disk_create
    install_disk
    emulate
}

compile() {
    # source directory
    SRC=./src/$1
    # linker file
    LINKER=./src/linker/$1.ld
    # target file
    TARGET=./disk/$2

    # assembler flags
    ASM_FLAGS="-f elf32"
    # compiler flags
    CC_FLAGS="-I./inc/std -I./inc/loader -m32 -std=gnu99 -ffreestanding -Wall -Wextra -nostdinc -D__kernel__"
    # linker flags
    LD_FLAGS="-m elf_i386 -T $LINKER -nostdlib"

    # break flag
    BREAK_FLAG=0

    echo $#

    if [ ! $# -lt 3 ]; then
        #for i
        echo debug
    fi

    #CC_FLAGS="$CC_FLAGS "

    # compiles all of the files for the directory
    while read FILE; do
        FIXED_FILE=${FILE#./}
        echo "[ Compiling '$(echo $FILE | sed 's|.*/||')' for '$(echo $TARGET | sed 's|.*/||')' ]" 
        OUT_NAME=$(printf '%s\n' "$FIXED_FILE" | sed 's/\.c$//' | tr '/' '_');
        $CC $CC_FLAGS -c "$FILE" -o "bin/$OUT_NAME.o" || BREAK_FLAG=1;
        echo
    done < <(find $SRC -type f -name "*.c")

    # assembles all of the files for the directory
    while read FILE; do
        FIXED_FILE=${FILE#./}
        echo "[ Assembling '$(echo $FILE | sed 's|.*/||')' for '$(echo $TARGET | sed 's|.*/||')' ]" 
        OUT_NAME=$(printf '%s\n' "$FIXED_FILE" | sed 's/\.asm$//' | tr '/' '_');
        $ASM $ASM_FLAGS "$FILE" -o "bin/$OUT_NAME.o" || { BREAK_FLAG=1; };
        echo
    done < <(find $SRC -type f -name "*.asm")

    if [ $BREAK_FLAG -eq 1 ]; then
        echo "[ Stopping script... ]"
        return 1
    fi

    # links the object files
    OBJECTS=$(find bin/ -name "$(printf '%s\n' "${SRC#./}" | tr '/' '_')"*.o)
    echo "[ linking '$(echo $TARGET | sed 's|.*/||')' ]"
	$LD $LD_FLAGS -o $TARGET $OBJECTS || return 1;
}

disk_create() {
    # create a new disk with a bootable partition
    rm bin/disk.img
    dd if=/dev/zero of=bin/disk.img bs=1M count=91
    (echo n; echo p; echo 1; echo ""; echo ""; echo a; echo w;) | fdisk bin/disk.img
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

clean() {
    echo "[ Cleaning ]"
}

fail() {
    echo "SCRIPT ERROR: $FAIL_REASON"
    echo "Exiting..."
    exit 1
}

# doing this for the sake of organization
main $@