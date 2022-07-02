# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}

changedetect service is dead:
  compose.dead:
    - name: {{ changedetect.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if changedetect.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ changedetect.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if changedetect.install.rootless %}
    - user: {{ changedetect.lookup.user.name }}
{%- endif %}

changedetect service is disabled:
  compose.disabled:
    - name: {{ changedetect.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if changedetect.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ changedetect.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if changedetect.install.rootless %}
    - user: {{ changedetect.lookup.user.name }}
{%- endif %}
