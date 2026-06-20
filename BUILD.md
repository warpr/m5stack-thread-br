# Building the M5Stack Thread Border Router Firmware with Docker

This builds the [M5Stack Thread Border Router example](examples/m5stack_thread_border_router)
using the `Dockerfile` in this directory, without installing ESP-IDF or any
toolchains locally.

## Build the Image

From the repository root:

```sh
docker build -t m5stack-thread-br .
```

This will:

1. Install ESP-IDF `release/v5.5` (the version required by this example) and
   the toolchains for ESP32-S3 and ESP32-H2.
2. Build the `ot_rcp` firmware for the ESP32-H2 (the Thread radio co-processor).
3. Build the border router firmware for the ESP32-S3, packing the RCP image
   into it.

The image is large (around 9 GB) since it bundles the full ESP-IDF toolchain.
The build itself takes several minutes, most of it spent compiling firmware.

## Extract the Firmware

Once the image is built, copy the build output out of it onto your host:

```sh
docker run --rm -v "$PWD/out":/out m5stack-thread-br \
    cp -r examples/m5stack_thread_border_router/build /out
```

This places the build directory under `./out/build`, including:

* `esp_ot_br.bin` — the border router application firmware.
* `rcp_fw.bin` — the ESP32-H2 RCP firmware, packed for auto-update.
* `bootloader/bootloader.bin`, `partition_table/partition-table.bin`,
  `ota_data_initial.bin`, `web_storage.bin` — the remaining flash images.
* `flash_args` — the flash offsets/options for all of the above.

## Flash the Firmware

Flashing requires a connection to the device's serial port, so it must be run
on the host, not from inside the container. Install
[esptool](https://github.com/espressif/esptool) (`pip install esptool`), then
from `./out/build`:

```sh
python -m esptool --chip esp32s3 -p PORT -b 460800 \
    --before default_reset --after hard_reset write_flash "@flash_args"
```

Replace `PORT` with the serial port of the M5Stack CoreS3 (e.g. `/dev/ttyACM0`
or `/dev/cu.usbmodem*`).
