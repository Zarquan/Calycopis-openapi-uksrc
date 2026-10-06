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
# A shell script to set the version numbers and file paths.
#

configfile=${1:?}

CALYCOPIS_OPENAPI_SCHEMA_VERSION=$(
    yq '.openapi.schema.version' "${configfile:?}"
    )

CALYCOPIS_OPENAPI_SCHEMA_PATH=$(
    yq '.openapi.schema.path' "${configfile:?}"
    )

CALYCOPIS_OPENAPI_SPRING_VERSION=$(
    yq '.openapi.spring.version' "${configfile:?}"
    )

CALYCOPIS_OPENAPI_PYTHON_VERSION=$(
    yq '.openapi.python.version' "${configfile:?}"
    )

CALYCOPIS_OPENAPI_SCHEMA_FILE="execution-broker-${CALYCOPIS_OPENAPI_SCHEMA_VERSION:?}.yaml"

export CALYCOPIS_OPENAPI_SCHEMA_VERSION
export CALYCOPIS_OPENAPI_SCHEMA_PATH
export CALYCOPIS_OPENAPI_SPRING_VERSION
export CALYCOPIS_OPENAPI_PYTHON_VERSION
export CALYCOPIS_OPENAPI_SCHEMA_FILE

#
# Update GitHub environment variables.
if [ -n "${GITHUB_ENV}" ]
then
cat >> "${GITHUB_ENV}" << EOF
CALYCOPIS_OPENAPI_SCHEMA_VERSION=${CALYCOPIS_OPENAPI_SCHEMA_VERSION}
CALYCOPIS_OPENAPI_SCHEMA_PATH=${CALYCOPIS_OPENAPI_SCHEMA_PATH}
CALYCOPIS_OPENAPI_SPRING_VERSION=${CALYCOPIS_OPENAPI_SPRING_VERSION}
CALYCOPIS_OPENAPI_PYTHON_VERSION=${CALYCOPIS_OPENAPI_PYTHON_VERSION}
CALYCOPIS_OPENAPI_SCHEMA_FILE=${CALYCOPIS_OPENAPI_SCHEMA_FILE}
EOF
fi
