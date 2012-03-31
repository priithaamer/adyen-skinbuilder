#!/usr/bin/env ruby

$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')
require 'adyen-skinbuilder/server'

use Rack::Reloader, 0

run Adyen::SkinBuilder::Server.new
