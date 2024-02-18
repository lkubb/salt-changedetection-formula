# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

Changedetection user account is present:
  user.present:
{%- for param, val in changedetect.lookup.user.items() %}
{%-   if val is not none and param != "groups" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ changedetect.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false
  file.append:
    - names:
      - {{ changedetect.lookup.user.home | path_join(".bashrc") }}:
        - text:
          - export XDG_RUNTIME_DIR=/run/user/$(id -u)
          - export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

      - {{ changedetect.lookup.user.home | path_join(".bash_profile") }}:
        - text: |
            if [ -f ~/.bashrc ]; then
              . ~/.bashrc
            fi

    - require:
      - user: {{ changedetect.lookup.user.name }}

Changedetection user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ changedetect.lookup.user.name }}
    - enable: {{ changedetect.install.rootless }}
    - require:
      - user: {{ changedetect.lookup.user.name }}

Changedetection paths are present:
  file.directory:
    - names:
      - {{ changedetect.lookup.paths.base }}
    - user: {{ changedetect.lookup.user.name }}
    - group: {{ changedetect.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ changedetect.lookup.user.name }}

{%- if changedetect.install.podman_api %}

Changedetection podman API is enabled:
  compose.systemd_service_enabled:
    - name: podman.socket
    - user: {{ changedetect.lookup.user.name }}
    - require:
      - Changedetection user session is initialized at boot

Changedetection podman API is available:
  compose.systemd_service_running:
    - name: podman.socket
    - user: {{ changedetect.lookup.user.name }}
    - require:
      - Changedetection user session is initialized at boot
{%- endif %}

Changedetection compose file is managed:
  file.managed:
    - name: {{ changedetect.lookup.paths.compose }}
    - source: {{ files_switch(
                    ["docker-compose.yml", "docker-compose.yml.j2"],
                    config=changedetect,
                    lookup="Changedetection compose file is present",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ changedetect.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - makedirs: true
    - context:
        changedetect: {{ changedetect | json }}

Changedetection is installed:
  compose.installed:
    - name: {{ changedetect.lookup.paths.compose }}
{%- for param, val in changedetect.lookup.compose.items() %}
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- for param, val in changedetect.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - watch:
      - file: {{ changedetect.lookup.paths.compose }}
{%- if changedetect.install.rootless %}
    - user: {{ changedetect.lookup.user.name }}
    - require:
      - user: {{ changedetect.lookup.user.name }}
{%- endif %}

{%- if changedetect.install.autoupdate_service is not none %}

Podman autoupdate service is managed for Changedetection:
{%-   if changedetect.install.rootless %}
  compose.systemd_service_{{ "enabled" if changedetect.install.autoupdate_service else "disabled" }}:
    - user: {{ changedetect.lookup.user.name }}
{%-   else %}
  service.{{ "enabled" if changedetect.install.autoupdate_service else "disabled" }}:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}
