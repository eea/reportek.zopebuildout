#!/bin/bash
set -e
#set -x

CONFIG=$1
VERSIONSCFG="https://raw.githubusercontent.com/eea/reportek.zopebuildout/bdr/buildout-configs/versions.cfg"
SETUPTOOLS=`curl -s $VERSIONSCFG | grep "setuptools\s*\=\s*" | sed 's/ *//g' | sed 's/=//g' | sed 's/[a-z]//g'`
ZCBUILDOUT=`curl -s $VERSIONSCFG | grep "zc\.buildout\s*=\s*" | sed 's/^.*\=\s*//g'`
BOOTSTRAP='https://raw.githubusercontent.com/eea/eea.plonebuildout.core/master/bootstrap.py'

if [ -z "$CONFIG" ]; then
  if [ -s "devel.cfg" ]; then
    CONFIG="devel.cfg"
  else
    CONFIG="buildout.cfg"
  fi
fi

echo ""
echo "Using $CONFIG"
echo ""

if [ -z "$SETUPTOOLS" ]; then
  SETUPTOOLS="7.0"
fi

echo "Using setuptools $SETUPTOOLS"
echo ""

if [ -z "$ZCBUILDOUT" ]; then
  ZCBUILDOUT="2.2.1"
fi

echo "Using zc.buildout $ZCBUILDOUT"
echo ""

if [ ! -s "bootstrap.py" ]; then
  curl -o "bootstrap.py" -k $BOOTSTRAP
fi

if [ -z "$PYTHON" ]; then
  PYTHON="/usr/bin/env python"
fi

echo "Running bin/python bootstrap.py -c $CONFIG -v $ZCBUILDOUT --setuptools-version=$SETUPTOOLS"
$PYTHON "bootstrap.py" -c $CONFIG -v $ZCBUILDOUT --setuptools-version=$SETUPTOOLS

echo "Disabling the SSL CERTIFICATION for git"
git config --global http.sslVerify false

echo ""
echo "========================================================================="
echo "All set. Now you can run ./bin/buildout -c $CONFIG"
echo "========================================================================="
echo ""
