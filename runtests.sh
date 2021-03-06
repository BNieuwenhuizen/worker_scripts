BUILDERNAME=$1
MESA_ID=$2

FAMILY=${BUILDERNAME#test-}

[ -d artifacts ] && rm -R artifacts

set -e

scp -o StrictHostKeyChecking=no stashed-file-writer@ci.basnieuwenhuizen.nl:/srv/stashed-files/vulkan-master.tar.xz ./vulkan.tar.xz
scp -o StrictHostKeyChecking=no stashed-file-writer@ci.basnieuwenhuizen.nl:/srv/stashed-files/mesa-${MESA_ID}.tar.xz mesa.tar.xz


tar xf vulkan.tar.xz
tar xf mesa.tar.xz

sed -i "s#\"library_path\": \".*artifacts#\"library_path\": \"$PWD\/artifacts#g"  $PWD/artifacts/share/vulkan/icd.d/radeon_icd.x86_64.json
export VK_ICD_FILENAMES=$PWD/artifacts/share/vulkan/icd.d/radeon_icd.x86_64.json
export LD_LIBRARY_PATH=$PWD/artifacts/lib


cp artifacts/mustpass.txt mustpass.txt
[ -f worker_scripts/exclusions/${FAMILY?}/unstable.txt ] && (grep -vFf worker_scripts/exclusions/${FAMILY?}/unstable.txt artifacts/mustpass.txt > mustpass.txt) || true

artifacts/bin/vulkan-cts-runner --deqp "$PWD/artifacts/vulkan-cts/external/vulkancts/modules/vulkan/deqp-vk" --caselist  "$PWD/mustpass.txt" --output results.csv

cp results.csv results_filtered.csv
echo None > ignored.txt

[ -f worker_scripts/exclusions/${FAMILY?}/failing.txt ] && (grep -vFf worker_scripts/exclusions/${FAMILY?}/failing.txt results.csv > results_filtered.csv) || true
[ -f worker_scripts/exclusions/${FAMILY?}/failing.txt ] && (grep -Ff worker_scripts/exclusions/${FAMILY?}/failing.txt results.csv > ignored.csv) || true

echo "Ignored tests:"
cat ignored.csv

echo "Failures:"
! grep Fail\\\|Crash results_filtered.csv 
