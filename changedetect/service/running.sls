# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}

include:
  - {{ sls_config_file }}

{%- if changedetect._podman_compose %}

Changedetection containers are running:
{%-   if not changedetect.installation.podman.rootless %}
  service.running:
    - names:
{%-     for srv in changedetect._service_names %}
      - {{ srv }}
{%-     endfor %}
    - enable: true
    - watch:
      - Changedetection containers are present
      - file: {{ changedetect.lookup.paths.data | path_join("url-watches.json") }}

{%-   else %}
  cmd.run:
  # systemctl needs XDG_RUNTIME_DIR and DBUS_SESSION_BUS_ADDRESS set.
  # Those depend on the UID (and need lingering). Two solutions:
  # 1. hardcode the UID (easiest)
  # 2. sh -c 'XDG_RUNTIME_DIR="/run/user/$(whoami | id -u)" DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" systemctl --user enable --now pod_changedetection.service'
  # (3. fail on the first run because jinja is run first and cannot inspect a nonexistent user)
    - names:
{%-     for srv in changedetect._service_names %}
      - systemctl --user enable --now {{ srv }}:
        - unless:
          - |
              export XDG_RUNTIME_DIR="/run/user/$(whoami | id -u)"
              export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
              test -n "$(systemctl --user is-enabled {{ srv }} \
                | grep enabled)" \
              || exit 1
              test -n "$(systemctl --user is-active {{ srv }} \
                | grep active | grep -v inactive)" \
              || exit 1
{%-     endfor %}
    - env:
      - XDG_RUNTIME_DIR: /run/user/{{ changedetect.lookup.user.uid }}
      - DBUS_SESSION_BUS_ADDRESS: unix:path=/run/user/{{ changedetect.lookup.user.uid }}/bus
    - runas: {{ changedetect.lookup.user.name }}
    - require:
      - Changedetection user has lingering enabled

# During first setup, this restarts the services directly after
# activation, which is not pretty, but does not matter.
Changedetection containers are restarted:
  cmd.run:
    - names:
{%-     for srv in changedetect._service_names %}
      - systemctl --user restart {{ srv }}
{%-     endfor %}
    - env:
      - XDG_RUNTIME_DIR: /run/user/{{ changedetect.lookup.user.uid }}
      - DBUS_SESSION_BUS_ADDRESS: unix:path=/run/user/{{ changedetect.lookup.user.uid }}/bus
    - runas: {{ changedetect.lookup.user.name }}
    - onchanges:
      - Changedetection containers are present
      - file: {{ changedetect.lookup.paths.data | path_join("url-watches.json") }}
    - require:
      - Changedetection user has lingering enabled
{%-   endif %}

{%- else %}

Changedetection containers are running:
  cmd.run:
    - name: |
        {{ changedetect._compose }} -f '{{ changedetect.lookup.paths.compose }}' \
          --project-name changedetection \
        start

Changedetection container has correct settings applied:
  cmd.run:
    - name: |
        {{ changedetect._compose }} -f '{{ changedetect.lookup.paths.compose }}' \
          --project-name changedetection \
        restart
    - onchanges:
      - Changedetection containers are present
      - file: {{ changedetect.lookup.paths.data | path_join("url-watches.json") }}
{%- endif %}
