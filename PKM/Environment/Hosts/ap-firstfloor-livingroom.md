---
name: ap-firstfloor-livingroom
host_type: access-point
status: active
provider: ubiquiti
os: UniFi AP OS
location: home — first floor, living room
specs: UniFi AP AC Pro (UAP-AC-PRO); 3x3 MIMO; 802.11ac Wave 1; 2.4 GHz + 5 GHz dual-band
ip_public: ""
ip_lan: 192.168.1.114
ip_tailscale: ""
dns_name: ""
access: managed via [[uck-g2-plus]] controller
secrets_ref: managed by UniFi controller
renewal_date: ""
monthly_cost: ""
mac_address: "78:8A:20:89:D3:ED"
firmware: "6.8.2"
linked_accounts: []
tags:
  - network
  - unifi
  - wifi
---

# ap-firstfloor-livingroom

UniFi AP AC Pro — first floor, living room. Factory reset and adopted into [[uck-g2-plus]] on 2026-06-13 as part of the homelab network rebuild. Firmware updated from an older version to 6.8.2 during adoption.

## RF configuration

| Band | Channel | Width | Mode |
|---|---|---|---|
| 2.4 GHz | 1 | 20 MHz | WiFi 4 (802.11n) |
| 5 GHz | **36** | 40 MHz | WiFi 5 (802.11ac) |

**5 GHz channel 36** — deliberately different from [[ap-secondfloor-masterbedroom]] (ch. 149) to eliminate co-channel interference. This was the root cause of persistent Wi-Fi dropouts on [[jeff-laptop]] (MediaTek MT7921 stalls its data path when two same-SSID APs share a 5 GHz channel).

## SSIDs broadcast

- Downton Abbey (Default/LAN, 2.4 + 5 GHz, Fast Roaming enabled)
- Downton Abbey-IOT (IoT VLAN 20, 2.4 GHz only)
- Downton Abbey-Guest (Guest VLAN 30, 2.4 + 5 GHz)

## Connected to

- Uplink: [[us-24]] (wired, GbE)

## Open questions

- Consider enabling Band Steering once co-channel fix is confirmed stable.
- Rename device in controller from "AC Pro" to "AP-FirstFloor-LivingRoom" for clarity.
