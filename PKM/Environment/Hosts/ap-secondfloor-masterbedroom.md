---
name: ap-secondfloor-masterbedroom
host_type: access-point
status: active
provider: ubiquiti
os: UniFi AP OS
location: home — second floor, master bedroom
specs: UniFi AP AC Pro (UAP-AC-PRO); 3x3 MIMO; 802.11ac Wave 1; 2.4 GHz + 5 GHz dual-band
ip_public: ""
ip_lan: 192.168.1.110
ip_tailscale: ""
dns_name: ""
access: managed via [[uck-g2-plus]] controller
secrets_ref: managed by UniFi controller
renewal_date: ""
monthly_cost: ""
mac_address: "78:8A:20:2C:68:75"
firmware: "6.8.2"
linked_accounts: []
tags:
  - network
  - unifi
  - wifi
---

# ap-secondfloor-masterbedroom

UniFi AP AC Pro — second floor, master bedroom. Factory reset and adopted into [[uck-g2-plus]] on 2026-06-13 as part of the homelab network rebuild. Required two adoption attempts — first attempt stalled at firmware 4.3.24 (Device Unreachable); second attempt succeeded and updated to 6.8.2.

## RF configuration

| Band | Channel | Width | Mode |
|---|---|---|---|
| 2.4 GHz | 11 | 20 MHz | WiFi 4 (802.11n) |
| 5 GHz | **149** | 40 MHz | WiFi 5 (802.11ac) |

**5 GHz channel 149** — deliberately different from [[ap-firstfloor-livingroom]] (ch. 36) to eliminate co-channel interference that was causing persistent dropouts on [[jeff-laptop]].

**Note:** This AP's BSSID (78:8A:20:2C:68:75) was previously identified in Windows Wi-Fi logs as the AP Jeff's laptop was connected to on 2.4 GHz during the co-channel diagnosis (2026-06-13).

## SSIDs broadcast

- Downton Abbey (Default/LAN, 2.4 + 5 GHz, Fast Roaming enabled)
- Downton Abbey-IOT (IoT VLAN 20, 2.4 GHz only)
- Downton Abbey-Guest (Guest VLAN 30, 2.4 + 5 GHz)

## Connected to

- Uplink: [[us-24]] (wired, GbE)

## Open questions

- Rename device in controller from "AC Pro" to "AP-SecondFloor-MasterBedroom" for clarity.
- Consider enabling Band Steering once co-channel fix confirmed stable.
