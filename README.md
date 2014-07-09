# libcec-apkg

![](https://raw.githubusercontent.com/mafredri/libcec-apkg/master/source/CONTROL/icon.png)

This is a package providing libcec functionality on ASUSTOR ADM. By default, ADM does not ship with the cdc-acm kernel module which is required for libCEC. For this reason it has been included in this package and is automatically loaded on startup.

## Instructions

After installation the command-line tool `cec-client` can be used on the NAS.

## Contains

* libCEC
* liblockdev
* libudev (eudev)
* cdc-acm kernel module (built for the ADM kernel)
