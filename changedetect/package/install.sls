# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

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

Changedetection compose file is managed:
  file.managed:
    - name: {{ changedetect.lookup.paths.compose }}
    - source: {{ files_switch(['docker-compose.yml', 'docker-compose.yml.j2'],
                              lookup='Changedetection compose file is present'
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ changedetect.lookup.rootgroup }}
    - makedirs: True
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
