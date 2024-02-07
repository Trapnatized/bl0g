#!/bin/bash

rbenv install 3.0.3
rbenv global 3.0.3

gem install bundler jekyll
bundle install
bundle exec jekyll build
