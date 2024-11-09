# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.standalone.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}

include:
  - {{ sls_package_install }}

Changedetection settings are managed:
  file.serialize:
    - name: {{ changedetect.lookup.paths.data | path_join("url-watches.json") }}
    - serializer: json
    - merge_if_exists: true
    - dataset:
        settings:
          headers: {{ changedetect.config.headers | json }}
          requests: {{ changedetect.config.requests | json }}
          application: {{ changedetect.config.app | json }}
    # Do not create the file, only modify it once it has been created.
    - create: false
