#!/bin/bash
# usage: ./start_benchmark.sh
# Environment variables (all optionals):
# - TEST_ITERATIONS: benchmark test iteration ( default: 1200 )
# - TEST_SLEEP: sleep time for each iteration ( default: 1 )
# - API_URL: api url to test (defaults to the api endpoint url)
# - APP_NAME: app name to test (defaults to last app available in the targeted space)
# - APP_URL: app url to test (defaults to last app available in the targeted space)
# - APP_INTERNAL_URL: app internal url used for testing (defaults to last app available in the targeted space)

set -ex

ROOT_DIR=${ROOT_DIR:-$PWD}

apps=$(cf apps)
API_URL="${API_URL:-$(cf api | awk '{ print $3 }' | head -n 1)}"
APP_URL=${APP_URL:-$(echo "$apps" | awk '{ print $6 }' | tail -n 1)}
API_URL="${API_URL/https/http}"
APP_NAME=${APP_NAME:-$(echo "$apps" | awk '{ print $1 }' | tail -n 1)}
APP_INTERNAL_URL=${APP_INTERNAL_URL:-$(cf ssh $APP_NAME -c "echo \$CF_INSTANCE_ADDR")}

echo "Benchmarking with app $APP_NAME: $APP_URL ( $APP_INTERNAL_URL ). API url at $API_URL"

THEDATE=`date +%Y%m%d%H%M%S`
BENCH_DATADIR="$ROOT_DIR/bench-curl-$THEDATE-${TEST_DURATION}-${TEST_CONCURRENCY}"

mkdir $BENCH_DATADIR

echo "Start benchmark of app (with gorouter)"
bash $ROOT_DIR/curl.sh "http://$APP_URL" > $BENCH_DATADIR/app_${APP_NAME}.csv

echo "Start benchmark of api"
bash $ROOT_DIR/curl.sh "$API_URL" > $BENCH_DATADIR/api.csv

kubectl cp -c nfs-broker $ROOT_DIR/curl.sh scf/nfs-broker-0:/curl.sh
kubectl exec -n scf nfs-broker-0 -c nfs-broker -ti -- bash /curl.sh "http://${APP_INTERNAL_URL}" > $BENCH_DATADIR/nogorouter.csv
kubectl exec -n scf nfs-broker-0 -c nfs-broker -ti -- rm -rfv /curl.sh


if [ -f "$ROOT_DIR/create_graphs.sh" ]; then
    PLOT="plot_curl.gnuplot" bash $ROOT_DIR/create_graphs.sh $BENCH_DATADIR
fi
