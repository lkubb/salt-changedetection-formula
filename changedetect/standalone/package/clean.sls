# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.standalone.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}

include:
  - {{ sls_config_clean }}

{%- if changedetect._podman_compose and not changedetect.install.podman.compose_systemd %}

Changedetection systemd units are absent:
  file.absent:
    - names:
{%-   for cnt in changedetect._containers %}
      - {{ changedetect._services | path_join(cnt ~ ".service") }}
{%-   endfor %}
{%-   if changedetect.install.podman.compose_pods %}
      - {{ changedetect._services | path_join("pod_changedetection.service") }}
{%-   endif %}
{%- endif %}

# for podman with systemd services, this is unnecessary
Changedetection containers are absent:
  cmd.run:
    - name: |
        {{ changedetect._compose }} -f '{{ changedetect.lookup.paths.compose }}' \
          --project-name changedetection \
{%- if changedetect._podman_compose %}
{%-   if changedetect._podman_nopod_switch %}
          --no-pod \
{%-   elif changedetect.install.podman.compose_pods and not changedetect.install.podman.compose_systemd %}
          --pod-args='--infra=true --share=""' \
{%-   endif %}
{%- endif %}
        down
{%- if changedetect._podman_compose and changedetect.install.podman.rootless %}
    - runas: {{ changedetect.lookup.user.name }}
{%- endif %}
    - onlyif:
      - fun: file.file_exists
        path: {{ changedetect.lookup.paths.compose }}
    - require:
      - sls: {{ sls_config_clean }}

Changedetection container definitions are absent:
  file.absent:
    - names:
      - {{ changedetect.lookup.paths.compose }}
      - {{ changedetect.lookup.paths.config_changedetection }}
      - {{ changedetect.lookup.paths.config_selenium_chrome }}
      - {{ changedetect.lookup.paths.config_playwright_chrome }}
    - require:
      - Changedetection containers are absent

Changedetection user has lingering disabled:
  cmd.run:
    - name: loginctl disable-linger '{{ changedetect.lookup.user.name }}'
    # avoid errors when the user does not exist
    - onlyif:
      - loginctl show-user '{{ changedetect.lookup.user.name }}' --property=Linger | grep -q yes

Changedetection user account is absent:
  user.absent:
    - name: {{ changedetect.lookup.user.name }}
