===============================================
Zope buildout for https://bdr.eionet.europa.eu/
===============================================

.. contents ::

This buildout will create an isolated environment for running BDR Reportek.
There are three configurations available for running this buildout:
1. production (production)
2. testing (staging)
3. development (devel)


Project name
------------
The project name is BDR: Bussines Data Repository and it's based on Zope framework.


Prerequisites - System packages
-------------------------------
These should be installed by the sysadmin (needs root)
This buildout was tested on linux (debian based and RHEL based)
and Max OS X

RHEL based systems
~~~~~~~~~~~~~~~~~~
We will need pip to install some python related packages for versions greater
than the python shipped with RHEL 6.5. We will also need additional repos: PUIAS

 * $ sudo bash
 * $ yum install python-pip python27-setuptools subversion git libxml2-devel libxslt-devel munin-node perl-XML-SAX

Reportek-convertes system packages:
 * $ yum install unrar unzip p7zip mdbtools wv xlhtml libxslt poppler-utils gdal-libs java-1.6.0-openjdk
 * $ easy_install-2.7 virtualenv

Debian based systems
~~~~~~~~~~~~~~~~~~~~
 * $ sudo bash
 * $ apt-get install python2.7 python2.7-dev python-ldap python-setuptools subversion git libxml2-dev libxslt-dev munin-node libxml-sax-perl python-virtualenv

Reportek-convertes system packages:
 * $ apt-get install unrar p7zip-full mdbtools wv xlhtml xsltproc unzip ppthtml pdftohtml python-gdal openjdk-6-jre

Product directory
~~~~~~~~~~~~~~~~~
 * $ mkdir -p /var/local/bdr/production


Internal dependencies
---------------------
This buildout depends on us having the following products

Products.Reportek https://svn.eionet.europa.eu/repositories/Zope/trunk/Products.Reportek/
XMLRPCMethod https://svn.eionet.europa.eu/repositories/Zope/trunk/XMLRPCMethod/ 
RDFGrabber https://svn.eionet.europa.eu/repositories/Zope/trunk/RDFGrabber/ 
SmallObligations https://svn.eionet.europa.eu/repositories/Zope/trunk/SmallObligations/ 
reportek-converters https://github.com/eea/reportek-converters

Install Products.Reportek
-------------------------
We shall use virtualenv & co for isolated packages

 * $ cd /var/local/bdr/production
 * $ git clone https://github.com/eea/bdr.zopebuildout zope
 * $ virtualenv prod-venv
 * $ . ./prod-venv/bin/activate
 * $ pip install -r zope/requirements.txt


Install local-converters
------------------------
Make sure you have installed the system packages for reportek-converters (see above)

 * $ cd /var/local/bdr/production
 * $ . ./prod-venv/bin/activate
 * $ git clone https://github.com/eea/reportek-converters local-converters
 * $ cd local-converters
 * $ pip install -r requirements.txt
 * $ mkdir lib
 * $ wget -P lib http://archive.apache.org/dist/tika/tika-app-1.2.jar


Build production
----------------
Note that the production deployment will use Products.Reportek egg from
http://eggshop.eaudeweb.ro/

 * $ cd /var/local/bdr/production
 * $ . prod-venv/bin/activate
 * $ cd zope
 * $ ./bin/buildout -c production.cfg

Check logs/supervisor.log to see if all the procs started


Build staging
-------------
This deployment is what runns behind https://bdr-test.eionet.europa.eu/
Note that staging will user Products.Reportek from sources (through mr.developer)
https://svn.eionet.europa.eu/repositories/Zope/trunk/Products.Reportek/

 * $ mkdir -p /var/local/bdr/staging
 * $ cd /var/local/bdr/staging
 * $ git clone https://github.com/eea/bdr.zopebuildout zope
 * $ virtualenv staging-venv
 * $ . staging-venv/bin/activate
 * $ pip install -r zope/requirements.txt
 * $ cd zope
 * $ ./bin/buildout -c staging.cfg

Install local-converters in staging/local-converters (see above) but using 
staging-venv environment
Start instance ./bin/instance
 * $ cd ../local-converters && ../zope/bin/gunicorn -b localhost:5001 web:app


Build devel
-------------
Note that devel will user Products.Reportek from sources (through mr.developer)
https://svn.eionet.europa.eu/repositories/Zope/trunk/Products.Reportek/
but has always-checkout = false so that you can control the version of your sources

 * $ mkdir -p /var/local/bdr/devel
 * $ cd /var/local/bdr/devel
 * $ git clone https://github.com/eea/bdr.zopebuildout zope
 * $ virtualenv devel-venv
 * $ . devel-venv/bin/activate
 * $ pip install -r zope/requirements-dev.txt
 * $ cd zope
 * $ ./bin/buildout -c devel.cfg

Install local-converters in devel/local-converters (see above) but using 
devel-venv environment
Start instance ./bin/instance
 * $ cd ../local-converters && ../zope/bin/gunicorn -b localhost:5002 web:app


Contacts
--------
The project owner is Søren Roug (soren.roug at eaa.europa.eu)

Other people involved in this project are:
 - Cornel Nițu (cornel.nitu at eaudeweb.ro)
 - Miruna Bădescu (miruna.badescu at eaudeweb.ro)
 - Daniel Mihai Bărăgan (daniel.baragan at eaudeweb.ro)
