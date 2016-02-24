# EupsPkg config file. Sourced by 'eupspkg'

MINICONDA2_VERSION=${MINICONDA2_VERSION:-3.19.0} # Version of Miniconda to install

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
        Linux*)  ana_platform="Linux-x86_64" ;;
        Darwin*) ana_platform="MacOSX-x86_64" ;;
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
        local reqfile='conda_packages.txt'
        local baseurl='https://raw.githubusercontent.com/lsst/lsstsw/master/etc/'
        local tmpfile
        tmpfile=$(mktemp -t "${reqfile}.XXXXXXXX")
        # attempt to be a good citizen and not leave tmp files laying around
        # after either a normal exit or an error condition
        # shellcheck disable=SC2064
        trap "{ rm -rf $tmpfile; }" EXIT
        $CURL -# -L --silent "${baseurl}/${reqfile}" --output "$tmpfile"

        conda install --yes --file "$tmpfile"
    )

    install_ups
}
