# ============================================================================
# Hailin HL7621S  ——  OpenWrt 23.05 / kernel 5.15
# 贴到 target/linux/ramips/image/mt7621.mk（放在 mqmaker_witi 附近即可）
#
# 参数来源：厂家 18.06 固件（/dev/mtd3 的 uImage 头）实测
#   comp = lzma(3)   lc/lp/pb = 1/2/2   dict = 2 MiB   load/ep = 0x80001000
#   压缩后 2,037,251 B / 解压后 6,702,704 B  -> 这颗 u-boot 能启动
# ============================================================================

define Device/hailin_hl7621s
  DEVICE_VENDOR := Hailin
  DEVICE_MODEL := HL7621S
  DEVICE_DTS := mt7621_hailin_hl7621s
  KERNEL_LOADADDR := 0x80001000

  # ★ -d21 = 2^21 = 2 MiB 字典，和厂家固件完全一致。
  #   注意：lzma_alone 的 -d{N} 是「2 的 N 次方」，不是字节数！
  #     -d1  -> 2 字节（被夹到 4096，压缩率极差，就是最早 4.78 MiB 的原因）
  #     -d1m -> 非法参数，lzma 直接报错退出（会留下未压缩的 9.5 MB 文件）
  #     -d20 -> 1 MiB
  #     -d21 -> 2 MiB   ← 厂家用这个
   KERNEL := kernel-bin | append-dtb | uImage none

  # ★ 真正的启动限制不是这里的 4 MiB，而是「解压后」大小：
  #   这颗 u-boot 的 LZMA 输出缓冲区约 8 MiB。
  #     厂家 4.14: 解压后 6.70 MiB  -> 正常
  #     我们 5.15: 解压后 9.10 MiB  -> "LZMA ERROR 1 - must RESET board to recover"
  #   所以必须保证 uncompressed <= 8 MiB（最好 <= 7.5 MiB）：
  #     make menuconfig -> 关 "Compile the kernel with symbol table information" (KALLSYMS)
  #     + kernel_menuconfig 砍掉用不到的 built-in
  #   KERNEL_SIZE 只是压缩后的粗保险（防止误加一堆内置），别把它当真正的目标。
  #KERNEL_SIZE := 4096k

  # 0x50000 + 0xfb0000 = 16 MiB，与 DTS 的 firmware 分区严格一致
  IMAGE_SIZE := 16064k

  # 厂家固件实测：ath9k 无线、sdhci=okay（有 SD 卡槽）、xhci=okay、nand=disabled
    DEVICE_PACKAGES := kmod-ath9k kmod-mmc kmod-sdhci-mt7620 kmod-usb3 \
        kmod-usb-storage kmod-usb-storage-uas \
        kmod-fs-vfat kmod-fs-ext4 kmod-fs-exfat \
        kmod-nls-cp437 kmod-nls-iso8859-1 \
        block-mount \
        ip-full iw wpad-basic-mbedtls \
        luci luci-ssl

  IMAGES += factory.bin
  IMAGE/factory.bin := append-kernel | append-rootfs | pad-rootfs | check-size
  IMAGE/sysupgrade.bin := append-kernel | append-rootfs | pad-rootfs | append-metadata | check-size
endef
TARGET_DEVICES += hailin_hl7621s