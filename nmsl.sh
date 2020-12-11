#!/bin/bash

# shellcheck disable=SC2048,SC2086

_NMSL_debug() { if [[ -n $_NMSL_debug ]]; then echo     "$(date -Iseconds)[DEBUG][NMSL    ]$1"; fi     ; }
_NMSL_info()  {                                echo     "$(date -Iseconds)[INFO ][NMSL    ]$1"         ; }
_NMSL_warn()  {                                echo >&2 "$(date -Iseconds)[WARN ][NMSL    ]$1"         ; }
_NMSL_error() {                                echo >&2 "$(date -Iseconds)[ERROR][NMSL    ]$1"; exit $2; }

if [[ -z $_NMSL_INCLUDED ]]; then

_NMSL_INCLUDED="_NMSL_INCLUDED"

add() {
    add_file() {
        cp $* "$_NMSL_TEMPORARY"
        _NMSL_debug "Add file \"$*\" to package"
    }
    add_folder() {
        cp -r $* "$_NMSL_TEMPORARY"
        _NMSL_debug "Add folder \"$*\" to package"
    }
    add_func() {
        echo "$1() {" >> "$_NMSL_OUTPUT_TO"
        echo "}" >> "$_NMSL_OUTPUT_TO"
    }
    add_option() {
        echo >> "$_NMSL_OUTPUT_TO"
        echo "$1() {" >> "$_NMSL_OUTPUT_TO"
        _NMSL_BEHAVIOR_FOR="$1"
        _NMSL_debug "Add option \"$1\" to package"
        shift
        $*
        echo "}" >> "$_NMSL_OUTPUT_TO"
    }
    ${FUNCNAME[0]}_$*
}

behavior() {
    behavior_is() {
        behavior_is_default() {
            case $_NMSL_BEHAVIOR_FOR in
                "--extract")
                    _NMSL_debug "With default behavior of extracting"
                    ;;
                *)
                    _NMSL_info "Option \"$_NMSL_BEHAVIOR_FOR\" doesn't have a default behavior."
            esac
        }
        behavior_is_empty() {
            _NMSL_debug "With empty behavior"
            echo "    :" >> "$_NMSL_OUTPUT_TO"
        }
        ${FUNCNAME[0]}_$*
    }
    ${FUNCNAME[0]}_$*
}

clean() {
    clean_everything() {
        rm -rf "$_NMSL_TEMPORARY" "$_NMSL_COMPRESS_SOURCE" "$_NMSL_TEMPORARY_DEST"
        _NMSL_info "Cleaned up"
    }
    ${FUNCNAME[0]}_$*
}

compress() {
    compress_it() {
        _NMSL_COMPRESS_SOURCE=${_NMSL_TEMPORARY_DEST:?_NMSL_TEMPORARY}
        _NMSL_debug "Compressing \"$_NMSL_COMPRESS_SOURCE\""
        case $_NMSL_COMPRESSION_TOOL in
            xz)
                xz $_NMSL_COMPRESSION_EXTRA $_NMSL_COMPRESS_SOURCE
                _NMSL_TEMPORARY_DEST="$_NMSL_COMPRESS_SOURCE.xz"
                _NMSL_info "Compressed at \"$_NMSL_TEMPORARY_DEST\""
                ;;
            *)
                _NMSL_warn "Unrecognized compression tool. Trying default command"
                _NMSL_warn "$_NMSL_COMPRESSION_TOOL $_NMSL_PACKAGE_EXTRA $_NMSL_TEMPORARY"
                $_NMSL_PACKAGE_TOOL $_NMSL_PACKAGE_EXTRA $_NMSL_TEMPORARY
                ;;
        esac
    }
    ${FUNCNAME[0]}_$*
}

debug() {
    debug_off() {
        unset _NMSL_debug
        _NMSL_debug "Debug OFF" # ???
    }
    debug_on() {
        _NMSL_debug="DEBUG"
        _NMSL_debug "Debug ON"
    }
    ${FUNCNAME[0]}_$*
}

output() {
    output_to() {
        _NMSL_OUTPUT_TO="$1"
        _NMSL_debug "Output destination is \"$_NMSL_OUTPUT_TO\""
        _NMSL_TEMPORARY=$(mktemp -d)
        _NMSL_debug "Temporary destination is at \"$_NMSL_TEMPORARY\""
        echo "#!/bin/bash" > "$_NMSL_OUTPUT_TO"
        echo "" >> "$_NMSL_OUTPUT_TO"
    }
    ${FUNCNAME[0]}_$*
}

pack() {
    pack_it() {
        case $_NMSL_PACKAGE_TOOL in
            tar)
                _NMSL_debug "Packing with tar"
                _NMSL_TEMPORARY_DEST="$_NMSL_TEMPORARY.tar"
                tar -C $_NMSL_TEMPORARY -cf $_NMSL_TEMPORARY_DEST .
                _NMSL_info "Packed at \"$_NMSL_TEMPORARY_DEST\""
                ;;
            *)
                _NMSL_warn "Unrecognized package tool. Trying default command"
                _NMSL_warn "$_NMSL_PACKAGE_TOOL $_NMSL_PACKAGE_EXTRA $_NMSL_TEMPORARY"
                $_NMSL_PACKAGE_TOOL $_NMSL_PACKAGE_EXTRA $_NMSL_TEMPORARY
                ;;
        esac
    }
    ${FUNCNAME[0]}_$*
}

packaging() {
    packaging_definition() {
        packaging_definition_of() {
            _NMSL_PACKAGE_PROCESS_NAME="$*"
            _NMSL_info "This is a package process for \"$_NMSL_PACKAGE_PROCESS_NAME\""
        }
        ${FUNCNAME[0]}_$*
    }
    ${FUNCNAME[0]}_$*
}

remove() {
    remove_file() {
        rm "$_NMSL_TEMPORARY"$*
        _NMSL_debug "Add file $* to package"
    }
    remove_folder() {
        rm -r "${_NMSL_TEMPORARY:?}/"$*
        _NMSL_debug "Add folder $* to package"
    }
    ${FUNCNAME[0]}_$*
}

use() {
    use_checksum() {
        use_checksum_method() {
            _NMSL_CKSUM=$("${1}sum" $_NMSL_TEMPORARY_DEST | awk '{ print $1 }')
            _NMSL_debug "Checksum by ${1}sum is \"$_NMSL_CKSUM\""
            echo "_NMSL_CKSUM_${1}=\"$_NMSL_CKSUM\"" >> "$_NMSL_OUTPUT_TO"
        }
        use_checksum_tool() {
            _NMSL_CKSUM=$("$1" $_NMSL_TEMPORARY_DEST | awk '{ print $1 }')
            _NMSL_debug "Checksum by $1 is \"$_NMSL_CKSUM\""
            echo "_NMSL_CKSUMT_$1=\"$_NMSL_CKSUM\"" >> "$_NMSL_OUTPUT_TO"
        }
        ${FUNCNAME[0]}_$*
    }
    use_compression() {
        use_compression_tool() {
            _NMSL_COMPRESSION_TOOL="$1"
            _NMSL_EXTRA_TYPE="compression"
            _NMSL_debug "Use \"$_NMSL_COMPRESSION_TOOL\" as compression tool"
            shift
            $*
        }
        ${FUNCNAME[0]}_$*
    }
    use_package() {
        use_package_tool() {
            _NMSL_PACKAGE_TOOL="$1"
            _NMSL_EXTRA_TYPE="package"
            _NMSL_debug "Use \"$_NMSL_PACKAGE_TOOL\" as package tool"
            shift
            $*
        }
        ${FUNCNAME[0]}_$*
    }
    ${FUNCNAME[0]}_$*
}

with() {
    with_extra() {
        case "$_NMSL_EXTRA_TYPE" in
            compression)
                _NMSL_COMPRESSION_EXTRA="$*"
                _NMSL_debug "With compression extra \"$_NMSL_COMPRESSION_EXTRA\""
                ;;
            package)
                _NMSL_PACKAGE_EXTRA="$*"
                _NMSL_debug "With package extra \"$_NMSL_PACKAGE_EXTRA\""
                ;;
        esac
    }
    ${FUNCNAME[0]}_$*
}

$*

else
    _NMSL_warn "NMSL has been included."
fi
