# Building from source

Target: **Siflower SF19A28**, OpenWrt **18.06**. Assumes a Debian/Ubuntu host with ~25 GB free.

## 1. Host dependencies

```bash
sudo -E apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git \
  libncurses5-dev libz-dev patch python3 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 \
  subversion flex uglifyjs gcc-multilib g++-multilib p7zip p7zip-full msmtp libssl-dev \
  texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool \
  autopoint device-tree-compiler antlr3 gperf swig libtinfo5
```

`lib32gcc1` and `libtinfo5` only exist in older releases. On a modern host they are
`lib32gcc-s1` and `libtinfo6`; the multilib pieces are only needed if you build the x86 tools.

## 2. Fetch the tree

The upstream OpenWrt repository has no Siflower target. Use the community fork:

```bash
git clone --depth=1 -b openwrt-18.06-siflower https://github.com/fumiama/openwrt-gl.git
cd openwrt-gl/openwrt-18.06
```

## 3. Add the package feeds as local clones

```bash
git clone --depth=1 https://github.com/fumiama/openwrt-passwall.git  ./package/passwall
git clone --depth=1 https://github.com/fumiama/openwrt-packages.git  ./package/useful
git clone --depth=1 https://github.com/fumiama/opackages.git          ./package/fumiama
git clone --depth=1 https://github.com/fumiama/openwrt-upx.git        ./package/fumiama/upx
git clone --depth=1 https://github.com/fumiama/luci-theme-rosy.git    ./package/fumiama/luci-theme-rosy
git clone --depth=1 https://github.com/fumiama/lede.git               package/leana
```

The `lede` clone is not a feed — it is a source of packages that have to be moved into the
tree by hand, because the fork predates the modern feed layout:

```bash
mv package/leana/package/lean package/
mv -n package/leana/package/libs/* package/libs/
rm -rf package/leana
```

Skipping the `libs/*` move produces link errors an hour into the build, not at configure time.

## 4. Apply the device config

```bash
cp .config.sf1200 .config
cd include
mv siwifi_version.mk.sf1200 siwifi_version.mk
cd ..
```

**This second line is the one that matters.** `siwifi_version.mk` selects the vendor Wi-Fi
driver version pinned to this kernel. Leave the default and the build succeeds, flashes
cleanly, and boots with no radio. There is no error message; `dmesg` just never mentions a
wireless interface.

## 5. Build

```bash
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig      # only if you are changing packages
make -j$(nproc) V=s
```

First build takes 2–4 hours on a modern machine; most of it is toolchain. `V=s` is worth the
extra output the first time, because the failure will be in a vendor driver with an unhelpful
message.

## 6. Collect the artifacts

```
bin/targets/siflower/sf19a28/
├── *-squashfs-sysupgrade.tar   # web UI upgrade
└── *-squashfs-factory.img      # U-Boot / TFTP recovery
```

Keep both. The `.tar` cannot rescue a device stuck in U-Boot, and the `.img` cannot preserve
your configuration.

## Rebuilding after a kernel change

`make clean` is not enough once the vendor driver has been compiled against a kernel. Remove
`build_dir/target-mips_24kc_musl/linux-sf19a28/` and rebuild, or the stale module gets
relinked and the radio stays dead.
