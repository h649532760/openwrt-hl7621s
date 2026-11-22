# ============================================================================
# Hailin HL7621S  ——  OpenWrt 23.05 / kernel 5.15
# 参数来源：厂家 18.06 固件 uImage 头实测
#   comp = lzma(3)   lc/lp/pb = 1/2/2   dict = 2 MiB   load/ep = 0x80001000
# ============================================================================

define Device/hailin_hl7621s
  DEVICE_VENDOR := Hailin
  DEVICE_MODEL := HL7621S
  DEVICE_DTS := mt7621_hailin_hl7621s
  KERNEL_LOADADDR := 0x80001000

  # 内核压缩参数与原厂保持一致，避免 U-Boot LZMA ERROR 1
  KERNEL := kernel-bin | append-dtb | uImage none

  # 分区与 DTS 严格对齐：0x050000 + 0xfb0000 = 16064k
  IMAGE_SIZE := 16064k

  # 设备识别标记，保障 sysupgrade 与 rootfs_data 正常生成
  SUPPORTED_DEVICES += hailin,hl7621s

  # 预装基础包：全程 mbedtls，不引入 openssl
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

  # pad-rootfs 预留尾部空闲空间，用于生成 rootfs_data（可写 overlay）
  IMAGE/factory.bin := append-kernel | append-rootfs | pad-rootfs | check-size $$$$(IMAGE_SIZE)
  IMAGE/sysupgrade.bin := append-kernel | append-rootfs | pad-rootfs | sysupgrade-tar rootfs=$$$$@ | append-metadata | check-size $$$$(IMAGE_SIZE)
endef

TARGET_DEVICES += hailin_hl7621s
