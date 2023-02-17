# vim: ft=sls

{#-
    Removes the configuration of the changedetection, playwright_chrome, selenium_chrome containers
    and has a dependency on `changedetect.service.clean`_.

    This does not lead to the containers/services being rebuilt
    and thus differs from the usual behavior.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}

include:
  - {{ sls_service_clean }}

Changedetection environment files are absent:
  file.absent:
    - names:
      - {{ changedetect.lookup.paths.config_changedetection }}
      - {{ changedetect.lookup.paths.config_playwright_chrome }}
      - {{ changedetect.lookup.paths.config_selenium_chrome }}
    - require:
      - sls: {{ sls_service_clean }}
