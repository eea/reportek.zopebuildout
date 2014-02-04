BDR zope buildout
=================

This buildout will create an isolated environment for running BDR Reportek.
The main product being used is
Products.Reportek https://svn.eionet.europa.eu/repositories/Zope/trunk/Products.Reportek/
The service is using some additional external services most of them on localhost.


System packages
---------------
You will need to be root to acomplish this

### RHEL based systems:
We will need pip to install some python related packages for versions greater
than the python shipped with RHEL 6.5. We will also need additional repos: PUIAS
> $ sudo bash
>
> $ yum install python-pip python27-setuptools subversion git libxml2-devel libxslt-devel munin-node perl-XML-SAX

Reportek-convertes system packages:
> $ yum install unrar unzip p7zip mdbtools wv xlhtml libxslt poppler-utils gdal-libs java-1.6.0-openjdk
>
> $ easy_install-2.7 virtualenv

### Debian based systems:
> $ sudo bash
>
> $ apt-get install python2.7 python2.7-dev python-ldap python-setuptools subversion git libxml2-dev libxslt-dev munin-node libxml-sax-perl python-virtualenv

Reportek-convertes system packages:
> $ apt-get installunrar p7zip-full mdbtools wv xlhtml xsltproc unzip ppthtml pdftohtml python-gdal openjdk-6-jre


### Product dir
> $ mkdir -p /var/local/bdr/production
>
> $ cd /var/local/bdr/production



Install Products.Reportek
-------------------------
We shall use virtualenv & co for isolated packages
> $ cd /var/local/bdr/production
>
> $ git clone https://github.com/eea/bdr.zopebuildout zope
>
> $ virtualenv prod-venv
>
> $ . ./prod-venv/bin/activate
>
> $ pip install -r zope/requirements.txt

Install local-converters
------------------------
Make sure you have installed the system packages for reportek-converters (see above)
> $ cd /var/local/bdr/production
>
> $ . ./prod-venv/bin/activate
>
> $ git clone https://github.com/eea/reportek-converters local-converters
>
> $ cd local-converters

> $ pip install -r requirements.txt
>
> $ mkdir lib
>
> $ wget -P lib http://archive.apache.org/dist/tika/tika-app-1.2.jar

Build production
----------------
> $ cd /var/local/bdr/production
>
> $ . prod-venv/bin/activate
>
> $ cd zope
>
> $ ./bin/buildout -c production.cfg

Check logs/supervisor.log to see if all the procs started

### Build staging
> $ mkdir -p /var/local/bdr/staging
>
> $ cd /var/local/bdr/staging
>
> $ git clone https://github.com/eea/bdr.zopebuildout zope
>
> $ virtualenv staging-venv
>
> $ . staging-venv/bin/activate
>
> $ pip install -r zope/requirements.txt
>
> $ cd zope
>
> $ ./bin/buildout -c staging.cfg

Install local-converters in staging/local-converters (see above) but using 
staging-venv environment
Start instance ./bin/instance
> $ cd ../local-converters && ../zope/bin/gunicorn -b localhost:5001 web:app

