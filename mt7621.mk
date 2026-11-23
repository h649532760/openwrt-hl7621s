# ============================================================================
# Hailin HL7621S  ——  OpenWrt 23.05 / kernel 5.15
# 专属适配：Breed 引导器 / 公版 0x50000 布局 / SPI NOR 16MB
# 压缩参数与原厂固件完全一致：lzma / dict=2MiB / lc=1 lp=2 pb=2
# ============================================================================

define Device/hailin_hl7621s
  DEVICE_VENDOR := Hailin
  DEVICE_MODEL := HL7621S
  DEVICE_DTS := mt7621_hailin_hl7621s
  KERNEL_LOADADDR := 0x80001000
  KERNEL_ENTRY := 0x80001000

  # 核心修正：显式 lzma 压缩 + uImage 头标记为 lzma
  # Breed 严格按头信息解压，与原厂固件格式完全对齐
  # -d21 = 2^21 = 2MiB 字典，与原厂固件参数一致
  KERNEL := kernel-bin | append-dtb | lzma -d21 -lc1 -lp2 -pb2 | uImage lzma

  # 分区与 DTS 严格对齐：0x50000 起始，共 16064KB
  IMAGE_SIZE := 16064k
  SUPPORTED_DEVICES += hailin_hl7621s

  # 预装基础功能包
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

  # factory.bin：平铺启动镜像，Breed 公版 0x50000 布局直接刷入
  IMAGE/factory.bin := append-kernel | append-rootfs | pad-rootfs | check-size $$$$(IMAGE_SIZE)
  # sysupgrade.bin：系统内在线升级专用
  IMAGE/sysupgrade.bin := append-kernel | append-rootfs | pad-rootfs | sysupgrade-tar root=$$$$@ | append-metadata | check-size $$$$(IMAGE_SIZE)
endef

TARGET_DEVICES += hailin_hl7621s
