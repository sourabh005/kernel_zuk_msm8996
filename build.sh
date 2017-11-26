#!/bin/bash


#For Time Calculation
BUILD_START=$(date +"%s")

kernel_version="Oreo"
kernel_name="Destructor"
device_name="Z2_Plus"
zip_name="$kernel_name-$device_name-$kernel_version-$(date +"%Y%m%d")-$(date +"%H%M%S").zip"

# ccache
export USE_CCACHE=1
export CCACHE_DIR=/home/thakursourabh272

export CONFIG_FILE="destructor_z2_plus_defconfig"
export ARCH="arm64"
export KBUILD_BUILD_USER="Sourabh"
export KBUILD_BUILD_HOST="Destructor"
export TOOLCHAIN_PATH="/build/Custom_Toolchain"
export CROSS_COMPILE=$TOOLCHAIN_PATH/bin/aarch64-Mi5-linux-gnu-
export CONFIG_ABS_PATH="arch/${ARCH}/configs/${CONFIG_FILE}"
export objdir="/build/srb/destructor/obj"
export sourcedir="/build/srb/destructor/zuk"
export anykernel="/build/srb/destructor/anykernel"

compile() {
  make O=$objdir  $CONFIG_FILE -j12
  make O=$objdir -j12
}
clean() {
  make O=$objdir CROSS_COMPILE=${CROSS_COMPILE}  $CONFIG_FILE -j12
  make O=$objdir mrproper
  make O=$objdir clean
}
module_stock(){
  rm -rf $anykernel/modules/
  mkdir $anykernel/modules
  find $objdir -name '*.ko' -exec cp -av {} $anykernel/modules/ \;
  # strip modules
  ${CROSS_COMPILE}strip --strip-unneeded $anykernel/modules/*
  cp -rf $objdir/arch/$ARCH/boot/Image.gz-dtb $anykernel/zImage
}
delete_zip(){
  cd $anykernel
  find . -name "*.zip" -type f
  find . -name "*.zip" -type f -delete
}
build_package(){
  zip -r9 UPDATE-AnyKernel2.zip * -x README UPDATE-AnyKernel2.zip
}
make_name(){
  mv UPDATE-AnyKernel2.zip $zip_name
}
turn_back(){
cd $sourcedir
}

clean
compile
module_stock
delete_zip
build_package
make_name
turn_back
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
