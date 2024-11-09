# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as changedetect with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Changedetection user account is present:
  user.present:
    - name: {{ changedetect.lookup.user.name }}
    - home: {{ changedetect.lookup.user.home }}
    - shell: {{ changedetect.lookup.user.shell }}
    - uid: {{ changedetect.lookup.user.uid }}
    - usergroup: true
    - createhome: true
    - groups: {{ changedetect.lookup.user.groups }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false

{%- if changedetect._podman_compose and changedetect.install.podman.rootless %}

Changedetection user has lingering enabled:
  cmd.run:
    - name: loginctl enable-linger '{{ changedetect.lookup.user.name }}'
    - unless:
      - loginctl show-user '{{ changedetect.lookup.user.name }}' --property=Linger | grep -q yes
    # - creates:
    #   - /var/lib/systemd/linger/{{ changedetect.lookup.user.name }}
    - require:
      - user: {{ changedetect.lookup.user.name }}
{%- endif %}

Changedetection paths are present:
  file.directory:
    - names:
      - {{ changedetect.lookup.paths.base }}
{%- if      changedetect._podman_compose
    and not changedetect.install.podman.compose_systemd
    and     changedetect.install.podman.rootless %}
      - {{ changedetect._services }}
{%- endif %}
    - user: {{ changedetect.lookup.user.name }}
    - group: {{ changedetect.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ changedetect.lookup.user.name }}

# Currently, this formula only installs via docker-/podman-compose.
# In the future, it would be nice to have a kube for podman to play directly.

Changedetection compose file is present:
  file.managed:
    - name: {{ changedetect.lookup.paths.compose }}
    - source: {{ files_switch(['docker-compose.yml.j2'],
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

# I had those in config.file, but it seems to fit better here
# because the containers have to be recreated on changes, not restarted.
# This would be okay with `podman generate systemd --new` services though.

Changedetection environment file is managed:
  file.managed:
    - name: {{ changedetect.lookup.paths.config_changedetection }}
    - source: {{ files_switch(['changedetection.env', 'changedetection.env.j2'],
                              lookup='Changedetection environment file is managed'
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ changedetect.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - context:
        changedetect: {{ changedetect | json }}

selenium_chrome environment file is managed:
  file.{{ "managed" if changedetect.selenium.enable else "absent" }}:
    - name: {{ changedetect.lookup.paths.config_selenium_chrome }}

{%- if changedetect.selenium.enable %}
    - source: {{ files_switch(['selenium_chrome.env', 'selenium_chrome.env.j2'],
                              lookup='Selenium Chrome environment file is managed'
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ changedetect.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - context:
        changedetect: {{ changedetect | json }}
{%- endif %}

playwright_chrome environment file is managed:
  file.{{ "managed" if changedetect.playwright.enable else "absent" }}:
    - name: {{ changedetect.lookup.paths.config_playwright_chrome }}

{%- if changedetect.playwright.enable %}
    - source: {{ files_switch(['playwright_chrome.env', 'playwright_chrome.env.j2'],
                              lookup='Playwright Chrome environment file is managed'
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ changedetect.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - context:
        changedetect: {{ changedetect | json }}
{%- endif %}

# For podman, this is mostly unnecessary and only serves
# to dynamically generate the service files. They could
# be integrated into this formula. @TODO consider this
# or writing a compose execution/state module (much prettier probably)
# based on podman-compose

# This causes preexisting containers with changes
# to be stopped at this point (docker-compose at least),
# They will be started in service.running again.
Changedetection containers are present:
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
        up \
          --no-start \
          --quiet-pull \
          --remove-orphans
{%- if changedetect._podman_compose and changedetect.install.podman.rootless %}
    - runas: {{ changedetect.lookup.user.name }}
    - require:
      - user: {{ changedetect.lookup.user.name }}
{%- endif %}
    - onchanges:
      - file: {{ changedetect.lookup.paths.compose }}
      - file: {{ changedetect.lookup.paths.config_changedetection }}
      - file: {{ changedetect.lookup.paths.config_selenium_chrome }}
      - file: {{ changedetect.lookup.paths.config_playwright_chrome }}

{%- if changedetect._podman_compose and not changedetect.install.podman.compose_systemd %}

# podman-compose up seems to have some issues, probably related to
# systemd managing the service?
Systemd service is stopped before container creation:
{%-   if not changedetect.install.podman.rootless %}
  service.dead:
    - names:
{%-     for srv in changedetect._service_names %}
      - {{ srv }}
{%-     endfor %}
{%-   else %}
  cmd.run:
    - names:
{%-     for srv in changedetect._service_names %}
      - systemctl --user stop {{ srv }}:
        - onlyif:
          - |
              export XDG_RUNTIME_DIR="/run/user/$(whoami | id -u)"
              export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
              test -n "$(systemctl --user is-active {{ srv }} \
                | grep active | grep -v inactive)" \
              || exit 1
{%-     endfor %}
          # machinectl is not installed by default on debian 11
          # also this leads to some weird recursion issues
          # - machinectl shell <changedetect.lookup.user.name>@ /usr/bin/systemctl --user is-active <srv> 2>/dev/null | grep active | grep -v inactive
    - env:
      - XDG_RUNTIME_DIR: /run/user/{{ changedetect.lookup.user.uid }}
      - DBUS_SESSION_BUS_ADDRESS: unix:path=/run/user/{{ changedetect.lookup.user.uid }}/bus
    - runas: {{ changedetect.lookup.user.name }}
{%-   endif %}
    - prereq:
      - file: {{ changedetect.lookup.paths.compose }}
      - file: {{ changedetect.lookup.paths.config_changedetection }}
      - file: {{ changedetect.lookup.paths.config_selenium_chrome }}
      - file: {{ changedetect.lookup.paths.config_playwright_chrome }}
      # https://github.com/saltstack/salt/issues/60641
      # - Changedetection containers are present
{%- endif %}

{%- if changedetect._podman_compose %}
{%-   if changedetect.install.podman.compose_systemd %}

# this needs to run as root
podman-compose systemd unit is installed for changedetection:
  cmd.run:
    - name: podman-compose systemd -a create-unit
    - creates:
      - /etc/systemd/user/podman-compose@.service

Changedetection service is registered:
  cmd.run:
    - name: |
        podman-compose -f '{{ changedetect.lookup.paths.compose }}' \
          --project-name changedetection \
        systemd -a register
#{#- this check is probably harmful since podman-compose is specialized in rootless @FIXME #}
{%-     if changedetect.install.podman.rootless %}
    - runas: {{ changedetect.lookup.user.name }}
    - require:
      - user: {{ changedetect.lookup.user.name }}
{%-     endif %}
{%-   elif changedetect.install.podman.compose_pods %}

# pod services generated without --new seem to not work as intended
# (stopping/restarting them seems to not affect the containers)
Changedetection containers systemd units are installed:
  cmd.run:
    - name: |
        podman generate systemd \
          --files \
          --new \
          --name \
          --pod-prefix= \
          --container-prefix= \
          --separator= \
        pod_changedetection
    - cwd: {{ changedetect._services }}
    - onchanges:
      - Changedetection containers are present
{%-     if changedetect.install.podman.rootless %}
    - runas: {{ changedetect.lookup.user.name }}
    - require:
      - user: {{ changedetect.lookup.user.name }}
{%-     endif %}
{%-   else %}

Changedetection containers systemd units are installed:
  cmd.run:
    - names:
{%-     for container in changedetect._containers %}
      - podman generate systemd --new --name --files --container-prefix= --separator= {{ container }}
{%-     endfor %}
    - cwd: {{ changedetect._services }}
    - onchanges:
      - Changedetection containers are present
{%-     if changedetect.install.podman.rootless %}
    - runas: {{ changedetect.lookup.user.name }}
    - require:
      - user: {{ changedetect.lookup.user.name }}
{%-     endif %}
{%-   endif %}

{%-   if not changedetect.install.podman.compose_systemd %}

Daemons are reloaded:
{%-     if not changedetect.install.podman.rootless %}
  module.run:
    - service.systemctl_reload: []
{%-     else %}
  cmd.run:
    - name: systemctl --user daemon-reload
    - runas: {{ changedetect.lookup.user.name }}
    - env:
      - XDG_RUNTIME_DIR: /run/user/{{ changedetect.lookup.user.uid }}
      - DBUS_SESSION_BUS_ADDRESS: unix:path=/run/user/{{ changedetect.lookup.user.uid }}/bus
{%-     endif %}
    - onchanges:
      - Changedetection containers systemd units are installed
{%-   endif %}
{%- endif %}
