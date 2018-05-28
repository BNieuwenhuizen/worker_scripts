START_PWD=`pwd`
BUILD_NAME=$1

set -e

[ -d artifacts ] && rm -Rf artifacts
[ -d drm-build ] && rm -Rf drm-build
[ -d llvm-build ] && rm -Rf llvm-build
[ -d mesa-build ] && rm -Rf mesa-build
[ -f artifacts.tar.xz ] && rm artifacts.tar.xz


# some checkouts in case this script is run outside of the CI
[ -d drm ] || git clone git://anongit.freedesktop.org/mesa/drm
[ -d mesa ] || git clone git://anongit.freedesktop.org/mesa/mesa
[ -d llvm ] || git clone https://github.com/llvm-mirror/llvm.git

mkdir artifacts

mkdir drm-build

cd drm-build


meson --buildtype release  --prefix "$START_PWD/artifacts" ../drm
ninja
ninja install

cd $START_PWD

mkdir llvm-build
cd llvm-build

cmake -GNinja -DCMAKE_BUILD_TYPE:STRING=Release -DLLVM_CCACHE_BUILD=ON -DCMAKE_INSTALL_PREFIX:PATH="$START_PWD/artifacts" '-DLLVM_APPEND_VC_REV:BOOL=ON' '-DLLVM_ENABLE_RTTI:BOOL=ON' '-DLLVM_ENABLE_FFI:BOOL=OFF' '-DLLVM_BUILD_DOCS:BOOL=OFF' '-DLLVM_ENABLE_SPHINX:BOOL=OFF' '-DSPHINX_OUTPUT_HTML:BOOL=OFF' '-DSPHINX_OUTPUT_MAN:BOOL=OFF' '-DSPHINX_WARNINGS_AS_ERRORS:BOOL=OFF' '-DLLVM_BUILD_LLVM_DYLIB:BOOL=ON' '-DLLVM_LINK_LLVM_DYLIB:BOOL=ON' '-DLLVM_BINUTILS_INCDIR:PATH=/usr/include' '-DLLVM_VERSION_SUFFIX=git' '-DLLVM_ENABLE_OCAMLDOC=OFF' '-DLLVM_TARGETS_TO_BUILD=X86;AMDGPU' ../llvm 
ninja
ninja install

cd $START_PWD

mkdir mesa-build
cd mesa-build

export PATH="$START_PWD/artifacts/bin:$PATH"
export PKG_CONFIG_PATH="$START_PWD/artifacts/lib64/pkgconfig"
meson --buildtype release --prefix "$START_PWD/artifacts"  -Dplatforms=drm -Ddri-drivers= -Dvulkan-drivers=amd -Dgallium-drivers= ../mesa
ninja
ninja install

cd $START_PWD

rm artifacts/lib/*.a
rm -R artifacts/include


tar cJf artifacts.tar.xz artifacts
scp artifacts.tar.xz stashed-file-writer@ci.basnieuwenhuizen.nl:/srv/stashed-files/mesa-${BUILD_NAME?}.tar.xz
