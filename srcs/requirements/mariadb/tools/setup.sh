#!/bin/bash

set -e

chown -R mysql:mysql /var/lib/mysql

exec mysqld --user=mysql