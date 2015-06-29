# EupsPkg config file. Sourced by 'eupspkg'

prep()
{
	# Select the apropriate Anaconda distribution
	OS=$(uname -s -m)
	case "$OS" in
		"Linux x86_64")		FN=Anaconda-2.2.0-Linux-x86_64.sh ;;
		"Linux "*) 		FN=Anaconda-2.2.0-Linux-x86.sh ;;
		"Darwin x86_64")	FN=Anaconda-2.2.0-MacOSX-x86_64.sh ;;
		*) 			die "unsupported OS or architecture ($OS). try installing Anaconda manually."
	esac

	# Prefer system curl; user-installed ones sometimes behave oddly
	if [[ -x /usr/bin/curl ]]; then
		CURL=${CURL:-/usr/bin/curl}
	else
		CURL=${CURL:-curl}
	fi

	"$CURL" -s -L -o installer.sh http://repo.continuum.io/archive/$FN
}

build() { :; }

install()
{
	clean_old_install

	bash installer.sh -b -p "$PREFIX"

	if [[ $(uname -s) = Darwin* ]]; then
		#run install_name_tool on all of the libpythonX.X.dylib dynamic
		#libraries in anaconda
		for entry in $PREFIX/lib/libpython*.dylib
		do
			install_name_tool -id $entry $entry
		done
	fi

	install_ups
}
