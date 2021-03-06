#!/bin/bash

longusage() {
  echo "Gentoo Linux Genkernel ${GK_V}"
  echo "Usage: "
  echo "  genkernel [options] action"
  echo
  echo "Available Actions: "
  echo "  all    Build all steps"
  echo "  kernel   Build only the kernel and modules"
  echo "  initrd   Build only the initrd"
  echo
  echo "Available Options: "
  echo "  Debug settings"
  echo " --debuglevel=<0-5> Debug Verbosity Level"
  echo " --debugfile=<outfile> Output file for debug info"
  echo " --color   Output debug in color"
  echo " --no-color  Do not output debug in color"
  echo "  Kernel Configuration settings"
  echo " --menuconfig  Run menuconfig after oldconfig"
  echo " --no-menuconfig  Do not run menuconfig after oldconfig"
  echo " --gconfig  Run gconfig after oldconfig"
  echo " --xconfig  Run xconfig after oldconfig"
  echo " --save-config  Save the configuration to /etc/kernels"
  echo " --no-save-config Don't save the configuration to /etc/kernels"
  echo "  Kernel Compile settings"
  echo " --clean   Run make clean before compilation"
  echo " --mrproper  Run make mrproper before compilation"
  echo " --no-clean  Do not run make clean before compilation"
  echo " --no-mrproper  Do not run make mrproper before compilation"
  echo " --oldconfig  Implies --no-clean and runs a 'make oldconfig'"
  echo " --bootsplash  Install bootsplash support to the initrd"
  echo " --no-bootsplash  Do not use bootsplash"
  echo " --gensplash  Install gensplash support into bzImage"
  echo " --no-gensplash  Do not use gensplash"
  echo " --install  Install the kernel after building"
  echo " --no-install  Do not install the kernel after building"
  echo " --no-initrdmodules Don't copy any modules to the initrd"
  echo " --udev   Enables udev support in your initrd"
  echo " --no-udev  Disable udev support"
  echo " --callback=<...> Run the specified arguments after the"
  echo "    kernel and modules have been compiled"
  echo " --postconf=<...> Run the specified arguments after"
  echo "    the kernel has been configured"
  echo "  Kernel settings"
  echo " --kerneldir=<dir> Location of the kernel sources"
  echo " --kernel-config=<file> Kernel configuration file to use for compilation"
  echo " --module-prefix=<dir> Prefix to kernel module destination, modules will"
  echo "    be installed in <prefix>/lib/modules"
  echo "  Low-Level Compile settings"
  echo " --kernel-cc=<compiler> Compiler to use for kernel (e.g. distcc)"
  echo " --kernel-as=<assembler> Assembler to use for kernel"
  echo " --kernel-ld=<linker> Linker to use for kernel"
  echo " --kernel-make=<makeprg> GNU Make to use for kernel"
  echo " --utils-cc=<compiler> Compiler to use for utilities"
  echo " --utils-as=<assembler> Assembler to use for utils"
  echo " --utils-ld=<linker> Linker to use for utils"
  echo " --utils-make=<makeprog> GNU Make to use for utils"
  echo " --makeopts=<makeopts> Make options such as -j2, etc..."
  echo " --mountboot  Mount /boot automatically"
  echo " --no-mountboot  Don't mount /boot automatically"  
  echo "  Initialization"
  echo " --bootsplash=<theme> Force bootsplash using <theme>"
  echo " --gensplash=<theme> Force gensplash using <theme>"
  echo " --do-keymap-auto Forces keymap selection at boot"
  echo " --evms2   Include EVMS2 support"
  echo "     --> 'emerge evms' in the host operating system first"
  echo " --lvm2   Include LVM2 support"
  echo " --bootloader=grub Add new kernel to GRUB configuration"
  echo " --linuxrc=<file> Specifies a user created linuxrc"
  echo "  Internals"
  echo " --arch-override=<arch> Force to arch instead of autodetect"
  echo " --cachedir=<dir> Override the default cache location"
  echo " --tempdir=<dir>  Location of Genkernel's temporary directory"
  echo "  Output Settings"
  echo "        --minkernpackage=<tbz2> File to output a .tar.bz2'd kernel and initrd:"
  echo "                                No modules outside of the initrd will be"
  echo "                                included..."
}

usage() {
  echo "Gentoo Linux Genkernel ${GK_V}"
  echo "Usage: "
  echo " genkernel [options] all"
  echo
  echo 'Some useful options:'
  echo ' --menuconfig  Run menuconfig after oldconfig'
  echo ' --no-clean  Do not run make clean before compilation'
  echo ' --no-mrproper  Do not run make mrproper before compilation,'
  echo '    this is implied by --no-clean.'
  echo
  echo 'For a detailed list of supported options and flags; issue:'
  echo ' genkernel --help'
}

parse_opt() {
 case "$1" in
  *\=*)
   echo "$1" | cut -f2- -d=
  ;;
 esac
}

parse_cmdline() {
 case "$*" in
       --kernel-cc=*)
        CMD_KERNEL_CC=`parse_opt "$*"`
        print_info 2 "CMD_KERNEL_CC: $CMD_KERNEL_CC"
       ;;
       --kernel-ld=*)
        CMD_KERNEL_LD=`parse_opt "$*"`
        print_info 2 "CMD_KERNEL_LD: $CMD_KERNEL_LD"
       ;;
       --kernel-as=*)
        CMD_KERNEL_AS=`parse_opt "$*"`
        print_info 2 "CMD_KERNEL_AS: $CMD_KERNEL_AS"
       ;;
       --kernel-make=*)
        CMD_KERNEL_MAKE=`parse_opt "$*"`
        print_info 2 "CMD_KERNEL_MAKE: $CMD_KERNEL_MAKE"
       ;;
       --utils-cc=*)
        CMD_UTILS_CC=`parse_opt "$*"`
        print_info 2 "CMD_UTILS_CC: $CMD_UTILS_CC"
       ;;
       --utils-ld=*)
        CMD_UTILS_LD=`parse_opt "$*"`
        print_info 2 "CMD_UTILS_LD: $CMD_UTILS_LD"
       ;;
       --utils-as=*)
        CMD_UTILS_AS=`parse_opt "$*"`
        print_info 2 "CMD_UTILS_AS: $CMD_UTILS_AS"
       ;;
       --utils-make=*)
        CMD_UTILS_MAKE=`parse_opt "$*"`
        print_info 2 "CMD_UTILS_MAKE: $CMD_UTILS_MAKE"
       ;;
       --makeopts=*)
        CMD_MAKEOPTS=`parse_opt "$*"`
        print_info 2 "CMD_MAKEOPTS: $CMD_MAKEOPTS"
       ;;
       --mountboot)
        CMD_MOUNTBOOT=1
        print_info 2 "CMD_MOUNTBOOT: $CMD_MOUNTBOOT"
       ;;
       --no-mountboot)
        CMD_MOUNTBOOT=0
        print_info 2 "CMD_MOUNTBOOT: $CMD_MOUNTBOOT"
       ;;
       --do-keymap-auto)
        CMD_DOKEYMAPAUTO=1
        print_info 2 "CMD_DOKEYMAPAUTO: $CMD_DOKEYMAPAUTO"
       ;;
       --evms2)
        CMD_EVMS2=1
        print_info 2 'CMD_EVMS2: 1'
       ;;
       --lvm2)
        CMD_LVM2=1
        print_info 2 'CMD_LVM2: 1'
       ;;
       --bootloader=*)
        CMD_BOOTLOADER=`parse_opt "$*"`
        print_info 2 "CMD_BOOTLOADER: $CMD_BOOTLOADER"
       ;;
       --debuglevel=*)
        CMD_DEBUGLEVEL=`parse_opt "$*"`
        DEBUGLEVEL="${CMD_DEBUGLEVEL}"
        print_info 2 "CMD_DEBUGLEVEL: $CMD_DEBUGLEVEL"
       ;;
       --menuconfig)
        TERM_LINES=`stty -a | head -n 1 | cut -d\  -f5 | cut -d\; -f1`
        TERM_COLUMNS=`stty -a | head -n 1 | cut -d\  -f7 | cut -d\; -f1`

        if [[ TERM_LINES -lt 19 || TERM_COLUMNS -lt 80 ]]
        then
         echo "Error: You need a terminal with at least 80 columns"
         echo "       and 19 lines for --menuconfig; try --nomenuconfig..."
         exit 1
        fi
        CMD_MENUCONFIG=1
        print_info 2 "CMD_MENUCONFIG: $CMD_MENUCONFIG"
       ;;
       --no-menuconfig)
        CMD_MENUCONFIG=0
        print_info 2 "CMD_MENUCONFIG: $CMD_MENUCONFIG"
       ;;
       --gconfig)
        CMD_GCONFIG=1
        print_info 2 "CMD_GCONFIG: $CMD_GCONFIG"
       ;;
       --xconfig)
        CMD_XCONFIG=1
        print_info 2 "CMD_XCONFIG: $CMD_XCONFIG"
       ;;
       --save-config)
        CMD_SAVE_CONFIG=1
        print_info 2 "CMD_SAVE_CONFIG: $CMD_SAVE_CONFIG"
       ;;
       --no-save-config)
        CMD_SAVE_CONFIG=0
        print_info 2 "CMD_SAVE_CONFIG: $CMD_SAVE_CONFIG"
       ;;
       --mrproper)
        CMD_MRPROPER=1
        print_info 2 "CMD_MRPROPER: $CMD_MRPROPER"
       ;;
       --no-mrproper)
        CMD_MRPROPER=0
        print_info 2 "CMD_MRPROPER: $CMD_MRPROPER"
       ;;
       --clean)
        CMD_CLEAN=1
        print_info 2 "CMD_CLEAN: $CMD_CLEAN"
       ;;
       --no-clean)
        CMD_CLEAN=0
        print_info 2 "CMD_CLEAN: $CMD_CLEAN"
       ;;
       --oldconfig)
        CMD_CLEAN=0
        CMD_OLDCONFIG=1
        print_info 2 "CMD_CLEAN: $CMD_CLEAN"
        print_info 2 "CMD_OLDCONFIG: $CMD_OLDCONFIG"
       ;;
       --bootsplash=*)
        CMD_BOOTSPLASH=1
        CMD_GENSPLASH=0
        BOOTSPLASH_THEME=`parse_opt "$*"`
        print_info 2 "CMD_BOOTSPLASH: $CMD_BOOTSPLASH"
        print_info 2 "CMD_GENSPLASH: $CMD_GENSPLASH"
        print_info 2 "BOOTSPLASH_THEME: $BOOTSPLASH_THEME"
       ;;
       --bootsplash)
        CMD_BOOTSPLASH=1
        CMD_GENSPLASH=0
        print_info 2 "CMD_BOOTSPLASH: $CMD_BOOTSPLASH"
        print_info 2 "CMD_GENSPLASH: $CMD_GENSPLASH"
       ;;
       --no-bootsplash)
        CMD_BOOTSPLASH=0
        print_info 2 "CMD_BOOTSPLASH: $CMD_BOOTSPLASH"
       ;;
       --gensplash=*)
        CMD_GENSPLASH=1
        CMD_BOOTSPLASH=0
        GENSPLASH_THEME=`parse_opt "$*"`
        print_info 2 "CMD_GENSPLASH: $CMD_GENSPLASH"
        print_info 2 "GENSPLASH_THEME: $GENSPLASH_THEME"
        print_info 2 "CMD_BOOTSPLASH: $CMD_BOOTSPLASH"
       ;;
        --gensplashopt=*)
         CMD_GENSPLASH=1
         CMD_BOOTSPLASH=0
         GENSPLASH_THEME_PARAMS=`parse_opt "$*"`
         print_info 2 "CMD_GENSPLASH: $CMD_GENSPLASH"
         print_info 2 "GENSPLASH_THEME: $GENSPLASH_THEME"
         print_info 2 "CMD_BOOTSPLASH: $CMD_BOOTSPLASH"
        ;;
       --gensplash)
        CMD_GENSPLASH=1
        CMD_BOOTSPLASH=0
        GENSPLASH_THEME='default'
        print_info 2 "CMD_GENSPLASH: $CMD_GENSPLASH"
        print_info 2 "CMD_BOOTSPLASH: $CMD_BOOTSPLASH"
       ;;
       --no-gensplash)
        CMD_GENSPLASH=0
               print_info 2 "CMD_GENSPLASH: $CMD_GENSPLASH"
       ;;
	      --install)
		      CMD_NOINSTALL=0
		      print_info 2 "CMD_NOINSTALL: $CMD_NOINSTALL"
	      ;;
	      --no-install)
		      CMD_NOINSTALL=1
		      print_info 2 "CMD_NOINSTALL: $CMD_NOINSTALL"
	      ;;
	      --no-initrdmodules)
		      CMD_NOINITRDMODULES=1
		      print_info 2 "CMD_NOINITRDMODULES: $CMD_NOINITRDMODULES"
	      ;;
	      --udev)
		      CMD_UDEV=1
		      print_info 2 "CMD_UDEV: $CMD_UDEV"
	      ;;
	      --no-udev)
		      CMD_UDEV=0
		      print_info 2 "CMD_UDEV: $CMD_UDEV"
	      ;;
	      --callback=*)
		      CMD_CALLBACK=`parse_opt "$*"`
		      print_info 2 "CMD_CALLBACK: $CMD_CALLBACK/$*"
	      ;;
	      --postconf=*)
		      CMD_POSTCONF=`parse_opt "$*"`
		      print_info 2 "CMD_POSTCONF: $CMD_POSTCONF/$*"
	      ;;
	      --tempdir=*)
		      TEMP=`parse_opt "$*"`
		      print_info 2 "TEMP: $TEMP"
	      ;; 
	      --arch-override=*)
		      CMD_ARCHOVERRIDE=`parse_opt "$*"`
		      print_info 2 "CMD_ARCHOVERRIDE: $CMD_ARCHOVERRIDE"
	      ;;
	      --color)
		      CMD_USECOLOR=1
		      print_info 2 "CMD_USECOLOR: $CMD_USECOLOR"
	      ;;
	      --no-color)
		      CMD_USECOLOR=0
		      print_info 2 "CMD_USECOLOR: $CMD_USECOLOR"
	      ;;
	      --debugfile=*)
		      CMD_DEBUGFILE=`parse_opt "$*"`
		      DEBUGFILE=`parse_opt "$*"`
		      print_info 2 "CMD_DEBUGFILE: $CMD_DEBUGFILE"
		      print_info 2 "DEBUGFILE: $CMD_DEBUGFILE"
	      ;;
	      --kerneldir=*)
		      CMD_KERNELDIR=`parse_opt "$*"`
		      print_info 2 "CMD_KERNELDIR: $CMD_KERNELDIR"
	      ;;
	      --kernel-config=*)
		      CMD_KERNEL_CONFIG=`parse_opt "$*"`
		      print_info 2 "CMD_KERNEL_CONFIG: $CMD_KERNEL_CONFIG"
	      ;;
	      --module-prefix=*)
		      CMD_INSTALL_MOD_PATH=`parse_opt "$*"`
		      print_info 2 "CMD_INSTALL_MOD_PATH: $CMD_INSTALL_MOD_PATH"
	      ;;
	      --cachedir=*)
		      CACHE_DIR=`parse_opt "$*"`
		      print_info 2 "CACHE_DIR: $CACHE_DIR"
	      ;;
	      --minkernpackage=*)
		      CMD_MINKERNPACKAGE=`parse_opt "$*"`
		      print_info 2 "MINKERNPACKAGE: $CMD_MINKERNPACKAGE"
	      ;;
	      --linuxrc=*)
	      		CMD_LINUXRC=`parse_opt "$*"`
			print_info 2 "CMD_LINUXRC: $CMD_LINUXRC"
	      ;;
	      all)
		      BUILD_KERNEL=1
		      BUILD_INITRD=1
	      ;;
	      initrd)
		      BUILD_INITRD=1
	      ;;
	      kernel)
		      BUILD_KERNEL=1
		      BUILD_INITRD=0
	      ;;
	      --help)
		      longusage
		      exit 1
	      ;;
	      --version)
		      echo "${GK_V}"
		      exit 0
	      ;;
	      *)
		      echo "Error: Unknown option '$*'!"
		      exit 1
	      ;;
	esac
}
