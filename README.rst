===============================================
Zope buildout for https://cdr.eionet.europa.eu/
===============================================

.. contents ::

This buildout will create an isolated environment for running CDR Reportek.
There are three configurations available for running this buildout::

 1. production (production)
 2. testing (staging)
 3. testing dev (staging_dev)
 4. development (devel)


Project name
------------
The project name is CDR: Central Data Repository and it's based on Zope framework.


Prerequisites - System packages
-------------------------------
These should be installed by the sysadmin (needs root)
This buildout was tested on linux (debian based and RHEL based)
and Max OS X

RHEL based systems
~~~~~~~~~~~~~~~~~~
We will need pip to install some python related packages for versions greater
than the python shipped with RHEL 6.5. We will also need additional repos: PUIAS::

  $ sudo bash
  $ yum install python-pip python27-setuptools subversion git libxml2-devel libxslt-devel munin-node perl-XML-SAX cronie gcc python27-devel  openldap-devel libgsasl-devel curl-devel openssl-devel redis

Reportek-converters system packages::

  $ yum install unrar unzip p7zip mdbtools wv xlhtml libxslt poppler-utils gdal-libs java-1.6.0-openjdk gcc python-devel
  $ easy_install-2.7 virtualenv libssl-dev

Make sure crond (from cronie package) starts automatically on RHEL systems.

Debian based systems
~~~~~~~~~~~~~~~~~~~~
::

  $ sudo bash
  $ apt-get install python2.7 python2.7-dev python-ldap python-setuptools subversion git libxml2-dev libxslt-dev munin-node libxml-sax-perl python-virtualenv redis-server

Reportek-converters system packages::

  $ apt-get install unrar p7zip-full mdbtools wv xlhtml xsltproc unzip ppthtml pdftohtml python-gdal openjdk-6-jre

Product directory
~~~~~~~~~~~~~~~~~
::

  $ mkdir -p /var/local/cdr/production


Internal dependencies
---------------------
This buildout depends on us having the following products

 * Products.Reportek https://github.com/eea/Products.Reportek
 * XMLRPCMethod https://svn.eionet.europa.eu/repositories/Zope/trunk/XMLRPCMethod/
 * RDFGrabber https://svn.eionet.europa.eu/repositories/Zope/trunk/RDFGrabber/
 * SmallObligations https://svn.eionet.europa.eu/repositories/Zope/trunk/SmallObligations/
 * reportek-converters https://github.com/eea/reportek-converters


Install Products.Reportek
-------------------------
We shall use virtualenv & co for isolated packages::

  $ cd /var/local/cdr/production
  $ git clone https://github.com/eea/cdr.zopebuildout zope
  $ virtualenv prod-venv
  $ . ./prod-venv/bin/activate
  $ pip install -r zope/requirements.txt


Build production
----------------
Note that the production deployment will use Products.Reportek egg from
http://eggshop.eaudeweb.ro/ ::

  $ cd /var/local/cdr/production
  $ . prod-venv/bin/activate
  $ cd zope
  $ curl -L -O http://downloads.buildout.org/2/bootstrap.py
  $ python bootstrap.py
  $ cp secret.cfg.sample secret.cfg
  $ vim secret.cfg

Edit secret.cfg and change all the passwords. This file should not be added to Git because it is secret :).
Run buildout using the production.cfg configuration ::

  $ ./bin/buildout -c production.cfg
  $ ./bin/supervisorctl reload 1>/dev/null || ./bin/supervisord

Check logs/supervisor.log to see if all the procs started or use ./bin/supervisorctl status
Note that buildout for production and staging will make supervisord and all its services
start automatically at boot. (crontab @reboot entry). If you do not want such behaviour
remove supervisor_at_boot line from parts variable in supervisor.cfg file and build again.

Restart with ::
  $ ./bin/supervisorctl restart all


Build staging
-------------
This deployment is what runns behind https://cdr-test.eionet.europa.eu/
Note that staging will use Products.Reportek from sources (through mr.developer)
https://github.com/eea/Products.Reportek ::

  $ mkdir -p /var/local/cdr/staging
  $ cd /var/local/cdr/staging
  $ git clone https://github.com/eea/cdr.zopebuildout zope
  $ virtualenv staging-venv
  $ . staging-venv/bin/activate
  $ pip install -r zope/requirements-staging.txt
  $ cd zope
  $ curl -O http://downloads.buildout.org/2/bootstrap.py
  $ python bootstrap.py
  $ cp secret.cfg.sample secret.cfg
  $ vim secret.cfg

Edit secret.cfg and change all the passwords.
Run buildout using the staging.cfg configuration::

  $ ./bin/buildout -c staging.cfg
  $ ./bin/supervisorctl reload 1>/dev/null || ./bin/supervisord


Build devel
-------------
Note that devel will use Products.Reportek from sources (through mr.developer)
https://github.com/eea/Products.Reportek but has always-checkout = false so 
that you can control the version of your sources::

  $ mkdir -p /var/local/cdr/devel
  $ cd /var/local/cdr/devel
  $ git clone https://github.com/eea/cdr.zopebuildout zope
  $ virtualenv devel-venv
  $ . devel-venv/bin/activate
  $ pip install -r zope/requirements-dev.txt
  $ cd zope
  $ curl -O http://downloads.buildout.org/2/bootstrap.py
  $ python bootstrap.py
  $ cp secret.cfg.sample secret.cfg
  $ vim secret.cfg

Edit secret.cfg and change all the passwords.
Run buildout using the devel.cfg configuration::

  $ ./bin/buildout -c devel.cfg
  $ ./bin/instance fg

Find out what dir the reportek.converters egg is intalled to and start gunicorn::
  * $ cd eggs/reportek.converters-<ver>.egg/Products/reportek.converters/ && ../../../../zope/bin/gunicorn -b localhost:5002 web:app


Generate documentation
----------------------
Before generate documentation set variable DOCS_PATH from secret.cfg, to the
path where the program will save the documentation.

To generate documentation::

 $ ./make-docs

To delete all documentation::

 $ ./bin/clean-docs

**Be carefull with clean-docs because it removes the whole content of the folder 
DOCS_PATH.**


========
Contacts
========
The project owner is Søren Roug (soren.roug at eaa.europa.eu)

Other people involved in this project are::
 - Cornel Nițu (cornel.nitu at eaudeweb.ro)
 - Miruna Bădescu (miruna.badescu at eaudeweb.ro)
 - Daniel Mihai Bărăgan (daniel.baragan at eaudeweb.ro)


=========
Resources
=========
Minimum requirements:
 * 2048MB RAM
 * 2 CPU 1.8GHz or faster
 * 4GB hard disk space

Recommended:
 * 4096MB RAM
 * 4 CPU 2.4GHz or faster
 * 8GB hard disk space


=====================
Copyright and license
=====================
Copyright 2007 European Environment Agency (EEA)

Licensed under the EUPL, Version 1.1 or – as soon they will be approved
by the European Commission - subsequent versions of the EUPL (the "Licence");

You may not use this work except in compliance with the Licence.

You may obtain a copy of the Licence at:
https://joinup.ec.europa.eu/software/page/eupl/licence-eupl

Unless required by applicable law or agreed to in writing, software distributed under the Licence is distributed on an "AS IS" basis,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the Licence for the specific language governing permissions and limitations under the Licence.
