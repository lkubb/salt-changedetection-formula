# vim: ft=sls

{#-
    Removes the changedetection, playwright_chrome, selenium_chrome containers
    and the corresponding user account and service units.
    Has a depency on `changedetect.config.clean`_.
    If ``remove_all_data_for_sure`` was set, also removes all data.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
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

{%- if changedetect.install.podman_api %}

Changedetection podman API is unavailable:
  compose.systemd_service_dead:
    - name: podman.socket
    - user: {{ changedetect.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ changedetect.lookup.user.name }}

Changedetection podman API is disabled:
  compose.systemd_service_disabled:
    - name: podman.socket
    - user: {{ changedetect.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ changedetect.lookup.user.name }}
{%- endif %}

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
