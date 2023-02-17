# vim: ft=yaml
---
changedetect:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    compose:
      create_pod: null
      pod_args: null
      project_name: changedetection
      remove_orphans: true
      build: false
      build_args: null
      pull: false
      service:
        container_prefix: null
        ephemeral: true
        pod_prefix: null
        restart_policy: on-failure
        restart_sec: 2
        separator: null
        stop_timeout: null
    paths:
      base: /opt/containers/changedetection
      compose: docker-compose.yml
      config_changedetection: changedetection.env
      config_playwright_chrome: playwright_chrome.env
      config_selenium_chrome: selenium_chrome.env
      data: datastore
    user:
      groups: []
      home: null
      name: changedetection
      shell: /usr/sbin/nologin
      uid: null
      gid: null
    container:
      changedetection:
        container_name: changedetection
        hostname: changedetection
        image: ghcr.io/dgtlmoon/changedetection.io
        pgid: false
        puid: false
      playwright_chrome:
        container_name: playwright-chrome
        hostname: playwright-chrome
        image: docker.io/browserless/chrome
      selenium_chrome:
        container_name: selenium-chrome
        hostname: browser-chrome
        image: docker.io/selenium/standalone-chrome-debug:3.141.59
    podman:
      compose_current_pip_default: 1.0.3
      compose_forced_pods:
        - '0.'
      compose_no_systemd:
        - '0.'
        - 1.0.2
        - 1.0.3
      compose_nopods:
        - 1.0.2
        - 1.0.3
  install:
    rootless: true
    autoupdate: true
    autoupdate_service: false
    remove_all_data_for_sure: false
    podman_api: true
    method: docker-compose
    podman:
      compose_pods: true
      compose_systemd: false
      rootless: false
  config:
    app: {}
    env:
      allow_file_uri: false
      base_url: http://127.0.0.1:5000
      default_fetch_backend: html_requests
      fetch_workers: 10
      http_proxy: ''
      https_proxy: ''
      minimum_seconds_recheck_time: 60
      no_proxy: []
      notification_mail_button_prefix: 0
      port: 5000
      salted_pass: ''
      settings_headers_useragent: null
      settings_requests_timeout: null
      settings_requests_workers: null
      use_x_settings: false
    headers: {}
    requests: {}
  playwright:
    browser_type: chromium
    browserless_chrome:
      chrome_refresh_time: 600000
      connection_timeout: 300000
      default_block_ads: true
      default_stealth: true
      enable_debugger: false
      max_concurrent_sessions: 10
      preboot_chrome: true
      screen:
        depth: 16
        height: 1024
        width: 1920
    enable: false
    proxy:
      bypass: []
      password: ''
      server: ''
      username: ''
    screenshot_quality: 72
  selenium:
    delay_before_content_ready: 5
    enable: false
    proxy:
      autoconfig_url: ''
      autodetect: false
      ftp: ''
      http: ''
      no_proxy: []
      socks: ''
      socks_password: ''
      socks_username: ''
      socks_version: ''
      ssl: false
    screen:
      depth: 24
      height: 1080
      width: 1920

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://changedetect/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   changedetect-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      Changedetection environment file is managed:
      - changedetect.env.j2

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
