#!/usr/bin/env bash
set -euxo pipefail

BUILD_PATH=$1

cd $BUILD_PATH
composer install --no-interaction