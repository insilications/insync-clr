# Insync for Clear Linux
This downloads the latest version of Insync and install it correctly on Clear Linux.


# Installation to /usr/local using cmake (won't by removed by swupd update or conflict with upstream)

Download the latest source from `local-install` branch (https://github.com/insilications/insync-clr/archive/local-install.zip):

    unzip -q insync-clr-local-install.zip
    cd insync-clr-local-install/
    mkdir build
    cd build/
    cmake CMAKE_INSTALL_PREFIX=/usr/local ..
    make
    make install


# Installation using RPM and autospec (for custom mixes and 3rd party bundles)

Following https://docs.01.org/clearlinux/latest/guides/clear/autospec.html (Example 3), you need to build a new spec file and RPM files using the pre-defined package provided by https://github.com/insilications/insync:

    cd your-autospec-workspace/packages/
    git clone https://github.com/insilications/insync.git
    cd insync/
    make autospec

The resulting RPMs will be built in `your-autospec-workspace/packages/insync/rpms/`. You can install everything by doing `make install-local` inside `your-autospec-workspace/packages/insync/` or by putting all the generated RPM files inside your mix or 3rd party bundle (e.g. https://docs.01.org/clearlinux/latest/guides/clear/mixer.html or https://docs.01.org/clearlinux/latest/guides/clear/swupd-3rd-party.html).

# Troubleshooting:

If autospec fails to build the package, remember add the following to the `buildreq_add` file inside `your-autospec-workspace/packages/insync/` and then do `make autospec` inside `your-autospec-workspace/packages/insync/` again

    rpm
    rpm-extras
    curl
    curl-bin
    ca-certs
    xmlstarlet
    openssl-dev
    findutils
    mlocate
    p11-kit
    bash
    cpio-bin
    curl-lib
    curl-dev
    openssl-lib
    zlib-dev
    pcre-dev
    pcre-extras
