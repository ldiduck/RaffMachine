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

## Bring Alexa devices into HA

Goal: everything controllable through Alexa is also integrated in HA, preferably locally.

- [ ] Export the device list from the Alexa app (Devices → All Devices) and reconcile it against the table below
- [ ] Identify the unknown LAN devices: 192.168.1.161 (78:1C:3C:…) and 192.168.1.163 (`none.local`)
- [x] TP-Link Kasa HS103 "Bedroom Lamp" (.157) and "Kitchen Fan" (.183) → `tplink` (legacy local protocol, no login)
- [ ] TP-Link Kasa HS103 at .154: newer firmware (KLAP, port 80 only). Add in the UI with TP-Link account credentials
      (Settings → Devices & services → Add integration → TP-Link Smart Home → host `192.168.1.154`)
- [ ] iRobot Roomba at .160 → `roomba` integration (local; requires pressing the robot's Home button during setup)
- [ ] RYSE SmartBridge (shades) at .167 → pair via HomeKit (`homekit_controller`)
- [ ] Echo-hub devices (Zigbee/Bluetooth/Matter paired directly to an Echo, so invisible on the LAN): decide per device.
      Re-pair to HA (needs a Zigbee/Thread radio such as a ZBT-2) or leave on Alexa
- [ ] Optional: Alexa Media Player (HACS) for the 4 Echo devices (.169, .170, .179, .180): TTS and announcements from HA
- [ ] Optional: link the Home Assistant skill in the Alexa app (Nabu Casa cloud already has Alexa enabled, but the
      skill isn't linked) so voice control goes Alexa → HA instead of directly to vendor skills
- [ ] Assign areas to every new device and add groups/automations under `packages/`

Already in HA: Cielo ×5, Miele ×2, Lutron Caséta, Ring, Chromecast.

## Cleanup

- [ ] Delete the disabled HomeKit Device integration (Settings → Devices & services). It duplicated the
      Lutron devices, and deleting it frees the bridge's HomeKit pairing slot.

## Next config

- [ ] `packages/presence.yaml`: when leaving home, turn off `light.interior_lights`, `switch.entry_lights`
      and the Cielo climate units
