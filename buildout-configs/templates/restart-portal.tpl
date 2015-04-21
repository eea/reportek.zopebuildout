#!/bin/bash
#
# restart-portal        This shell script takes care of starting and stopping
#                       the data registry portal
#
# Author: Olimpiu Rob olimpiu.rob@gmail.com
#
# chkconfig: 2345 13 87
# description: This script will start all required services for the datare gistry\
#   portal.

# . /etc/init.d/functions

RETVAL=0
SUCMD='su -s /bin/bash ${parts.configuration['effective-user']} -c'
PREFIX=${parts.buildout.directory}
INSTANCES=({% for i in range(1,3) %}{% with INSTANCE='instance'+str(i) %}{% if parts[INSTANCE]['recipe'] %}"$INSTANCE" {% end %}{% end %}{% end %})

PID_ZEO=$( cat "$$PREFIX/var/zeoserver.pid" 2>/dev/null )
PID_POUND=$( cat "$$PREFIX/parts/poundconfig/var/pound.pid" 2>/dev/null )


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
        $$SUCMD "$$PREFIX/bin/zeoserver start"
        echo "Zeosever started"
    fi
    for name in "$${INSTANCES[@]}"; do
        PID_ZOPE=$( cat "$$PREFIX/var/$$name.pid" 2>/dev/null )
        if pid_exists $$PID_ZOPE; then
            echo "Zope $$name not started"
        else
            $$SUCMD "$$PREFIX/bin/$$name start"
            echo "Zope $$name started"
        fi
    done
    if pid_exists $$PID_POUND; then
        echo "Pound not started"
    else
        $$SUCMD "$$PREFIX/bin/poundctl start"
        echo "Pound started"
    fi
}

stop_all() {
    if pid_exists $$PID_POUND; then
        $$SUCMD "$$PREFIX/bin/poundctl stop"
        echo "Pound stopped"
    else
        echo "Pound not stopped"
    fi
    for name in "$${INSTANCES[@]}"; do
        PID_ZOPE=$( cat "$$PREFIX/var/$$name.pid" 2>/dev/null )
        if pid_exists $$PID_ZOPE; then
            $$SUCMD "$$PREFIX/bin/$$name stop"
            echo "Zope $$name stopped"
        else
            echo "Zope $$name not stopped"
        fi
    done
    if pid_exists $$PID_ZEO; then
        $$SUCMD "$$PREFIX/bin/zeoserver stop"
        echo "Zeosever stopped"
    else
        echo "Zeoserver not stopped"
    fi
}

status_all() {
    if pid_exists $$PID_ZEO; then
        $$PREFIX/bin/zeoserver status
        echo "Zeosever"
    else
        echo "Zeoserver"
    fi
    for name in "$${INSTANCES[@]}"; do
        PID_ZOPE=$( cat "$$PREFIX/var/$$name.pid" 2>/dev/null )
        if pid_exists $$PID_ZOPE; then
            echo "Zope $$name"
            $$PREFIX/bin/$$name status
        else
            echo "Zope $$name"
        fi
    done
    if pid_exists $$PID_POUND; then
        $$SUCMD "$$PREFIX/bin/poundctl status"
        echo "Pound"
    else
        echo "Pound"
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
