# EupsPkg config file. Sourced by 'eupspkg'

MINICONDA2_VERSION=${MINICONDA2_VERSION:-4.2.12} # Version of Miniconda to install

prep() { :; }
build() { :; }

install()
{
    # Prefer system curl; user-installed ones sometimes behave oddly
    if [[ -x /usr/bin/curl ]]; then
        CURL=${CURL:-/usr/bin/curl}
    else
        CURL=${CURL:-curl}
    fi

    case $(uname -s) in
        Linux*)
            ana_platform="Linux-x86_64"
            conda_packages="conda2_packages-linux-64.txt"
            ;;
        Darwin*)
            ana_platform="MacOSX-x86_64"
            conda_packages="conda2_packages-osx-64.txt"
            ;;
        *)
            echo "Cannot install miniconda: unsupported platform $(uname -s)"
            exit 1
            ;;
    esac

    miniconda_file_name="Miniconda2-${MINICONDA2_VERSION}-${ana_platform}.sh"
    echo "::: Deploying Miniconda ${MINICONDA2_VERSION} for ${ana_platform}"
    $CURL -# -L -O http://repo.continuum.io/miniconda/${miniconda_file_name}

    clean_old_install

    bash ${miniconda_file_name} -b -p "$PREFIX"

    if [[ $(uname -s) = Darwin* ]]; then
        #run install_name_tool on all of the libpythonX.X.dylib dynamic
        #libraries in miniconda
        for entry in $PREFIX/lib/libpython*.dylib
            do
                install_name_tool -id $entry $entry
            done
    fi

    (
        # Install packages on which the stack is known to depend

        export PATH="$PREFIX/bin:$PATH"
        local baseurl='https://raw.githubusercontent.com/lsst/lsstsw/afcf8775f1539ac4f9db2939e0b127731b15a16d/etc/'
        local tmpfile
        tmpfile=$(mktemp -t "${conda_packages}.XXXXXXXX")
        # attempt to be a good citizen and not leave tmp files laying around
        # after either a normal exit or an error condition
        # shellcheck disable=SC2064
        trap "{ rm -rf $tmpfile; }" EXIT
        $CURL -# -L --silent "${baseurl}/${conda_packages}" --output "$tmpfile"

        conda install --yes --file "$tmpfile"
    )

    install_ups
}
