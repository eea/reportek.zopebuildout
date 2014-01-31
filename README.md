BDR zope buildout
=================

This buildout will create an isolated environment for running BDR Reportek.
The main product being used is
Products.Reportek https://svn.eionet.europa.eu/repositories/Zope/trunk/Products.Reportek/
The service is using some additional external services most of them on localhost.


System packages
---------------
You will need to be root to acomplish this
### Debian based systems:
> $ sudo bash
> $ apt-get install python2.7 python2.7-dev python-ldap python-setuptools \
>    python-gdal subversion git libxml2-dev libxslt-dev munin-node \
>    libxml-sax-perl python-virtualenv
### RHEL based systems:

> $ sudo bash
> $ yum install

Install Products.Reportek
=========================
::

    $
    $ git clone https://github.com/eea/bdr.zopebuildout instance_dir
    $ cd instance_dir
    $ 
