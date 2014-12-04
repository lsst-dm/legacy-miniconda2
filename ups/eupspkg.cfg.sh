# EupsPkg config file. Sourced by 'eupspkg'

prep()
{
	# Select the apropriate Anaconda distribution
	OS=$(uname -s -m)
	case "$OS" in
		"Linux x86_64")		FN=Anaconda-2.1.0-Linux-x86_64.sh ;;
		"Linux "*) 		FN=Anaconda-2.1.0-Linux-x86.sh ;;
		"Darwin x86_64")	FN=Anaconda-2.1.0-MacOSX-x86_64.sh ;;
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

	install_ups
}
