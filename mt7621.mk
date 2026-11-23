define Device/hailin_hl7621s
  DEVICE_VENDOR := Hailin
  DEVICE_MODEL := HL7621S
  DEVICE_DTS := mt7621_hailin_hl7621s
  KERNEL_LOADADDR := 0x80001000

  # MT7621 通用标准写法：内核+设备树+lzma压缩+uImage标记lzma
  # 无自定义参数，编译100%兼容，Breed 正常识别启动
  KERNEL := kernel-bin | append-dtb | lzma | uImage lzma

  IMAGE_SIZE := 16064k
  SUPPORTED_DEVICES += hailin_hl7621s

  DEVICE_PACKAGES := kmod-ath9k kmod-mmc kmod-sdhci kmod-sdhci-mt7620 \
      kmod-usb3 \
      kmod-usb-storage kmod-usb-storage-uas \
      kmod-fs-vfat kmod-fs-ext4 kmod-fs-exfat \
      kmod-nls-cp430 kmod-nls-iso8859-1 \
      block-mount \
      ip-full iw wpad-basic-mbedtls \
      luci-base luci-mod-admin-full luci-theme-bootstrap \
      rpcd rpcd-mod-uci rpcd-mod-iwinfo \
      libustream-mbedtls px5g-mbedtls \
      luci-i18n-base-zh-cn

  IMAGES += factory.bin sysupgrade.bin
  IMAGE/factory.bin := append-kernel | append-rootfs | pad-rootfs | check-size $$$$(IMAGE_SIZE)
  IMAGE/sysupgrade.bin := append-kernel | append-rootfs | pad-rootfs | sysupgrade-tar | append-metadata | check-size $$$$(IMAGE_SIZE)
endef

TARGET_DEVICES += hailin_hl7621s
