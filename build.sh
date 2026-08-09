# assembler
ASM=/usr/bin/nasm
# compiler
CC=/usr/bin/gcc
# linker
LD=/usr/bin/ld

main() {
    # load the config file

    # create libc 32-bit and 64-bit for all rings
    compile libc libc32R0.o --bin-target --no-libc -32 -R0
    compile libc libc32R1.o --bin-target --no-libc -32 -R1
    compile libc libc32R2.o --bin-target --no-libc -32 -R2
    compile libc libc32R3.o --bin-target --no-libc -32
    compile libc libc64R0.o --bin-target --no-libc -R0
    compile libc libc64R1.o --bin-target --no-libc -R1
    compile libc libc64R2.o --bin-target --no-libc -R2
    compile libc libc64R3.o --bin-target --no-libc

    # important boot systems and drivers
    compile loader32 system/boot/sysldr.exc -32 -R0
    grub-file --is-x86-multiboot disk/system/boot/sysldr.exc

    #exit 1

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
    ASM_FLAGS=""
    # compiler flags
    CC_FLAGS="-I./inc/std -std=gnu99 -ffreestanding -Wall -Wextra -nostdinc"
    # linker flags
    LD_FLAGS="-T $LINKER -nostdlib"

    # break flag
    BREAK_FLAG=0

    # 32 bit flag
    LONG_MODE_FLAG=1
    # value of the protection rings
    RING_ACCESS="3"
    # use libc headers
    USE_LIBH=1
    # use libc
    USE_LIBC=1

    echo "[ Creating $(echo $TARGET | sed 's|.*/||') ]"

    # goes through the parameters
    if [ ! $# -lt 3 ]; then
        for arg in "${@:3}"; do
            if [ $arg == "-32" ]; then
                LONG_MODE_FLAG=0
            elif [[ "$arg" =~ ^-R([0-2])$ ]]; then
                if [ "$RING_ACCESS" != "3" ]; then
                    fail "Ring was already set"
                fi

                RING_ACCESS="${BASH_REMATCH[1]}"
            elif [ $arg == "--bin-target" ]; then
                LD_FLAGS="-r $LD_FLAGS"
                TARGET=./bin/$2
            elif [ $arg == "--no-libh" ]; then
                USE_LIBh=0
            elif [ $arg == "--no-libc" ]; then
                USE_LIBC=0
            else
                fail "$arg is not defined"
            fi
        done
    fi

    # change compiler/assembler/linker flags depending on the arguements
    if [ $LONG_MODE_FLAG -eq 1 ]; then
        ASM_FLAGS="-f elf64 $ASM_FLAGS"
        CC_FLAGS="$CC_FLAGS -m64"
        LD_FLAGS="-m elf_x86_64 $LD_FLAGS"
    else
        ASM_FLAGS="-f elf32 $ASM_FLAGS"
        CC_FLAGS="$CC_FLAGS -m32"
        LD_FLAGS="-m elf_i386 $LD_FLAGS"
    fi

    # sets the protection value of the build
    ASM_FLAGS="$ASM_FLAGS -D__ring__=$RING_ACCESS"
    CC_FLAGS="$CC_FLAGS -D__ring__=$RING_ACCESS"

    # adds libc headers
    if [ $USE_LIBH -eq 1 ]; then
        CC_FLAGS="-I./inc/loader $CC_FLAGS"
    fi

    # compiles all of the files for the directory
    while read FILE; do
        FIXED_FILE=${FILE#./}
        echo "[ Compiling '$(echo $FILE | sed 's|.*/||')' for '$(echo $TARGET | sed 's|.*/||')' ]" 
        OUT_NAME=$(printf '%s\n' "$FIXED_FILE" | sed 's/\.c$//' | tr '/' '_');
        $CC $CC_FLAGS -c "$FILE" -o "bin/$OUT_NAME.o" || BREAK_FLAG=1;
    done < <(find $SRC -type f -name "*.c")

    # assembles all of the files for the directory
    while read FILE; do
        FIXED_FILE=${FILE#./}
        echo "[ Assembling '$(echo $FILE | sed 's|.*/||')' for '$(echo $TARGET | sed 's|.*/||')' ]" 
        OUT_NAME=$(printf '%s\n' "$FIXED_FILE" | sed 's/\.asm$//' | tr '/' '_');
        $ASM $ASM_FLAGS "$FILE" -o "bin/$OUT_NAME.o" || BREAK_FLAG=1;
    done < <(find $SRC -type f -name "*.asm")

    if [ $BREAK_FLAG -eq 1 ]; then
        fail "Compilation failure"
    fi

    # link the object files
    echo "[ linking '$(echo $TARGET | sed 's|.*/||')' ]"
    OBJECTS=$(find bin/ -name "$(printf '%s\n' "${SRC#./}" | tr '/' '_')"*.o)

    # adds libc unless requested otherwise
    if [ $USE_LIBC -eq 1 ]; then
        BASE="./bin/libc"

        if [ $LONG_MODE_FLAG -eq 1 ]; then
            BASE="${BASE}64R${RING_ACCESS}.o"
        else
            BASE="${BASE}32R${RING_ACCESS}.o"
        fi

        OBJECTS="$BASE $OBJECTS"
    fi

	$LD $LD_FLAGS -o $TARGET $OBJECTS || fail "Linking failure";
    
    # done
    echo "[ done ]"
    echo
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
    echo "SCRIPT ERROR: $@"
    echo "Exiting..."
    exit 1
}

# doing this for the sake of organization
main
