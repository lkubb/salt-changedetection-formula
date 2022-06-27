# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}

Changedetection containers are dead:
{%- if changedetect._podman_compose %}
{%-   if not changedetect.installation.podman.rootless %}
  service.dead:
    - names:
{%-     for srv in changedetect._service_names %}
      - {{ srv }}
{%-     endfor %}
    - enable: false

{%-   else %}
  cmd.run:
    - names:
{%-     for srv in changedetect._service_names %}
      - systemctl --user cat {{ srv }} 2>1 >/dev/null || exit 0 && systemctl --user disable --now {{ srv }}
{%-     endfor %}
    - env:
      - XDG_RUNTIME_DIR: /run/user/{{ changedetect.lookup.user.uid }}
      - DBUS_SESSION_BUS_ADDRESS: unix:path=/run/user/{{ changedetect.lookup.user.uid }}/bus
    - runas: {{ changedetect.lookup.user.name }}
{%-   endif %}

{%- else %}
  cmd.run:
    - name: |
        {{ changedetect._compose }} -f '{{ changedetect.lookup.paths.compose }}' \
          --project-name changedetection \
        stop
    - onlyif:
      - fun: file.file_exists
        path: {{ changedetect.lookup.paths.compose }}
{%- endif %}
