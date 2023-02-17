Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``changedetect``
^^^^^^^^^^^^^^^^
*Meta-state*.

This installs the changedetection, playwright_chrome, selenium_chrome containers,
manages their configuration and starts their services.


``changedetect.package``
^^^^^^^^^^^^^^^^^^^^^^^^
Installs the changedetection, playwright_chrome, selenium_chrome containers only.
This includes creating systemd service units.


``changedetect.config``
^^^^^^^^^^^^^^^^^^^^^^^
Manages the configuration of the changedetection, playwright_chrome, selenium_chrome containers.
Has a dependency on `changedetect.package`_.


``changedetect.service``
^^^^^^^^^^^^^^^^^^^^^^^^
Starts the changedetection, playwright_chrome, selenium_chrome container services
and enables them at boot time.
Has a dependency on `changedetect.config`_.


``changedetect.standalone.config``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



``changedetect.standalone.package``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



``changedetect.standalone.service``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



``changedetect.clean``
^^^^^^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``changedetect`` meta-state
in reverse order, i.e. stops the changedetection, playwright_chrome, selenium_chrome services,
removes their configuration and then removes their containers.


``changedetect.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the changedetection, playwright_chrome, selenium_chrome containers
and the corresponding user account and service units.
Has a depency on `changedetect.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``changedetect.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the changedetection, playwright_chrome, selenium_chrome containers
and has a dependency on `changedetect.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``changedetect.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the changedetection, playwright_chrome, selenium_chrome container services
and disables them at boot time.


``changedetect.standalone.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



``changedetect.standalone.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



``changedetect.standalone.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



