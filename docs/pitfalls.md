# Pitfalls

Six failures, roughly in order of how much time they cost.

## 1. Radio silently absent

The build completes, the flash succeeds, Ethernet works, `iw list` returns nothing.

Cause: `include/siwifi_version.mk` still points at the wrong vendor driver version for this
kernel. Copy `siwifi_version.mk.sf1200` over it before building. Nothing in the build log warns
you — the driver compiles fine, it just does not attach.

## 2. `lede` clone treated as a feed

`git clone` into `package/leana` and then `./scripts/feeds install -a` looks correct and does
nothing useful. That repository is a package tree, not a feed. Move `package/lean` and
`package/libs/*` into place manually and delete the clone.

## 3. Dependency names from a decade ago

The widely copied host-dependency list names `lib32gcc1` and `libtinfo5`. Both were removed
from Debian/Ubuntu years ago. On a current host the install step fails at the first package
and people assume the guide is wrong about everything. Substitute `lib32gcc-s1` and `libtinfo6`.

## 4. `kmod` source missing

Adding only `glinet_packages` and `glinet_private` gives a router that can install pure-Lua
packages and fails on anything touching the kernel. The `glinet_kmod` line points at a
different release path (`kmod-3.6`, not `packages-3.6`) and is easy to overlook when copying
two lines from a forum post.

## 5. Stale vendor driver after a kernel change

Changing the kernel config and rebuilding without clearing
`build_dir/target-mips_24kc_musl/linux-sf19a28/` relinks a module compiled against the previous
kernel. Symptoms match pitfall 1 exactly, which sends you looking at the version file again.

## 6. `.tar` cannot rescue a brick

The sysupgrade archive is applied by a running system. A device that no longer boots needs the
factory `.img` over TFTP in U-Boot. Keep both artifacts from every build — the one you did not
keep is the one you will need.
