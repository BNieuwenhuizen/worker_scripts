START_PWD=`pwd`
BUILD_NAME=$1

set -e

[ -d artifacts ] && rm -Rf artifacts
[ -f artifacts.tar.xz ] && rm artifacts.tar.xz

[ -d VK-GL-CTS ] || git clone https://github.com/KhronosGroup/VK-GL-CTS.git

mkdir artifacts

cd VK-GL-CTS/external
python2 fetch_sources.py

cd $START_PWD

mkdir artifacts/vulkan-cts
cd artifacts/vulkan-cts

cmake -GNinja -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH="$START_PWD/artifacts" -DDEQP_TARGET:STRING=default  ../../VK-GL-CTS
ninja

cd $START_PWD

cp VK-GL-CTS/external/vulkancts/mustpass/1.1.2/vk-default.txt artifacts/mustpass.txt


tar cJf artifacts.tar.xz artifacts
scp -o StrictHostKeyChecking=no artifacts.tar.xz stashed-file-writer@ci.basnieuwenhuizen.nl:/srv/stashed-files/vulkan-${BUILD_NAME?}.tar.xz
