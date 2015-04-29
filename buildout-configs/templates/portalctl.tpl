#!/bin/bash
#
# portalctl        This shell script takes care of starting and stopping
#                       the data registry portal
#
# Author: Olimpiu Rob olimpiu.rob@gmail.com
#
# chkconfig: 2345 13 87
# description: This script will start all required services for the data registry\
#   portal.


RETVAL=0
if [ -z "$$PYTHON" ]; then
  PYTHON="/usr/bin/env python2.7"
fi


# Make sure python is 2.7 or later. If we have software collections python27 and
# system python27, use the one from software collections by default
PYTHON_OK=`$$PYTHON -c 'import sys
print (sys.version_info >= (2, 7) and "1" or "0")' 2> /dev/null`

SCL_PKG="python27"
OPTS=

if [ -f /usr/bin/scl ]; then
    TEST_SCL_PY=`/usr/bin/scl --list | grep $$SCL_PKG`
    if [ -n "$$TEST_SCL_PY" ]; then
        OPTS="/usr/bin/scl enable $$SCL_PKG --"
    fi
elif [ ! "$$PYTHON_OK" = '1' ]; then
    echo "Python 2.7 or later is required"
    exit 0
fi

SUCMD='su -s /bin/bash ${parts.configuration['effective-user']} -c'
PREFIX=${parts.buildout.directory}
INSTANCES=({% for i in range(1,3) %}{% with INSTANCE='instance'+str(i) %}{% if parts[INSTANCE]['recipe'] %}"$INSTANCE" {% end %}{% end %}{% end %})

PID_ZEO=$( cat "$$PREFIX/var/zeoserver.pid" 2>/dev/null )
PID_POUND=$( cat "$$PREFIX/parts/pound/var/pound.pid" 2>/dev/null )
PID_CONVERTERS=$( cat "$$PREFIX/var/converters.pid" 2>/dev/null )


test -f $$PREFIX/bin/zeoserver || exit 5
test -f $$PREFIX/bin/poundctl || exit 5
for name in "$${INSTANCES[@]}"; do
    test -f $$PREFIX/bin/$$name || exit 5
done

pid_exists() {
    ps -p $1  &>/dev/null
}

start_all() {
    if pid_exists $$PID_ZEO; then
        echo "Zeoserver not started"
    else
        $$SUCMD "$$OPTS $$PREFIX/bin/zeoserver start"
        echo "Zeosever started"
    fi
    for name in "$${INSTANCES[@]}"; do
        PID_ZOPE=$( cat "$$PREFIX/var/$$name.pid" 2>/dev/null )
        if pid_exists $$PID_ZOPE; then
            echo "Zope $$name not started"
        else
            $$SUCMD "$$OPTS $$PREFIX/bin/$$name start"
            echo "Zope $$name started"
        fi
    done
    if pid_exists $$PID_POUND; then
        echo "Pound not started"
    else
        $$SUCMD "$$OPTS $$PREFIX/bin/poundctl start"
        echo "Pound started"
    fi
    if pid_exists $$PID_CONVERTERS; then
        echo "Pound not started"
    else
        $$SUCMD "$$OPTS $$PREFIX/bin/gunicorn -b ${parts.gunicorn['address']}:${parts.gunicorn['port']} ${parts.gunicorn['app_module']} --timeout 300 -p $$PREFIX/var/converters.pid -D --chdir=${parts.buildout['eggs-directory']}/reportek.converters.egg/Products/reportek.converters/"
        echo "Converters started"
    fi
}

stop_all() {
    if pid_exists $$PID_POUND; then
        $$SUCMD "$$OPTS $$PREFIX/bin/poundctl stop"
        echo "Pound stopped"
    else
        echo "Pound not stopped"
    fi
    for name in "$${INSTANCES[@]}"; do
        PID_ZOPE=$( cat "$$PREFIX/var/$$name.pid" 2>/dev/null )
        if pid_exists $$PID_ZOPE; then
            $$SUCMD "$$OPTS $$PREFIX/bin/$$name stop"
            echo "Zope $$name stopped"
        else
            echo "Zope $$name not stopped"
        fi
    done
    if pid_exists $$PID_ZEO; then
        $$SUCMD "$$OPTS $$PREFIX/bin/zeoserver stop"
        echo "Zeosever stopped"
    else
        echo "Zeoserver not stopped"
    fi
    if pid_exists $$PID_CONVERTERS; then
        $$SUCMD "/bin/kill -s TERM $$PID_CONVERTERS"
        echo "Converters stopped"
    else
        echo "Converters not stopped"
    fi
}

status_all() {
    if pid_exists $$PID_ZEO; then
        echo "Zeosever `$$OPTS $$SUCMD "$$PREFIX/bin/zeoserver status"`"
    else
        echo "Zeoserver"
    fi
    for name in "$${INSTANCES[@]}"; do
        PID_ZOPE=$( cat "$$PREFIX/var/$$name.pid" 2>/dev/null )
        if pid_exists $$PID_ZOPE; then
            echo "Zope $$name `$$OPTS $$SUCMD "$$PREFIX/bin/$$name status"`"
        else
            echo "Zope $$name"
        fi
    done
    if pid_exists $$PID_POUND; then
        echo "Pound `$$SUCMD "$$OPTS $$PREFIX/bin/poundctl status"`"
    else
        echo "Pound not running"
    fi
    if pid_exists $$PID_CONVERTERS; then
        echo "Converters seem to be running pid=$$PID_CONVERTERS"
    else
        echo "Converters not running"
    fi
}

case "$$1" in
  start)
        start_all
        ;;
  stop)
        stop_all
        ;;
  status)
        status_all
        ;;
  restart)
        stop_all
        start_all
        ;;
  *)
        echo "Usage: $$0 {start|stop|status|restart}"
        RETVAL=1
esac
exit $$RETVAL
