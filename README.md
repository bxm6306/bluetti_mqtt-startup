# bluetti_mqtt-startup


====================

A startup wrapper script that assists with starting [bluetti_mqtt](https://github.com/warhammerkid/bluetti_mqtt) with the [Home Assistant](https://github.com/home-assistant/) service. It has been tested on a Raspberry Pi 3B running Debian GNU/Linux 11 (bullseye).

- [Motivation](#motivation)
- [Files](#files)
- [Usage](#usage)
- [License](#license)

Motivation
----------

I run Bluetti_mqtt with two Bluetti power stations with Home Assistant running on my Raspberry Pi 3B and needed a more reiable way to send Bluetti staton metrics to my Home Assistant service when my RPI3 restarts which I do once a day. 


Files
-----

| File            | Description                                                                                     |
| ------------------------ |------------------------------------------------------------------------------------------------ |
| **start_bluetti_mqtt.sh** | The startup script                          |

Usage
-----

Define the required variables within start_bluetti_mqtt.sh and run it at system startup as root. This can be done by adding it to the end of your /etc/rc.local script.

| Variable Name            | Description                                                                                     | Example           |
| ------------------------ |------------------------------------------------------------------------------------------------ | ----------------- |
| **homeassistant_hostname** | The hostname of your Home Assistant service                                                   | localhost         |
| **homeassistant_port** | The port of your Home Assistant service                                                           | 8123              |
| **mqtt_broker_hostname** | The hostname of your MQTT broker account                                                        | localhost         |
| **mqtt_broker_username** | The username of your MQTT broker account                                                        | username1         |
| **mqtt_broker_password** | The password of your MQTT broker account                                                        | password123       |
| **mqtt_broker_port** | The MQTT broker service port                                                                        | 1883              |
| **mqtt_scan_interval** | How often (in seconds) to push new Bluetti station metrics to Home Assistant (default: 30)        | 30                |
| **station1_mac** | Bluetti station Bluetooth MAC address for discovery                                                     | 01:23:45:67:89:AB |
| **station2_mac** | An optional second Bluetti station Bluetooth MAC address for discovery                                  | 01:23:45:67:89:AC |
| **station1_description** | Description for Station 1                                                                       | AC200Max          |
| **station2_description** | Description for Station 2                                                                       | AC300             |

I also re-run this script every hour via crontab which you can edit by running **crontab -e** and adding the following line

0 * * * * bash /yourpathgoeshere/start_bluetti_mqtt.sh

License
-------
[![license](https://img.shields.io/github/license/ralish/bash-script-template)](https://choosealicense.com/licenses/mit/)
All content is licensed under the terms of [The MIT License](LICENSE).
