#!/bin/bash

gem uninstall -x sal
gem build sal.gemspec
gem install --local sal-1.1.9.gem
