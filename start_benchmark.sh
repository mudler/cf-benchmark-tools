#!/bin/bash
# usage: ./start_benchmark.sh
# Environment variables (all optionals):
# - TEST_DURATION: benchmark test duration ( default: 20m )
# - TEST_CONCURRENCY: how many tests to run in parallelism ( default: 1 )
# - TEST_RATE: how many requests in 1 second for each worker ( default: 1 )
# - API_URL: api url to test (defaults to the api endpoint url)
# - APP_NAME: app name to test (defaults to last app available in the targeted space)
# - APP_URL: app url to test (defaults to last app available in the targeted space)
# - APP_INTERNAL_URL: app internal url used for testing (defaults to last app available in the targeted space)

set -ex

ROOT_DIR=${ROOT_DIR:-$PWD}
TEST_DURATION="${TEST_DURATION:-20m}"
TEST_CONCURRENCY="${TEST_CONCURRENCY:-1}" # Test parallelism
TEST_RATE="${TEST_RATE:-1}" # Number of queries per second
HEY_URL="${HEY_URL:-https://storage.googleapis.com/hey-release/hey_linux_amd64}"

apps=$(cf apps)
API_URL="${API_URL:-$(cf api | awk '{ print $3 }' | head -n 1)}"
APP_URL=${APP_URL:-$(echo "$apps" | awk '{ print $6 }' | tail -n 1)}
APP_NAME=${APP_NAME:-$(echo "$apps" | awk '{ print $1 }' | tail -n 1)}
APP_INTERNAL_URL=${APP_INTERNAL_URL:-$(cf ssh $APP_NAME -c "echo \$CF_INSTANCE_ADDR")}

echo "Benchmarking with app $APP_NAME: $APP_URL ( $APP_INTERNAL_URL ). API url at $API_URL"

PATH=$PATH:$ROOT_DIR/.bin
hash hey 2>/dev/null || {
    mkdir $ROOT_DIR/.bin/;
    wget "$HEY_URL" -O $ROOT_DIR/.bin/hey
    chmod +x $ROOT_DIR/.bin/hey
}

THEDATE=`date +%Y%m%d%H%M%S`
BENCH_DATADIR="$ROOT_DIR/bench-$THEDATE-${TEST_DURATION}-${TEST_CONCURRENCY}"

mkdir $BENCH_DATADIR

echo "Start benchmark of app (with gorouter)"
hey -z "${TEST_DURATION}" -q "${TEST_RATE}" -c "${TEST_CONCURRENCY}" -o csv "http://$APP_URL" > $BENCH_DATADIR/app_${APP_NAME}.csv

cat << EOF >> $BENCH_DATADIR/app_${APP_NAME}.csv
#header: hey -z "${TEST_DURATION}" -q "${TEST_RATE}" -c "${TEST_CONCURRENCY}" -o csv "http://$APP_URL"
#footer: Directly connecting to the application (with gorouter, from the public access)
EOF

echo "Start benchmark of api"
hey -z "${TEST_DURATION}" -q "${TEST_RATE}" -c "${TEST_CONCURRENCY}" -o csv "$API_URL" > $BENCH_DATADIR/api.csv

cat << EOF >> $BENCH_DATADIR/api.csv
#header: hey -z "${TEST_DURATION}" -q "${TEST_RATE}" -c "${TEST_CONCURRENCY}" -o csv "$API_URL"
#footer: Connecting to the API
EOF

kubectl cp -c nfs-broker $ROOT_DIR/.bin/hey scf/nfs-broker-0:/bin/hey
kubectl exec -n scf nfs-broker-0 -c  nfs-broker -ti -- hey -z "${TEST_DURATION}" -q "${TEST_RATE}" -c "${TEST_CONCURRENCY}" -o csv "http://${APP_INTERNAL_URL}" > $BENCH_DATADIR/nogorouter.csv
cat << EOF >> $BENCH_DATADIR/nogorouter.csv
#header: kubectl exec -n scf nfs-broker-0 -c  nfs-broker -ti -- hey -z "${TEST_DURATION}" -q "${TEST_RATE}" -c "${TEST_CONCURRENCY}" -o csv "http://${APP_INTERNAL_URL}"
#footer: Connecting to the app from the internal url
EOF
kubectl exec -n scf nfs-broker-0 -c nfs-broker -ti -- rm -rfv /bin/hey


if [ -f "$ROOT_DIR/create_graphs.sh" ]; then
    bash $ROOT_DIR/create_graphs.sh $BENCH_DATADIR
fi
