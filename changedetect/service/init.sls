# vim: ft=sls

{#-
    Starts the changedetection, playwright_chrome, selenium_chrome container services
    and enables them at boot time.
    Has a dependency on `changedetect.config`_.
#}

include:
  - .running
