#!/bin/bash

# shellcheck disable=SC2048,SC2086

_NMSL_debug() { if [[ -n $_NMSL_debug ]]; then echo     "$(date -Iseconds)[DEBUG][NMSL    ]$1"; fi     ; }
_NMSL_info()  {                                echo     "$(date -Iseconds)[INFO ][NMSL    ]$1"         ; }
_NMSL_warn()  {                                echo >&2 "$(date -Iseconds)[WARN ][NMSL    ]$1"         ; }
_NMSL_error() {                                echo >&2 "$(date -Iseconds)[ERROR][NMSL    ]$1"; exit $2; }

if [[ -z $_NMSL_INCLUDED ]]; then

_NMSL_INCLUDED="_NMSL_INCLUDED"

debug() {
    debug_on() {
        _NMSL_debug="DEBUG"
        _NMSL_debug "Debug ON"
    }
    debug_off() {
        unset _NMSL_debug
        _NMSL_debug "Debug OFF" # ???
    }
    ${FUNCNAME[0]}_$*
}

packaging() {
    packaging_definition() {
        packaging_definition_of() {
            _NMSL_PACKAGE_PROCESS_NAME="$*"
            _NMSL_debug "This is a package process for \"$_NMSL_PACKAGE_PROCESS_NAME\""
        }
        ${FUNCNAME[0]}_$*
    }
    ${FUNCNAME[0]}_$*
}

use() {
    use_packaging() {
        use_packaging_tool() {
            _NMSL_PACKAGING_TOOL="$*"
            _NMSL_debug "Use $_NMSL_PACKAGING_TOOL as packaging tool"
            case "$*" in
                "xz" )
            esac
        }
        ${FUNCNAME[0]}_$*
    }
    ${FUNCNAME[0]}_$*
}

output() {
    output_to() {
        _NMSL_OUTPUT_TO="$*"
        _NMSL_debug "Output destination is \"$_NMSL_OUTPUT_TO\""
    }
    ${FUNCNAME[0]}_$*
}

$*

else
    _NMSL_warn "NMSL has been included."
fi
