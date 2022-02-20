#!/bin/bash
# Paperles installer script
# Automates the bare metal installation of Paperless according to the instructions
# https://paperless-ng.readthedocs.io/en/latest/setup.html#bare-metal-route

DEBUG=1   # Set to 1 to enable debug output
DRY_RUN=1 # Set to 1 to enable dry run mode
# Get system information
LINUX_FLAVOR=$(lsb_release -is)
ARCH=$(uname -m)
INSTALLER_VERSION="1.0.0"
MODE=""

exit_error() {
	echo -e "[$(date +%H:%M)] \033[0;31mERROR:\t $1\033[0m"
	exit 1
}
exit_success() {
	echo -e "[$(date +%H:%M)] \033[0;32mSUCCESS:\t $1\033[0m"
	exit 0
}
out() {
	echo -e "[$(date +%H:%M)] \033[1;30m$1\033[0m"
}
error() {
	echo -e "[$(date +%H:%M)] \033[0;31mERROR:\t\t $1\033[0m"
}
success() {
	echo -e "[$(date +%H:%M)] \033[0;32mSUCCESS:\t $1\033[0m"
}
warning() {
	echo -e "[$(date +%H:%M)] \033[0;33mWARNING:\t $1\033[0m"
}
question() {
	echo -e "[$(date +%H:%M)] \033[0;34mQUESTION:\t $1\033[0m"
}
dryrun() {
	echo -e "[$(date +%H:%M)] \033[1;36mDRYRUN:\t $1\033[0m"
}

if DEBUG=!; then
	out "LINUX_FLAVOR: $LINUX_FLAVOR"
	out "ARCH: $ARCH"
	out "INSTALLER_VERSION: $INSTALLER_VERSION"
	out "Testing color output..."
	warning "ok"
	success "ok"
	error "ok"
fi

out "Welcome to the Paperless installer!"
out "This script will install Paperless on your system."
out "Using install version $INSTALLER_VERSION"

question "Please select the installation mode:"
INSTALL_MODE=(
	"Install Paperless"
	"Uninstall Paperless"
	"Exit"
)

select INSTALL_MODE in "${INSTALL_MODE[@]}"; do
	case $REPLY in
	1)
		out "Installation mode: Install"
		MODE="install"
		break
		;;
	2)
		out "Installation mode: Uninstall"
		MODE="uninstall"
		break
		;;
	3)
		exit_error "Installation aborted"
		;;
	*)
		out "Invalid option. Please select a valid option."
		;;
	esac
done

read -p "Are you running paperless on Raspberry Pi? (y/n) " answer
case ${answer:0:1} in
y | Y)
	RASPBERRY_HARDWARE=1
	;;
*)
	RASPBERRY_HARDWARE=0
	;;
esac

if [ "$MODE" == "install" ]; then
	out "Installing Paperless..."
	out "Checking dependencies..."
	if [ "$LINUX_FLAVOR" == "Ubuntu" ]; then
		if [ "$ARCH" == "x86_64" ]; then
			out "Dependencies OK"
		else
			exit_error "Paperless requires a 64-bit architecture"
		fi
	else
		exit_error "Paperless only supports Ubuntu"
	fi

	out "Updating system..."
	if [ $DRY_RUN == 0 ]; then apt-get update -q; else dryrun "apt-get update -q"; fi
	out "Installing Paperless dependencies..."
	if [ $DRY_RUN == 0 ]; then apt install -y -q python3 python3-pip python3-dev imagemagick fonts-liberation optipng gnupg libpq-dev libmagic-dev mime-support; else dryrun "apt install -y -q python3 python3-pip python3-dev imagemagick fonts-liberation optipng gnupg libpq-dev libmagic-dev mime-support"; fi
	if [ $DRY_RUN == 0 ]; then apt install -y -q unpaper ghostscript icc-profiles-free qpdf liblept5 libxml2 pngquant zlib1g tesseract-ocr; else dryrun "apt install -y -q unpaper ghostscript icc-profiles-free qpdf liblept5 libxml2 pngquant zlib1g tesseract-ocr"; fi

	if [ $RASPBERRY_HARDWARE == 1 ]; then
		out "Installing Paperless dependencies for Raspberry Pi..."
		if [ $DRY_RUN == 0 ]; then apt install -y -q libatlas-base-dev libxslt1-dev; else dryrun "apt install -y -q libatlas-base-dev libxslt1-dev"; fi
	fi
	out "Installing additional dependencies..."
	if [ $DRY_RUN == 0 ]; then apt install -y -q build-essential python3-setuptools python3-wheel; else dryrun "apt install -y -q build-essential python3-setuptools python3-wheel"; fi

	#TODO: Check if redis is installed / running

	out "Installing Paperless..."
	out "Downloading Paperless..."
	if [ $DRY_RUN == 0 ]; then
		curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/jonaswinkler/paperless-ng/releases/latest | grep -E 'browser_download_url' | grep -Eo 'https://[^\"]*' | xargs wget -q -O paperless.tar.gz
	else dryrun "curl -H \"Accept: application/vnd.github.v3+json\" https://api.github.com/repos/jonaswinkler/paperless-ng/releases/latest | grep -E 'browser_download_url' | grep -Eo 'https://[^\"]*' | xargs wget -q -O paperless.tar.gz"; fi

	question "Please select the location of Paperless installation:"
	read -e -p "Please Enter Path: " -i "/opt/paperless" LOCATION
	LOCATION=${LOCATION:-$LOCATION}

	out "Extracting Paperless to $LOCATION ..."
	if [ $DRY_RUN == 0 ]; then tar -xzf paperless.tar.gz -C $LOCATION; else dryrun "tar -xzf paperless.tar.gz -C $LOCATION"; fi

	out "Creating paperless user..."
	if [ $DRY_RUN == 0 ]; then adduser paperless --system --home /opt/paperless --group; else dryrun "adduser paperless --system --home /opt/paperless --group"; fi
	out "Creating Paperless directories..."
	if [ $DRY_RUN == 0 ]; then mkdir -p $LOCATION/{media,data,consume}; else dryrun "mkdir -p $LOCATION/{media,data,consume}"; fi
	out "Setting Paperless permissions..."
	if [ $DRY_RUN == 0 ]; then chown -R paperless:paperless $LOCATION; else dryrun "chown -R paperless:paperless $LOCATION"; fi
	out "Upgrading pip..."
	if [ $DRY_RUN == 0 ]; then sudo -Hu paperless pip3 install --upgrade pip; else dryrun "sudo -Hu paperless pip3 install --upgrade pip"; fi
	out "Installing Requirement files..."
	if [ $DRY_RUN == 0 ]; then sudo -Hu paperless pip3 install -r $LOCATION/requirements.txt; else dryrun "sudo -Hu paperless pip3 install -r $LOCATION/requirements.txt"; fi
	out "Configuring Paperless..."
	warning "User interaction required!"
	if [ $DRY_RUN == 0 ]; then sudo -Hu paperless python3 $LOCATION/src/manage.py migrate; else dryrun "sudo -Hu paperless python3 $LOCATION/src/manage.py migrate"; fi
	if [ $DRY_RUN == 0 ]; then sudo -Hu paperless python3 $LOCATION/src/manage.py createsuperuser; else dryrun "sudo -Hu paperless python3 $LOCATION/src/manage.py createsuperuser"; fi
	out "Moving services to systemd..."
	if [ $DRY_RUN == 0 ]; then cp $LOCATION/scripts/paperless-consume.service /etc/systemd/system/paperless-consume.service; else dryrun "cp $LOCATION/scripts/paperless-consume.service /etc/systemd/system/paperless-consume.service"; fi
	if [ $DRY_RUN == 0 ]; then cp $LOCATION/scripts/paperless-scheduler.service /etc/systemd/system/paperless-scheduler.service; else dryrun "cp $LOCATION/scripts/paperless-scheduler.service /etc/systemd/system/paperless-scheduler.service"; fi
	if [ $DRY_RUN == 0 ]; then cp $LOCATION/scripts/paperless-webserver.service /etc/systemd/system/paperless-webserver.service; else dryrun "cp $LOCATION/scripts/paperless-webserver.service /etc/systemd/system/paperless-webserver.service"; fi
fi
