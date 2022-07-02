# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_service_clean = tplroot ~ '.standalone.service.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}

include:
  - {{ sls_service_clean }}

# does not delete settings json file (and data) to prevent accidental data loss
# something needs to be in here to require this file
changedetect-config-clean-file-absent:
  test.nop:
    - require:
      - sls: {{ sls_service_clean }}
