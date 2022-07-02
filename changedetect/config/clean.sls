# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}

include:
  - {{ sls_service_clean }}

# This does not lead to the containers/services being rebuilt
# and thus differs from the usual behavior
Changedetection environment files are absent:
  file.absent:
    - names:
      - {{ changedetect.lookup.paths.config_changedetection }}
      - {{ changedetect.lookup.paths.config_playwright_chrome }}
      - {{ changedetect.lookup.paths.config_selenium_chrome }}
    - require:
      - sls: {{ sls_service_clean }}
