# TODO

## Govee H5179 sensors (Bluetooth)

The Green has no Bluetooth radio of its own; a TP-Link UB500 now provides it.

- [x] Order TP-Link UB500 and a USB-A male-to-female extension (1–2 m, USB 2.0 is fine)
      (Amazon order 111-9923630-0984235). The unit received is the Bluetooth 5.4 revision, and HA supports it
- [x] Plug the UB500 into the USB hub via a 2 m extension (2026-10-29)
- [x] Confirm HA detects the adapter (Settings → Devices & services → Bluetooth)
- [x] Confirm `govee_ble` discovers each H5179 and add them
- iBeacon Tracker was also discovered and ignored. Revisit it for room-level presence
- [ ] Assign areas and give the sensors meaningful entity IDs
- [ ] Add any sensor-based config (e.g. climate automations) to a `packages/` file
- [ ] If some sensors are out of range: add an ESPHome Bluetooth proxy (ESP32, e.g. M5Stack Atom Lite) near them

Fallback if Bluetooth doesn't work out: Govee cloud API (key on hand; store it as the `GOVEE_API_KEY` env var).
It needs a custom integration, since HA has no built-in Govee cloud sensor support.

## Z-Wave and Zigbee radios

Hardware (2026-10-29): StarTech ST7202USB powered USB 2.0 hub (run it on its power adapter) on the Green, with the
UB500 and an Aeotec Z-Stick 10 Pro (ZWA060-A, US 908.42 MHz, Z-Wave 800/LR + Zigbee 3.0) each on a 2 m AINOPE
extension, a few feet apart. The stick exposes two serial ports, one per radio; select `/dev/serial/by-id/...` paths.

- [x] Z-Wave: Z-Wave integration + Z-Wave JS add-on, on one of the stick's ports (added manually; not auto-discovered)
- [x] Zigbee: ZHA on the other port, EZSP radio, 115200 baud, software flow control
- [ ] Check Z-Wave JS is v15.8.0 or newer so the stick isn't shown as unknown

## Aqara window sensors (Zigbee, ZHA)

Six Aqara MCCGQ11LM door/window sensors (two 3-packs). They're Zigbee, so they pair through ZHA; the "Aqara Hub is
Required" label only applies to Aqara's app. Battery: CR1632 (not CR2032). Mount at ≤ 2 m.

- [ ] Pair one at a time: ZHA → Add device, hold the sensor button ~5 s until it blinks, keep it near the stick, and tap
      the button every few seconds if the interview stalls
- [ ] After each one, name it after its window and assign the area before pairing the next
- [ ] Test each by moving the magnet away and back (open ↔ closed), then mount: sensor on the frame side, magnet on the
      sash
- [ ] Four for the upstairs windows; two spares (candidates: front door, vestibule, alongside the lock automations)
- [ ] Buy spare CR1632 cells
- [ ] Add window-open logic to `packages/` (e.g. warn when leaving with a window open, or pause the Cielo units)

## Bring Alexa devices into HA

Goal: everything controllable through Alexa is also integrated in HA, preferably locally.

- [x] Inventory devices from the Alexa app (2026-10-27, per-device settings screenshots) and a LAN scan
- [ ] Identify unknown LAN devices (no hostname, no common ports open): .161 (78:1C:3C), .80/.173 (same MAC
      5C:E7:53:B0:48:6A), .174 (5C:E7:53), .172 (`lwip0`, an embedded Wi-Fi stack), .178 (`dhcp_client`).
      Likely candidates include the Vornado fan and the ice maker. (.163 turned out to be an Echo)
- [x] Schlage locks → `schlage` integration (cloud): `lock.front_door` (Encode, BE489WB2) and `lock.vestibule`
      (Arrive, be459wb). Both are unexposed from Alexa, Google and Assist. HA can't restrict unlock per entity,
      so voice exposure is the control
- [ ] Decide on auto-lock: both locks have `select.*_auto_lock_time` = 0 (off)
- [x] Battery alert (`packages/locks.yaml`): push to the phone when a lock battery is < 20%, repeated daily at
      09:00 while low. Entities renamed to `sensor.front_door_lock_battery` / `sensor.vestibule_lock_battery`
      (the Ring doorbell owns `sensor.front_door_battery`)
- [ ] Vornado Transom fan "exhaust" (Lounge): no HA integration known, and it looks Alexa-only (Alexa Connect Kit
      style settings page). Fallback: control it via Alexa Media Player (HA → Alexa → fan, no state feedback)
- [ ] EcozyHome Smart Ice Machine "Lounge Ice Maker" (Lounge), connected via the EcozyHome skill. Check whether
      the EcozyHome app is a Tuya white-label (Smart Life login works?) → built-in `tuya` integration
- [x] TP-Link Kasa HS103 "Bedroom Lamp" (.157) and "Kitchen Fan" (.183) → `tplink` (legacy local protocol, no login)
- [x] TP-Link Kasa HS103 "Lounge Fan" (.154) → `tplink` (newer KLAP firmware, added with TP-Link credentials).
      All three plugs assigned to areas: Lounge Fan → Lounge, Kitchen Fan → Kitchen, Bedroom Lamp → Bedroom
- [ ] iRobot Roomba at .160 → `roomba` integration (local). HA discovers it; needs someone at the robot:
  1. Roomba on its dock; close the iRobot app (the robot allows one local connection at a time)
  2. Settings → Devices & services → Add integration → **iRobot Roomba and Braava** → pick `Roomba (192.168.1.160)`
  3. At the "link" step: hold the Home button ~2 s until it beeps, then click Submit within ~30 s
  4. Assign it to the area of its dock on the First Floor
- [ ] RYSE SmartBridge (.167, d0:16:f0:20:81:25, FW 5.2.0) → pair via HomeKit (`homekit_controller`).
      Shades: "patio shade", "bedroom east", "bedroom West". HA hasn't discovered it, so it's either already paired
      elsewhere (unpair first) or HomeKit is off. Needs the 8-digit setup code (RYSE app ☰ menu or bridge sticker)
- [ ] Echo-hub devices (Zigbee/Bluetooth/Matter paired directly to an Echo): none found in the inventory. Revisit if
      one turns up; it would need a Zigbee/Thread radio (e.g. ZBT-2) to move to HA
- [ ] Echo devices → Alexa Media Player: 5 Echoes at .163, .169, .170, .179, .180 (port fingerprint
      4070/55442/55443/8888). **Waiting for HA 2026.11** (expected ~Nov 4), which replaces HACS with the built-in
      Marketplace; decided not to install HACS now. Then:
  1. Update HA to 2026.11
  2. Settings → Marketplace → install Alexa Media Player, restart
  3. Sign in to Amazon in the HA UI (email, password, 2FA)
  4. Name the Echoes and assign rooms; Vornado fan control via Alexa commands follows from this
- [ ] Optional: link the Home Assistant skill in the Alexa app (Nabu Casa cloud already has Alexa enabled, but the
      skill isn't linked) so voice control goes Alexa → HA instead of directly to vendor skills
- [ ] Assign areas to every new device and add groups/automations under `packages/`

Already in HA: Cielo ×5, Miele ×2, Lutron Caséta, Ring, Chromecast.

## Ceiling fan with light (single-pole wall switch)

Goal: control the fan and its light separately from HA, with a Caséta Pico on the wall. Lutron makes no Caséta
canopy module, and the PD-FSQN wall fan control drives only one load, so the plan is a Zigbee canopy module.

- [ ] Find the fan's brand and model (sticker on top of the motor housing, inside the canopy, or in the light kit)
      and note whether it has a built-in remote receiver or a DC motor
- [ ] Pick a canopy module that fits and suits the motor: Hampton Bay / King of Fans Zigbee module, or Inovelli's
      canopy module (alternative: Inovelli fan/light wall switch + canopy module, which works without HA)
- [ ] Install the module in the canopy (breaker off; electrician if unsure)
- [ ] Wire the wall box so the fan always has power (line to load), and mount a Pico over it with a wall-plate bracket
- [ ] Pair the module with ZHA, then add a `packages/` automation mapping the Pico buttons to fan speed and light.
      The Pico only works through HA, so keep the fan's remote or pull chains as a fallback

## TV and soundbar

Inventory (2026-10-29):
- TV: Panasonic TC-P50S30, 50" plasma (Aug 2011). Ports: LAN (empty), HDMI 1 (ARC), HDMI 2, side HDMI and USB,
  optical out. Built-in Wi-Fi is doubtful, so assume Ethernet is needed
- Soundbar: Definitive Technology W Studio (DTS Play-Fi). HDMI in 1–3 and out; WAN MAC 60:B6:06:02:47:DB
- Chromecast on soundbar HDMI 1, already in HA

- [ ] Decide what to automate (e.g. all off when leaving, a "movie" scene, volume)
- [ ] Use the Chromecast as the main control point: enable HDMI-CEC on the TV (VIERA Link) and soundbar so casting
      wakes them and switches inputs
- [ ] TV: run Ethernet to the LAN port and try the built-in `panasonic_viera` integration. Support for a 2011
      model is uncertain; expect power-off, volume and input at best (network power-on often isn't possible)
- [ ] Soundbar: no known HA integration for Play-Fi; check whether it shows up on the LAN and if anything exposes it

## Cleanup

- [ ] Delete the disabled HomeKit Device integration (Settings → Devices & services). It duplicated the
      Lutron devices, and deleting it frees the bridge's HomeKit pairing slot.

## Next config

- [ ] `packages/presence.yaml`: when leaving home, turn off `light.interior_lights`, `switch.entry_lights`
      and the Cielo climate units
