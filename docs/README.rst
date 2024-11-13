.. _readme:

Changedetection Formula
=======================

|img_sr| |img_pc|

.. |img_sr| image:: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
   :alt: Semantic Release
   :scale: 100%
   :target: https://github.com/semantic-release/semantic-release
.. |img_pc| image:: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
   :alt: pre-commit
   :scale: 100%
   :target: https://github.com/pre-commit/pre-commit

Manage Changedetection with Salt and Podman.

.. contents:: **Table of Contents**
   :depth: 1

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html>`_.

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

If you need (non-default) configuration, please refer to:

- `how to configure the formula with map.jinja <map.jinja.rst>`_
- the ``pillar.example`` file
- the `Special notes`_ section

Special notes
-------------
* This formula is re-written with the custom compose modules in mind. It was actually the cause for writing the modules, as evidenced by the standalone states. You can enable using the module by setting install:method to compose-module.

Configuration
-------------
An example pillar is provided, please see `pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in `map.jinja`.


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




Contributing to this repo
-------------------------

Commit messages
^^^^^^^^^^^^^^^

**Commit message formatting is significant!**

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``. ::

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.
