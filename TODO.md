# TODO

## Govee H5179 sensors (Bluetooth)

The Green has no Bluetooth radio, so `govee_ble` can't hear the sensors yet.

- [x] Order TP-Link UB500 (Realtek RTL8761B) and a USB-A male-to-female extension (1–2 m, USB 2.0 is fine)
- [ ] Plug the UB500 into the Green via the extension, ideally on a USB 2.0 port, at least a foot or two from the box
- [ ] Confirm HA detects the adapter (Settings → Devices & services → Bluetooth)
- [ ] Confirm `govee_ble` discovers each H5179 and add them
- [ ] Assign areas and give the sensors meaningful entity IDs
- [ ] Add any sensor-based config (e.g. climate automations) to a `packages/` file
- [ ] If some sensors are out of range: add an ESPHome Bluetooth proxy (ESP32, e.g. M5Stack Atom Lite) near them

Fallback if Bluetooth doesn't work out: Govee cloud API (key on hand; store it as the `GOVEE_API_KEY` env var).
It needs a custom integration, since HA has no built-in Govee cloud sensor support.

## Cleanup

- [ ] Delete the disabled HomeKit Device integration (Settings → Devices & services). It duplicated the
      Lutron devices, and deleting it frees the bridge's HomeKit pairing slot.

## Next config

- [ ] `packages/presence.yaml`: when leaving home, turn off `light.interior_lights`, `switch.entry_lights`
      and the Cielo climate units
