# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}

include:
  - {{ sls_config_clean }}

{%- if changedetect.install.autoupdate_service %}

Podman autoupdate service is disabled for Changedetection:
{%-   if changedetect.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ changedetect.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

Changedetection is absent:
  compose.removed:
    - name: {{ changedetect.lookup.paths.compose }}
    - volumes: {{ changedetect.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if changedetect.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ changedetect.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if changedetect.install.rootless %}
    - user: {{ changedetect.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

Changedetection compose file is absent:
  file.absent:
    - name: {{ changedetect.lookup.paths.compose }}
    - require:
      - Changedetection is absent

Changedetection user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ changedetect.lookup.user.name }}
    - enable: false
    - onlyif:
      - fun: user.info
        name: {{ changedetect.lookup.user.name }}

Changedetection user account is absent:
  user.absent:
    - name: {{ changedetect.lookup.user.name }}
    - purge: {{ changedetect.install.remove_all_data_for_sure }}
    - require:
      - Changedetection is absent
    - retry:
        attempts: 5
        interval: 2

{%- if changedetect.install.remove_all_data_for_sure %}

Changedetection paths are absent:
  file.absent:
    - names:
      - {{ changedetect.lookup.paths.base }}
    - require:
      - Changedetection is absent
{%- endif %}
