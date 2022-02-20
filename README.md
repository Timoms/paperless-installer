# Paperless-NG(X) Installer for Linux

This installer provides a quick way to install paperless without using docker.  
The installation speed is based on the hardware and amount of missing packages.  
Typically this script runs for about 10 minutes and **requires** user intervention.

## Supported Environments and Requirements

- Debian/Buster
- Ubuntu

## Features

This script guides you through each step of the offical documentation.
These includes:

- Checks os support
- Installation of prerequisites
- Downloading the newest release
- Creating Paperless directories
- Setting up the paperless user and permissions
- Installation of Paperless services

## Installation

You can use this command to start the installation (root required):

```bash
bash <(wget --no-check-certificate -O - 'https://raw.githubusercontent.com/Timoms/paperless-installer/main/paperless-installer.sh')
```

or just download the script and run it manually:

```wget https://raw.githubusercontent.com/Timoms/paperless-installer/main/paperless-installer.sh```

## Testing

If you want to see the script in action without modifying anything you can use the dryrun option.  
Just set `DRY_RUN=1` in the config of the script.

## Roadmap

- [ ] Implement CI testing for the installation script
- [x] Basic install task based on official documentation
- [x] Raspberry Pi Hardware check (manual)
- [ ] Raspberry Pi Hardware check (automatic)
- [ ] Environment checks which service interpreter is used
- [ ] Redis installation check with port settings
- [ ] Change Paperless settings to match the script
- [ ] Configure ImageMagick to allow processing of PDF documents
- [ ] Compile jbig2enc encoder