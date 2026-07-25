# Home Automation Platform Comparison
*Near — 2026-03-27. 3x TP-Link Tapo Matter smart plugs + APC UPS 600 + 2 always-on servers.*

---

## the question, restated

3 matter-capable smart plugs, a UPS with NUT, 2 servers. need programmatic control (API/webhooks), monitoring, and automated power event responses. is a full home automation platform justified at this scale?

---

## comparison matrix

| criteria | Home Assistant | Tapo App | Node-RED | openHAB | bare scripts |
|---|---|---|---|---|---|
| matter support | production-ready | yes (cloud) | no | experimental | impractical |
| tapo plug control | native + matter | native | community node | community binding | python-kasa |
| energy monitoring | yes, as sensors | yes, in-app only | via community node | via binding | via python-kasa |
| REST API | full, documented | none official | build-your-own | yes | build-your-own |
| webhook support | send + receive | no | excellent | yes | build-your-own |
| NUT/UPS integration | native integration | no | community node | community binding | nut-client lib |
| docker deployment | yes, 2 containers | n/a | yes, 1 container | yes, 1 container | n/a |
| RAM footprint | ~256-512MB | n/a | ~100MB | ~512MB-1GB | ~10MB |
| setup time | ~30 min | ~5 min | ~1-2 hours | ~1-2 hours | ~2-4 hours |
| always-on reliability | high | cloud-dependent | high | high | depends on code |
| long-term maintenance | low (updates via UI) | zero | medium | medium | high |

---

## recommendation: Home Assistant

**is it overkill?** no. the overhead is 2 docker containers and ~256MB RAM. what it gives back:

1. **matter support is the deciding factor.** only self-hosted platform with production-ready matter integration. pairs plugs locally, no cloud dependency
2. **NUT integration closes the loop.** UPS battery level, load, status become HA sensors. "if battery < 30% → send webhook" is a 10-line YAML automation
3. **REST API is what makes it worth it.** every plug state, every power reading, every UPS metric accessible via `curl` with a bearer token. agents can poll or subscribe via websocket
4. **the alternative is building HA yourself.** skip HA → write plug control scripts, UPS monitoring daemons, state persistence, alerting pipelines, and a dashboard. that's HA, except maintained solo with no community

---

## architecture

```
linux box (docker host)
├── home-assistant container (host network mode)
├── matter-server container
├── NUT daemon (for UPS shutdown signaling)
└── agent scripts (call HA REST API)
```

---

## critical risk: plug 1 topology

plug 1 controls the UPS that powers both servers. **never toggle plug 1 without a graceful shutdown sequence:**
1. NUT shutdown command → wait for servers to halt → then toggle if needed
2. plugs 2 and 3 can be toggled freely

**deadlock risk:** if the wifi access point is powered by the UPS on plug 1, toggling plug 1 off kills the network path to turn plug 1 back on. ensure network infrastructure power path doesn't create this loop.

---

## setup notes

- pair tapo plugs via HA's matter integration, not the tapo app (or use multi-admin matter fabrics if firmware supports it)
- NUT integration: point to `localhost` where `upsd` is listening. exposes `sensor.ups_battery`, `sensor.ups_load`, `sensor.ups_status`
- webhook automations: `rest_command` integration for outbound HTTP calls on state changes
- energy dashboard: natively supports power-monitoring plugs once paired
- disable auto-updates on tapo plugs if stability is the priority (firmware OTA can affect matter behavior)
