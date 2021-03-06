#!/usr/bin/env bash

# Copyright 1999-2018 Alibaba Group.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

curDir=$(cd "$(dirname "$0")" && pwd)
BASE_HOME=$(cd "${curDir}"/.. && pwd)

BUILD_DIR="${BASE_HOME}/build"

INSTALL_PREFIX="/opt/dragonfly"

. "${BUILD_DIR}/log.sh"

printResult() {
    filed=$1
    result=$2
    if [ "${result}" -eq 0 ]; then
        info "${filed}" "SUCCESS"
    else
        error "${filed}" "FAILURE"
    fi
}

buildClient() {
    field="dfdaemon&dfget"
    echo "====================================================================="
    info "${field}" "compiling dfdaemon and dfget..."
    cd "${BUILD_DIR}/client"
    ./configure --prefix="${INSTALL_PREFIX}"
    make
    retCode=$?
    printResult "${field}" ${retCode}
    return ${retCode}
}

installClient() {
    field="install client"
    echo "====================================================================="
    info "${field}" "install dfdaemon and dfget..."
    cd "${BUILD_DIR}/client"
    make install
    retCode=$?
    test ${retCode} -eq 0 && make clean
    printResult "${field}" ${retCode}
    return ${retCode}
}

buildSupernode() {
    field="supernode"
    echo "====================================================================="
    info "${field}" "compiling source and building image..."
    "${BUILD_DIR}/supernode/supernode-build.sh" all
    retCode=$?
    printResult "${field}" ${retCode}
    return ${retCode}
}

main() {
    case "$1" in
        install)
            installClient
        ;;
        client)
            buildClient
        ;;
        supernode)
            buildSupernode
        ;;
        *)
            buildClient && buildSupernode
        ;;
    esac
}

main "$@"

