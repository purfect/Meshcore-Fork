# Meshcore-Fork: reguläre Companion-Firmware

Aktuelle Fork-Version: `v1.0.5`

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

Auto-Reply-Regeln (Kanal/Keyword/Antworttext) sind aktuell nur über die
Kommandozeile konfigurierbar (siehe unten).

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
fest begrenzte Auswahl von höchstens fünf Companion-Zielen. So werden nicht mehr
über hundert Matrix-Jobs gestartet. Aktuell werden diese Ziele gebaut:

- `Xiao_S3_WIO_companion_radio_usb`
- `Xiao_S3_WIO_companion_radio_ble`
- `Heltec_v3_companion_radio_usb`
- `Heltec_v3_companion_radio_ble`
- `RAK_4631_companion_radio_ble`

Bei einem manuellen Start über **Actions → Build End-Device Companion Firmwares
→ Run workflow** erscheint ein Dropdown. Dort kann gezielt der Seeed XIAO
ESP32-S3 mit Wio-SX1262, der Heltec V3 oder der RAK4631 ausgewählt werden, jeweils
als USB-, BLE- oder kombinierter Build. Zusätzlich steht das Preset **Alle fünf
Release-Ziele** zur Verfügung. Standardmäßig werden beim manuellen Start nur die
beiden XIAO-Varianten gebaut. Tag- und Release-Builds verwenden unabhängig vom
Dropdown immer die fünf oben aufgeführten Release-Ziele.

Damit entstehen für den Seeed XIAO ESP32-S3 mit Wio-SX1262 sowohl die normale
Update-Datei als auch die vollständige `-merged.bin` für USB und BLE. Bei einem
veröffentlichten Release werden die Firmware-Dateien an genau diesen Release
angehängt, ohne dessen Titel oder Beschreibung zu überschreiben. Pro Ziel werden
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
