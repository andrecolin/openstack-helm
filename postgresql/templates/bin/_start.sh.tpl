#!/bin/bash
# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

sudo chown mysql: /var/lib/postgresql
rm -rf /var/lib/postgresql/lost+found

{{- if .Values.development.enabled }}
REPLICAS=1
{{- else }}
REPLICAS={{ .Values.replicas }}
{{- end }}
PETSET_NAME={{ printf "%s" .Values.service_name }}
INIT_MARKER="/var/lib/mysql/init_done"

function join_by { local IFS="$1"; shift; echo "$*"; }

# Remove postgresql.pid if exists
if [[ -f /var/lib/postgresql/9.6/main/postmaster.pid ]]; then
    if [[ `pgrep -c $(cat /var/lib/postgresql/9.6/main/postmaster.pid)` -eq 0 ]]; then
        rm -vf /var/lib/postgresql/9.6/main/postmaster.pid
    fi
fi

if [ "$REPLICAS" -eq 1 ] ; then
    if [[ ! -f ${INIT_MARKER} ]]; then
        cd /var/lib/postgresql/9.6/main
        echo "Creating main provider."
        bash /tmp/bootstrap-db.sh
        touch ${INIT_MARKER}
    fi
    exec /usr/lib/postgresql/9.6/bin/postgres \
        -D /var/lib/postgresql/9.6/main \
        -c config_file=/etc/postgresql/9.6/main/postgresql.conf
else

    # give the seed more of a chance to be ready by the time
    # we start the first pet so we succeed on the first pass
    # a little hacky, but prevents restarts as we aren't waiting
    # for job completion here so I'm not sure what else
    # to look for
    sleep 30

    exec /usr/lib/postgresql/9.6/bin/postgres \
        -D /var/lib/postgresql/9.6/main \
        -c config_file=/etc/postgresql/9.6/main/postgresql.conf
fi

