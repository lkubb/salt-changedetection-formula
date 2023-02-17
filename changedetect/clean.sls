# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``changedetect`` meta-state
    in reverse order, i.e. stops the changedetection, playwright_chrome, selenium_chrome services,
    removes their configuration and then removes their containers.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}
{%- set prefix = ".standalone" if changedetect.install.method != "compose-module" else "" %}

include:
  - {{ prefix }}.service.clean
  - {{ prefix }}.config.clean
  - {{ prefix }}.package.clean
