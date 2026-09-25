# Meshcore-Fork: reguläre Companion-Firmware

Aktuelle Fork-Version: `v1.0.12`

Dieser Fork basiert auf der offiziellen MeshCore-Firmware und behält die normalen
Companion-Schnittstellen bei. Damit kann das benachbarte `Meshcore-Dashboard` über
USB oder Bluetooth verbunden werden.

## Autonomes Auto-Pong und Auto-Reply

Alle regulären USB- und Bluetooth-Companion-Ziele enthalten zusätzlich eine
autonome Antwortlogik. Sie arbeitet direkt im Funkgerät und benötigt keine
geöffnete oder verbundene App. Dazu gehört unter anderem das Seeed XIAO ESP32-S3
mit Wio-SX1262. Auto-Pong ist ab Werk aktiviert. Die Funktion existiert
ausschließlich in der Companion-Firmware; Repeater, Room-Server und Sensoren
leiten Nachrichten weiterhin nur normal weiter und antworten nicht selbst.

- Auto-Pong kann über die lokale serielle Kommandozeile ein- und ausgeschaltet
  werden. Im Kanal `#ping` beantwortet es Nachrichten mit dem Keyword `ping` mit
  `@[Name] Pong - x Hops`.
- Bis zu vier Auto-Reply-Regeln können mit Kanal, Keyword und frei wählbarem
  Antworttext gespeichert werden. Die Regeln sind nach einem Neustart weiterhin
  vorhanden.
- Ein eigener Cooldown von 15 Sekunden je Regel begrenzt automatische Antworten.
- Eigene Nachrichten werden ignoriert, wodurch Antwortschleifen vermieden werden.

Die normalen Companion-Schnittstellen bleiben erhalten, sodass das Gerät weiterhin
per USB oder Bluetooth mit einer App verbunden werden kann. Wenn im Dashboard
zusätzlich Auto-Pong oder eine identische Auto-Reply-Regel aktiv ist, sollte diese
dort abgeschaltet werden, damit nicht Firmware und Dashboard doppelt antworten.

## RPINFO-Repeaterkanal

Repeater-Firmwares enthalten den fest integrierten verschlüsselten Kanal `#rpinfo`
mit dem Secret `4ce21579abb524e1e61e5244641bc8ea`. Im Kanal können aus der regulären
MeshCore-App diese Befehle gesendet werden:

```text
status                           Kurzer Online- und Paketstatus
info                             Firmware, Node-Name und Funkparameter
uptime                           Zeit seit dem letzten Neustart
```

Jeder empfangende Repeater antwortet als normale verschlüsselte Kanalnachricht.
Andere Kanäle und alle bisherigen Repeater-Funktionen bleiben unverändert. Pro
Repeater gilt ein Cooldown von 15 Sekunden gegen Antwortfluten. Das Repeater-Target
`Xiao_S3_WIO_repeater` wird bei `autoreply-*`-Release-Tags zusätzlich zur normalen
Companion-Matrix gebaut.

## Konfiguration über die App (Custom Variables)

`autopong` (an/aus) und `autopong_loc` (Ortsangabe, z. B. PLZ) stehen als normale
**Custom Variables** im Companion-Protokoll zur Verfügung (`CMD_GET_CUSTOM_VARS` /
`CMD_SET_CUSTOM_VAR`) und sind damit über die reguläre App per USB oder Bluetooth
setzbar – ganz ohne serielles Terminal. In der App unter den Geräteeinstellungen
den Bereich **"Custom Variables"** (bzw. "Node Variables"/"Advanced Settings",
je nach App-Version) öffnen:

- `autopong` auf `1` (an) oder `0` (aus) setzen
- `autopong_loc` auf den gewünschten Text (z. B. `01705`) setzen, oder auf
  `clear`/`-`, um die Ortsangabe zu entfernen

Die vier Auto-Reply-Regeln werden über das Lesezeichen-Hub-Modul
`meshcore-autopong_location` verwaltet. Es verwendet die Companion-Befehle
`GET_AUTO_REPLY_RULE` und `SET_AUTO_REPLY_RULE`; die Regeln bleiben nach einem
Neustart erhalten.

## Konfiguration über die Kommandozeile

Auf reinen Bluetooth-Zielen (`*_companion_radio_ble`) sind `autopong`- und
`autoreply`-Befehle jederzeit über den seriellen USB-Debug-Port (115200 Baud)
verfügbar, solange kein Dashboard per BLE verbunden ist – ganz ohne
Knopfdruck oder Neustart. Andere Befehle bleiben dort weiterhin gesperrt.

Für alle übrigen Befehle (`set`, `ls`, `cat`, `rm`, `rebuild`, `erase`, `reboot`, …)
sowie auf USB-Zielen (`*_companion_radio_usb`, dort belegt das Companion-Protokoll
den seriellen Port exklusiv) muss weiterhin innerhalb der ersten acht Sekunden nach
dem Start der Benutzerknopf lange gedrückt werden, um den lokalen `CLI Rescue`-Modus
zu öffnen. Danach über den seriellen Port mit 115200 Baud verbinden. Nach Änderungen
das Gerät mit `reboot` neu starten, um den normalen Companion-Modus wieder zu
verwenden.

```text
autopong                         Aktuellen Zustand und Regeln anzeigen
autopong on                      Auto-Pong einschalten
autopong off                     Auto-Pong ausschalten
autopong location 12345          Optionale Ortsangabe setzen
autopong location clear          Ortsangabe entfernen

autoreply list                   Alle Regeln anzeigen
autoreply set 1 public hallo Hallo, ich bin gerade nicht erreichbar.
autoreply set 2 test wetter Der Wetterdienst ist momentan offline.
autoreply delete 1               Regel in Slot 1 löschen
autoreply clear                  Alle Auto-Reply-Regeln löschen
```

Im Antworttext einer Auto-Reply-Regel stehen folgende Platzhalter zur Verfügung:

- `{name}`: Name des Absenders
- `{plz}`: gespeicherte Auto-Pong-Ortsangabe
- `{hops}`: Hop-Anzahl der eingegangenen Nachricht

Beispiel: `Hallo {name}, Standort {plz}, Nachricht über {hops} Hops empfangen.`

Syntax für eine Regel:

```text
autoreply set <Slot 1-4> <Kanal> <Keyword> <Antworttext>
```

Kanal und Keyword sind nicht von Groß-/Kleinschreibung abhängig. Das Keyword darf
an einer beliebigen Stelle im Nachrichtentext stehen. Der Antworttext darf
Leerzeichen enthalten. Der betreffende Kanal muss zuvor normal auf dem Companion
eingerichtet worden sein.

Der feste Auto-Pong-Kanal und der Cooldown können bei Bedarf über die Build-Defines
`AUTO_PONG_CHANNEL` und `AUTO_REPLY_COOLDOWN_MS` geändert werden. Ohne eigene
Vorgabe gelten `ping` und 15 Sekunden.

## Seeed XIAO ESP32-S3 mit Wio-SX1262

Die passenden offiziellen Build-Ziele sind bereits enthalten:

| Verbindung zum Dashboard | PlatformIO-Ziel |
| --- | --- |
| USB (empfohlen) | `Xiao_S3_WIO_companion_radio_usb` |
| Bluetooth LE | `Xiao_S3_WIO_companion_radio_ble` |
| WLAN/TCP | `Xiao_S3_WIO_companion_radio_wifi` |
| Hardware-UART | `Xiao_S3_WIO_companion_radio_serial` |

Für das vorhandene Browser-Dashboard sind USB und Bluetooth direkt unterstützt.
Der Build-Helfer verwendet ohne Parameter das USB-Ziel:

```powershell
.\tools\build-companion.ps1
```

Bluetooth kann so gebaut werden:

```powershell
.\tools\build-companion.ps1 -Target Xiao_S3_WIO_companion_radio_ble
```

Voraussetzung ist eine installierte PlatformIO-CLI (`pio`, `platformio` oder das
Python-Modul `platformio`). Das Skript legt die fertigen Dateien unter `out/` ab. Für eine vollständige
Neuinstallation auf einem ESP32-S3 ist die Datei mit `-merged.bin` geeignet; für
ein Update ohne Löschen der vorhandenen Einstellungen die normale `.bin`.

Direktes Bauen ohne Hilfsskript:

```powershell
pio run -e Xiao_S3_WIO_companion_radio_usb -t mergebin
```

Andere regulär unterstützte Geräte können mit ihrem vorhandenen
`*_companion_radio_usb`- beziehungsweise `*_companion_radio_ble`-Ziel gebaut
werden. Eine Übersicht liefert:

```powershell
pio project config | Select-String 'companion_radio_(usb|ble)'
```

## GitHub Actions und Firmware-Pakete

Der Workflow `Build End-Device Companion Firmwares` baut bei manueller Ausführung,
bei jedem neu gepushten Tag und beim Veröffentlichen eines GitHub-Releases eine
fest begrenzte Auswahl von vier BLE-Companion-Zielen und vier Repeater-Zielen.
So werden nicht mehr über hundert Matrix-Jobs gestartet. Aktuell werden diese
Ziele gebaut:

- `Xiao_S3_WIO_companion_radio_ble` / `Xiao_S3_WIO_repeater`
- `LilyGo_T-Echo_companion_radio_ble` / `LilyGo_T-Echo_repeater`
- `ThinkNode_M3_companion_radio_ble` / `ThinkNode_M3_repeater`
- `ThinkNode_M7_companion_radio_ble` / `ThinkNode_M7_repeater`

Bei einem manuellen Start über **Actions → Build End-Device Companion Firmwares
→ Run workflow** erscheint ein Dropdown. Dort kann gezielt der Seeed XIAO
ESP32-S3 mit Wio-SX1262, der LilyGO T-Echo, der ThinkNode M3 oder der ThinkNode M7
als BLE-Companion- und Repeater-Build ausgewählt werden. Zusätzlich steht das
Preset **Alle vier BLE-Companion- und Repeater-Ziele** zur Verfügung. Tag- und
Release-Builds verwenden unabhängig vom Dropdown immer alle acht Ziele.

Damit entstehen für alle vier Geräte jeweils die BLE-Companion-Datei sowie das
Repeater-Paket. Bei einem veröffentlichten Release werden die
Firmware-Dateien an genau diesen Release angehängt, ohne dessen Titel oder
Beschreibung zu überschreiben. Pro Ziel werden
nur die tatsächlich flashbaren Dateien veröffentlicht, die der jeweilige
Mikrocontroller benötigt:

- ESP32: `.bin` und `-merged.bin`
- nRF52: `.uf2` und gegebenenfalls `.zip`
- RP2040: `.uf2` und `.bin`
- STM32: `.bin` und `.hex`

Nicht vorhandene Formate werden nicht als leere oder künstliche Dateien angelegt.
Jeder Build prüft zusätzlich, ob ein für den MeshCore Web-Flasher geeignetes
Paket entstanden ist: ESP32-Builds benötigen eine normale und eine
`-merged.bin`, nRF52-Builds ein OTA-`.zip`. Fehlt eine dieser erforderlichen
Dateien, wird der betreffende Matrix-Job als fehlgeschlagen markiert. Der
Web-Flasher akzeptiert unter **Custom Firmware** `.bin` für ESP32 und `.zip` für
nRF52; ein GitHub-Artifact muss vor der Dateiauswahl zuerst entpackt werden.

## Funkparameter

Die Standardwerte der offiziellen Basis werden unverändert verwendet. Vor dem
Einsatz muss das im eigenen Mesh verwendete Frequenzprofil passen. Änderungen an
Frequenz, Bandbreite oder Spreading Factor sollten nur einheitlich für alle Nodes
im betreffenden Mesh vorgenommen werden.
