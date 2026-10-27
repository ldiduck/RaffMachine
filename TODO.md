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

- [x] Inventory devices from the Alexa app (2026-10-27, per-device settings screenshots) and a LAN scan
- [ ] Identify the unknown LAN devices: 192.168.1.161 (78:1C:3C:…, no common ports open) and
      192.168.1.163 (`none.local`, TCP 8888 open but not HTTP). Likely candidates: the Vornado fan and the ice maker
- [x] Schlage locks → `schlage` integration (cloud): `lock.front_door` (Encode, BE489WB2) and `lock.vestibule`
      (Arrive, be459wb). Both are unexposed from Alexa, Google and Assist. HA can't restrict unlock per entity,
      so voice exposure is the control
- [ ] Decide on auto-lock: both locks have `select.*_auto_lock_time` = 0 (off)
- [ ] Battery automation: notify the phone when `sensor.vestibule_battery` / `sensor.front_door_battery_2` < 20%
      (the `_2` suffix is because the Ring doorbell already took `sensor.front_door_battery`; rename both for clarity)
- [ ] Vornado Transom fan "exhaust" (Lounge): no HA integration known, and it looks Alexa-only (Alexa Connect Kit
      style settings page). Fallback: control it via Alexa Media Player (HA → Alexa → fan, no state feedback)
- [ ] EcozyHome Smart Ice Machine "Lounge Ice Maker" (Lounge), connected via the EcozyHome skill. Check whether
      the EcozyHome app is a Tuya white-label (Smart Life login works?) → built-in `tuya` integration
- [x] TP-Link Kasa HS103 "Bedroom Lamp" (.157) and "Kitchen Fan" (.183) → `tplink` (legacy local protocol, no login)
- [ ] TP-Link Kasa HS103 at .154: newer firmware (KLAP, port 80 only). Add in the UI with TP-Link account credentials
      (Settings → Devices & services → Add integration → TP-Link Smart Home → host `192.168.1.154`)
- [ ] iRobot Roomba at .160 → `roomba` integration (local; requires pressing the robot's Home button during setup)
- [ ] RYSE SmartBridge (.167, d0:16:f0:20:81:25, FW 5.2.0) → pair via HomeKit (`homekit_controller`).
      Shades: "patio shade", "bedroom east", "bedroom West". HA hasn't discovered it, so it's either already paired
      elsewhere (unpair first) or HomeKit is off. Needs the 8-digit setup code (RYSE app ☰ menu or bridge sticker)
- [ ] Echo-hub devices (Zigbee/Bluetooth/Matter paired directly to an Echo): none found in the inventory. Revisit if
      one turns up; it would need a Zigbee/Thread radio (e.g. ZBT-2) to move to HA
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
