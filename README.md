# Tuttle

[![Build Status](https://api.travis-ci.org/dgynn/tuttle.svg?branch=develop)](https://travis-ci.org/dgynn/tuttle)
[![Code Climate](https://codeclimate.com/github/dgynn/tuttle/badges/gpa.svg)](https://codeclimate.com/github/dgynn/tuttle)
[![Test Coverage](https://codeclimate.com/github/dgynn/tuttle/badges/coverage.svg)](https://codeclimate.com/github/dgynn/tuttle)
[![Dependency Status](https://gemnasium.com/dgynn/tuttle.svg)](https://gemnasium.com/dgynn/tuttle)

Tuttle is a tool for assisting Rails developers by exposing runtime configuration information for your application. It is similar to the `/rails/info/routes` and `/rails/info/properties` information pages or the `rake routes` and `rake middleware` tasks.

Tuttle is very much in alpha/proof-of-concept mode. You can see it in action in a [simple demo application](http://tuttle-demo.herokuapp.com/). The [source code](https://github.com/dgynn/tuttle-demo) for that demo is also on GitHub.

## To use...

Add tuttle to you Gemfile
```ruby
gem 'tuttle', :github => 'dgynn/tuttle', :branch => 'develop'
```
Browse to `/tuttle`
