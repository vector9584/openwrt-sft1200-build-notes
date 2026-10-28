# OpenWrt on the GL.iNet SFT1200

Build notes for a travel router that OpenWrt does not officially support.

## The device

GL.iNet SFT1200 (sold in some markets as GL-SF1200) — a pocket router that trades CPU for price.

| | |
| :--- | :--- |
| SoC | Siflower SF19A28 |
| ISA | MIPS 24Kc |
| RAM / flash | 128 MB / 128 MB NAND |
| Wi-Fi | SiWifi (vendor driver, out of tree) |
| Stock firmware | GL.iNet 3.x, based on OpenWrt 18.06 |

Two things make it awkward. The SoC has no upstream OpenWrt target, so there is no
`bin/targets/siflower/` waiting for you. And the Wi-Fi driver is a vendor blob that has to be
built against a matching kernel — get the version file wrong and the router boots with a
working Ethernet port and no radio at all.

## Two ways to get a firmware

| Approach | Tool | Output | Use |
| :--- | :--- | :--- | :--- |
| Image builder | `image builder` | `.tar` / `.img` | prebuilt packages only |
| Full source build | `openwrt-18.06-siflower` tree | `.tar` / `.img` | custom packages, patched kernel |

The `.tar` is for upgrading through the web UI. The `.img` is for U-Boot recovery over TFTP.
Ship both or you will eventually wish you had.

## What is in here

- **[docs/build-from-source.md](docs/build-from-source.md)** — the full compile chain: feeds, config, the version file nobody documents
- **[docs/opkg-and-packages.md](docs/opkg-and-packages.md)** — package sources, and why the default ones 404 on this target
- **[docs/pitfalls.md](docs/pitfalls.md)** — the six failures that cost the most time

## Why bother

Because the alternative is a locked vendor firmware on a device that is otherwise a perfect
travel router: USB-C powered, dual-band, small enough to forget in a bag. The community tree
that makes it work is one person's fork, undocumented outside a handful of forum threads. This
repository is the note I wish I had found first.

## Not in here

No firmware binaries. No device configuration backups. Nothing from the router itself — no
addresses, no credentials, no keys. Build it from source or use the vendor's releases.

## Licence

MIT for the text. The OpenWrt tree and the vendor driver carry their own.
