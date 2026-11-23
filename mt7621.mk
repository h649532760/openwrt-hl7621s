# ============================================================================
# Hailin HL7621S  ——  OpenWrt 23.05 / kernel 5.15
# 参数来源：厂家 18.06 固件 uImage 头实测
#   comp = lzma(3)   lc/lp/pb = 1/2/2   dict = 2 MiB   load/ep = 0x80001000
#   压缩后 2,037,251 B / 解压后 6,702,704 B  -> 这颗 u-boot 能启动
# ============================================================================

define Device/hailin_hl7621s
  DEVICE_VENDOR := Hailin
  DEVICE_MODEL := HL7621S
  DEVICE_DTS := mt7621_hailin_hl7621s
  KERNEL_LOADADDR := 0x80001000
  KERNEL_ENTRY := 0x80001000
  KERNEL_SUFFIX := -uImage

  # 强制 lzma 压缩 + 标准 uImage 封装，参数严格对齐原厂老 U-Boot
  KERNEL := kernel-bin | append-dtb | lzma -d1 -lc1 -lp2 -pb2 | uImage none

  # 真正的启动限制是「解压后」<= 8 MiB，不是压缩后大小。
  # 厂家 4.14 解压后 6.70 MiB 正常；5.15 解压后 9.10 MiB -> LZMA ERROR 1
  # 必须关 KALLSYMS + 砍 built-in，把解压后压到 7.5 MiB 以下。
  #KERNEL_SIZE := 4096k

  # 0x50000 + 0xfb0000 = 16 MiB，与 DTS 的 firmware 分区严格一致
  IMAGE_SIZE := 16064k

  # 厂家固件实测：ath9k 无线、sdhci=okay、xhci=okay、nand=disabled
  # ★ 不用 luci 元包（会拉 luci-ssl -> openssl，与 mbedtls 冲突）
  DEVICE_PACKAGES := kmod-ath9k kmod-mmc kmod-sdhci kmod-sdhci-mt7620 \
      kmod-usb3 \
      kmod-usb-storage kmod-usb-storage-uas \
      kmod-fs-vfat kmod-fs-ext4 kmod-fs-exfat \
      kmod-nls-cp437 kmod-nls-iso8859-1 \
      block-mount \
      ip-full iw wpad-basic-mbedtls \
      luci-base luci-mod-admin-full luci-mod-status luci-mod-system \
      luci-mod-network luci-theme-bootstrap \
      rpcd rpcd-mod-uci rpcd-mod-file rpcd-mod-iwinfo \
      libustream-mbedtls px5g-mbedtls \
      luci-i18n-base-zh-cn

  IMAGES += factory.bin sysupgrade.bin
  # factory 平铺镜像：开头必须是 uImage，老 U-Boot 可直接识别启动
  IMAGE/factory.bin := append-kernel | append-rootfs | pad-rootfs | check-size $$$$(IMAGE_SIZE)
  # sysupgrade 仅用于系统内升级，不可直接刷入 flash 分区
  IMAGE/sysupgrade.bin := append-kernel | append-rootfs | pad-rootfs | sysupgrade-tar rootfs=$$$$@ | append-metadata | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += hailin_hl7621s
