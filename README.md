# CF Benchmarking utilities

This repository contains recipes and utils to benchmark CF and applications pushed to it.

## Creating workload

You might need to replicate a "busy" environment in lab, you can download and install [PAT](https://github.com/cloudfoundry-incubator/pat) to simulate workload on your CF environment, for example:

```bash
$>  pat -app assets/hello-world -concurrency 3 -iterations 10
```

## Benchmarking

![api](https://user-images.githubusercontent.com/2420543/85020002-f8b02100-b16f-11ea-8a8a-ea22e6882203.png)

```bash
$> bash start_benchmark.sh
```

The benchmarking script will perform benchmarks and collect the results of the following scenarios:
- From the host to the public CF API
- From the host to the public app url
- From an internal CF component(nfs-broker) to the internal app url

`start_benchmark.sh` requires `cf-cli` to be logged in within the testing targeted space. It uses also `kubectl` to 
run tests against a pushed application to the targeted cluster. Finally it requires `gnuplot` to draw the resulting graphs.

It uses [hey](https://github.com/rakyll/hey) and accepts several parameters to tweak the benchmarking behavior.

It creates a new folder `bench-<date>-<duration>-<concurrency>` with all the generated csv from the test. It automatically generates graphs from the csv as well with  `gnuplot`.

If you don't need graphs to be generated, just don't copy over the `create_graphs.sh` script.

### Target a specific app

```bash
$> APP_URL="my-app.127.0.0.1.nip.io" APP_NAME="my-app" bash start_benchmark.sh
```
### Change concurrency and requests intervals

```bash
$> TEST_CONCURRENCY="2" TEST_RATE="2" TEST_DURATION="1m" bash start_benchmark.sh
```

## Graphs

There is an utility script that converts all the generated `*.csv` files from `hey` to graphs using `gnuplot`.

```bash
$> bash create_graphs.sh <benchmark-dir>
```
