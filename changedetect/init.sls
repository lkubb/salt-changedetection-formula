# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}
{%- set prefix = ".standalone" if changedetect.install.method != "compose-module" else "" %}

include:
  - {{ prefix }}.package
  - {{ prefix }}.config
  - {{ prefix }}.service
