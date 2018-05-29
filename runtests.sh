[ -d artifacts ] && rm -R artifacts

set -e

scp -o StrictHostKeyChecking=no stashed-file-writer@ci.basnieuwenhuizen.nl:/srv/stashed-files/vulkan-master.tar.xz ./vulkan.tar.xz
scp -o StrictHostKeyChecking=no stashed-file-writer@ci.basnieuwenhuizen.nl:/srv/stashed-files/mesa-t.tar.xz mesa.tar.xz


tar xvf vulkan.tar.xz
tar xvf mesa.tar.xz



sed -i "s#\".*artifacts#\"$PWD\/artifacts#g"  $PWD/artifacts/share/vulkan/icd.d/radeon_icd.x86_64.json
export VK_ICD_FILENAMES=$PWD/artifacts/share/vulkan/icd.d/radeon_icd.x86_64.json
export LD_LIBRARY_PATH=$PWD/artifacts/lib

artifacts/bin/vulkan-cts-runner --deqp "$PWD/artifacts/vulkan-cts/external/vulkancts/modules/vulkan/deqp-vk" --caselist  "$PWD/artifacts/mustpass.txt" --output results.csv



