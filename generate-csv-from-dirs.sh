#!/bin/sh
# 指定されたディレクトリ以下の *.json ファイル全件を CSV 出力する

basedir=`dirname "$0"`
basename=`basename "$0"`
create_csv="${basedir}/create_csv.rb"

if [ $# -lt 1 ]; then
        echo "usage: $basename source-dir [source-dir ...]"
        exit 1
fi


ruby "$create_csv" -h || exit 1
find "$@" -name '*.json' | xargs ruby "$create_csv" -b || exit 1

