# ============================================================================
# Hailin HL7621S  ——  OpenWrt 23.05 / kernel 5.15
# 适配：Breed 引导器 + SPI NOR 16MB 闪存
# ============================================================================

define Device/hailin_hl7621s
  DEVICE_VENDOR := Hailin
  DEVICE_MODEL := HL7621S
  DEVICE_DTS := mt7621_hailin_hl7621s
  KERNEL_LOADADDR := 0x80001000
  KERNEL_ENTRY := 0x80001000

  # 标准 lzma 压缩 + uImage 封装，Breed/原厂U-Boot 双兼容
  KERNEL := kernel-bin | append-dtb | lzma | uImage none

  # 分区与 DTS 严格对齐：0x50000 起始 + 16064KB 大小
  IMAGE_SIZE := 16064k
  SUPPORTED_DEVICES += hailin_hl7621s

  # 预装基础包：ath9k无线、USB存储、网口、LuCI精简
  DEVICE_PACKAGES := kmod-ath9k kmod-usb3 kmod-usb-storage \
	kmod-fs-ext4 kmod-fs-vfat kmod-fs-exfat \
	block-mount ip-full wpad-basic-mbedtls \
	luci-base luci-mod-admin-full luci-theme-bootstrap

  # 镜像生成规则
  IMAGES += factory.bin sysupgrade.bin
  # factory.bin：平铺镜像，开头为 uImage，Breed 公版0x50000布局直接刷
  IMAGE/factory.bin := append-kernel | append-rootfs | pad-rootfs | check-size $$$$(IMAGE_SIZE)
  # sysupgrade.bin：系统内升级专用，不可直接刷入 flash
  IMAGE/sysupgrade.bin := append-kernel | append-rootfs | pad-rootfs | sysupgrade-tar root=$$$$@ | append-metadata | check-size $$$$(IMAGE_SIZE)
endef

TARGET_DEVICES += hailin_hl7621s
