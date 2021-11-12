#! /bin/sh

### BEGIN INIT INFO
# Provides:          pgsql
# Required-Start:    $syslog
# Required-Stop:     $syslog
# Should-Start:      $syslog
# Should-Stop:       $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: pgsql daemon
# Description:       pgsql daemon
### END INIT INFO

# chkconfig: 2345 98 02
# description: PostgreSQL RDBMS

# contrib/start-scripts/linux

prefix=/usr/local/pgsql
PGDATA="/data/pgsql"
PGUSER=postgres
PGLOG="$PGDATA/serverlog"
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON="$prefix/bin/postmaster"
PGCTL="$prefix/bin/pg_ctl"

set -e

test -x $DAEMON ||
{
    echo "$DAEMON not found"
    if [ "$1" = "stop" ]
    then exit 0
    else exit 5
    fi
}

if [ -e "$PG_OOM_ADJUST_FILE" -a -n "$PG_CHILD_OOM_SCORE_ADJ" ]
then
    DAEMON_ENV="PG_OOM_ADJUST_FILE=$PG_OOM_ADJUST_FILE PG_OOM_ADJUST_VALUE=$PG_CHILD_OOM_SCORE_ADJ"
fi

case $1 in
  start)
    echo -n "Starting PostgreSQL: "
    test -e "$PG_OOM_ADJUST_FILE" && echo "$PG_MASTER_OOM_SCORE_ADJ" > "$PG_OOM_ADJUST_FILE"
    su - $PGUSER -c "$DAEMON_ENV $DAEMON -D '$PGDATA' >>$PGLOG 2>&1 &"
    echo "ok"
    ;;
  stop)
    echo -n "Stopping PostgreSQL: "
    su - $PGUSER -c "$PGCTL stop -D '$PGDATA' -s"
    echo "ok"
    ;;
  restart)
    echo -n "Restarting PostgreSQL: "
    su - $PGUSER -c "$PGCTL stop -D '$PGDATA' -s"
    test -e "$PG_OOM_ADJUST_FILE" && echo "$PG_MASTER_OOM_SCORE_ADJ" > "$PG_OOM_ADJUST_FILE"
    su - $PGUSER -c "$DAEMON_ENV $DAEMON -D '$PGDATA' >>$PGLOG 2>&1 &"
    echo "ok"
    ;;
  reload)
    echo -n "Reload PostgreSQL: "
    su - $PGUSER -c "$PGCTL reload -D '$PGDATA' -s"
    echo "ok"
    ;;
  status)
    su - $PGUSER -c "$PGCTL status -D '$PGDATA'"
    ;;
  *)
    # Print help
    echo "Usage: $0 {start|stop|restart|reload|status}" 1>&2
    exit 1
    ;;
esac

exit 0
