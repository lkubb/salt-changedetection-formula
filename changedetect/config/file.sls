# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

changedetection environment file is managed:
  file.managed:
    - name: {{ changedetect.lookup.paths.config_changedetection }}
    - source: {{ files_switch(
                    ["changedetection.env", "changedetection.env.j2"],
                    config=changedetect,
                    lookup="changedetection environment file is managed",
                 )
              }}
    - mode: '0640'
    - user: root
    - group: {{ changedetect.lookup.user.name }}
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ changedetect.lookup.user.name }}
    - watch_in:
      - Changedetection is installed
    - context:
        changedetect: {{ changedetect | json }}

selenium_chrome environment file is managed:
  file.{{ "managed" if changedetect.selenium.enable else "absent" }}:
    - name: {{ changedetect.lookup.paths.config_selenium_chrome }}
{%- if changedetect.selenium.enable %}
    - source: {{ files_switch(
                    ["selenium_chrome.env", "selenium_chrome.env.j2"],
                    config=changedetect,
                    lookup="selenium_chrome environment file is managed",
                 )
              }}
    - mode: '0640'
    - user: root
    - group: {{ changedetect.lookup.user.name }}
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ changedetect.lookup.user.name }}
    - watch_in:
      - Changedetection is installed
    - context:
        changedetect: {{ changedetect | json }}
{%- endif %}

playwright_chrome environment file is managed:
  file.{{ "managed" if changedetect.playwright.enable else "absent" }}:
    - name: {{ changedetect.lookup.paths.config_playwright_chrome }}
{%- if changedetect.playwright.enable %}
    - source: {{ files_switch(
                    ["playwright_chrome.env", "playwright_chrome.env.j2"],
                    config=changedetect,
                    lookup="playwright_chrome environment file is managed",
                 )
              }}
    - mode: '0640'
    - user: root
    - group: {{ changedetect.lookup.user.name }}
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ changedetect.lookup.user.name }}
    - watch_in:
      - Changedetection is installed
    - context:
        changedetect: {{ changedetect | json }}
{%- endif %}

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
