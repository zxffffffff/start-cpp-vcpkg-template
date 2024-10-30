#!/bin/sh
set -e

root_path=$(cd "$(dirname "$0")" && pwd)
cd ${root_path}

# 初始化 vcpkg
# vcpkg_path=${root_path}/vcpkg
# vcpkg_exe=${vcpkg_path}/vcpkg
# echo vcpkg_path: ${vcpkg_path}
# echo vcpkg_exe: ${vcpkg_exe}
# if [[ ! -x ${vcpkg_exe} ]]; then
#   vcpkg_sh=${vcpkg_path}/bootstrap-vcpkg.sh
#   echo vcpkg_sh: ${vcpkg_sh}
#   xcode-select --install
#   sh ${vcpkg_sh}
# fi

# 可选vcpkg配置版本
# arm64-osx
# x64-osx
VCPKG_TARGET_TRIPLET=arm64-osx
echo VCPKG_TARGET_TRIPLET: ${VCPKG_TARGET_TRIPLET}

# 配置Debug/Release
config=Debug
build_path=build-${VCPKG_TARGET_TRIPLET}-${config}
install_path=install-${VCPKG_TARGET_TRIPLET}-${config}
echo config: ${config}
echo build_path: ${build_path}
echo install_path: ${install_path}

if [[ -d ${install_path} ]]; then
    rm -rf ${install_path}
fi

# 可选编译器版本 -G
echo cmake ${build_path} ...
cmake -B ${build_path} -S . -DCMAKE_INSTALL_PREFIX=${install_path} -DVCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET}
echo cmake ${install_path} ...
cmake --build ${build_path} --target install --config ${config}

# 拷贝vcpkg第三方库
vcpkg_installed="${build_path}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}"
echo vcpkg_installed: ${vcpkg_installed}
# 可选 cp -rf "${vcpkg_installed}/include" "${install_path}/include"
if [[ "${config}" == "Debug" ]]; then
  cp -rf "${vcpkg_installed}/debug/lib/" "${install_path}/lib/"
else
  cp -rf "${vcpkg_installed}/lib/" "${install_path}/lib/"
fi

# run（也可使用 ctest）
echo run test
export DYLD_LIBRARY_PATH=${install_path}/bin:$DYLD_LIBRARY_PATH
${install_path}/bin/sample-main
${install_path}/bin/sample-tools-test
