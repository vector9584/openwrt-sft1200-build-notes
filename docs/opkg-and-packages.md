# Packages and feeds

## Why the default sources fail

OpenWrt's global package CDN does not carry `siflower` packages. Pointing `opkg` at
`downloads.openwrt.org` on this device resolves fine and then 404s on every install. The
packages only exist in GL.iNet's own build output for this target.

## Working sources

`/etc/opkg/distfeeds.conf`:

```
src/gz glinet_packages https://fw.gl-inet.com/releases/v18.06.5/packages-3.6/siflower/packages
src/gz glinet_private  https://fw.gl-inet.com/releases/v18.06.5/packages-3.6/siflower/glinet
src/gz glinet_kmod     https://fw.gl-inet.com/releases/v18.06.5/kmod-3.6/siflower/sf19a28_nand
```

`glinet_kmod` is the one people forget. Without it, installing anything that depends on a
kernel module pulls an incompatible `kmod-*` from nowhere and the install fails with a
dependency loop rather than a missing-package error.

## Enabling SFTP for package uploads

Stock firmware ships Dropbear without the SFTP subsystem, so `scp` fails silently and the
LuCI file upload page has nowhere to put anything.

```bash
opkg update
opkg install vsftpd openssh-sftp-server
/etc/init.d/vsftpd enable
/etc/init.d/vsftpd start
```

## Installing packages from the web UI

LuCI on GL.iNet firmware has no native `.ipk` uploader. Add one:

```bash
opkg install /tmp/luci-lib-fs_1.0-1_all.ipk
opkg install /tmp/luci-app-filetransfer_1-2_all.ipk
opkg install /tmp/luci-i18n-filetransfer-zh-cn_1-2_all.ipk
```

Install in that order — `filetransfer` depends on `luci-lib-fs`, and the UI will show the menu
entry but throw a Lua error if the lib is missing.

## ShellClash

For a router with 128 MB of RAM, a shell-based proxy manager is lighter than a LuCI app:

```bash
export url='https://cdn.jsdelivr.net/gh/juewuy/ShellClash@master'
wget -q --no-check-certificate -O /tmp/install.sh $url/install.sh
sh /tmp/install.sh && source /etc/profile
```

It survives firmware upgrades only if `/etc/config` is preserved — which the sysupgrade `.tar`
does by default, and the factory `.img` does not.

## Useful background

- [GL.iNet Chinese forum](https://forum.gl-inet.com/c/chinese/8)
- [Image builder walkthrough (right.com.cn)](https://www.right.com.cn/forum/thread-7473327-1-1.html)
- [Siflower port thread (right.com.cn)](https://www.right.com.cn/forum/thread-7348817-1-1.html)
