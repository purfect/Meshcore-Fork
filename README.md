# MeshCore AutoPong / AutoReply Fork

Dieser Fork basiert auf dem offiziellen
[MeshCore-Projekt](https://github.com/meshcore-dev/MeshCore). Neu hinzugekommen
sind ausschließlich **AutoPong** und **AutoReply** für die normale
Companion-Firmware. Für alle allgemeinen MeshCore-Funktionen, unterstützte Apps
und die Bedienung gilt die [offizielle Dokumentation](https://docs.meshcore.io/).

## AutoPong

AutoPong beantwortet `ping`-Nachrichten im Kanal `#ping` direkt auf dem
Funkgerät – auch wenn keine App verbunden ist. Die Antwort nennt den Absender
und die Zahl der empfangenen Hops, optional ergänzt um einen hinterlegten Ort:

```text
@[Name] Pong - 2 Hops in 12345
```

AutoPong ist standardmäßig aktiv. Eigene Nachrichten werden ignoriert und ein
Cooldown von 15 Sekunden verhindert zu häufige Antworten.

## AutoReply

AutoReply ermöglicht bis zu vier dauerhaft gespeicherte Antwortregeln. Jede
Regel besteht aus Kanal, Suchwort und Antworttext. Kanal und Suchwort werden
ohne Beachtung der Groß-/Kleinschreibung geprüft; das Suchwort darf irgendwo im
Nachrichtentext stehen.

Im Antworttext sind folgende Platzhalter möglich:

- `{name}` – Name des Absenders
- `{plz}` – hinterlegter AutoPong-Ort
- `{hops}` – Anzahl der empfangenen Hops

Auch AutoReply arbeitet ohne verbundene App, ignoriert eigene Nachrichten und
verwendet einen eigenen 15-Sekunden-Cooldown je Regel.

## Konfiguration

AutoPong kann über die Companion-Einstellungen (`autopong`, `autopong_loc`) und
AutoReply über die dafür vorgesehenen Companion-Befehle konfiguriert werden.
Auf BLE-Companion-Geräten stehen außerdem über den seriellen Debug-Port mit
115200 Baud unter anderem diese Befehle bereit:

```text
autopong on
autopong off
autopong location 12345
autoreply list
autoreply set 1 public hallo Hallo {name}, ich bin gerade nicht erreichbar.
autoreply delete 1
autoreply clear
```

Der angegebene Kanal muss zuvor regulär auf dem Companion eingerichtet worden
sein. Einstellungen und Regeln bleiben nach einem Neustart erhalten.

## Firmware

Fertige BLE-Companion-Pakete gibt es unter
[Releases](https://github.com/purfect/Meshcore-Fork/releases) für:

- Seeed XIAO ESP32-S3 mit Wio-SX1262
- LilyGO T-Echo
- ThinkNode M3 und M7
- Heltec V3 und V4

## Lizenz

Wie das Upstream-Projekt steht dieser Fork unter der MIT-Lizenz.
