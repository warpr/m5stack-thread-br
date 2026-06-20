# Flashing the M5Stack Thread Border Router Firmware on macOS

### Preparation

Before you can flash the firmware, you should build it,
see [BUILD.md](BUILD.md).

I'm assuming you're building the firmware on a linux box in your
homelab, and then wish to flash on a macbook.

Adapt and then run `bin/get-firmware` to copy the firmware
from your linux box to your laptop.

### Flashing

Connect your M5Stack Thread Border Router, and run the following:

```sh
ls -lh /dev/cu.*
```

You should see `/dev/cu.usbmodem101`, if that exact file doesn't show
up but something similar does, you probably should edit `bin/flash`.

Finally, run `bin/flash` to flash the firmware.
