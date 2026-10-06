#!/bin/bash
#
# <meta:header>
#   <meta:licence>
#     Copyright (c) 2026, Manchester University (http://www.manchester.ac.uk/)
#
#     This work is made available under the Creative Commons
#     Attribution-ShareAlike 4.0 International licence.
#
#     For details of the licence terms see:
#     https://creativecommons.org/licenses/by-sa/4.0/
#   </meta:licence>
# </meta:header>
#
# AIMetrics: []
#
# A shell script to build the Java client package from the schema.
#

basepath=$(
    dirname $(
        realpath $(
            dirname "$0"
            )
        )
    )

source "${basepath}/bin/versions.sh" "${basepath}/config.yaml"

#
# Build the Java client Maven project.
pushd "${basepath:?}/codegen/java/client/"
    ./mvnw \
        -Drevision=${CALYCOPIS_OPENAPI_SPRING_VERSION:?} \
        -Dcalycopis.schema.file=/tmp/${CALYCOPIS_OPENAPI_SCHEMA_FILE:?} \
        clean install
popd



