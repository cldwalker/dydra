#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'
require 'dydra'

desc "Builds the dydra-x.y.z.gem binary"
task :build do
  sh "mkdir -p pkg"
  sh "gem build .gemspec && mv *.gem pkg/"
end

desc "Builds the dydra-x.y.z.tgz, dydra-x.y.z.tbz and dydra-x.y.z.zip archives"
task :package => ['VERSION', '.gemspec'] do
  gemspec = eval(File.read('.gemspec'))
  package = gemspec.name.to_s
  version = gemspec.version.to_s
  sh "mkdir -p pkg"
  sh "git archive --prefix=#{package}-#{version}/ --format=tar #{version} | gzip > pkg/#{package}-#{version}.tgz"
  sh "git archive --prefix=#{package}-#{version}/ --format=tar #{version} | bzip2 > pkg/#{package}-#{version}.tbz"
  sh "git archive --prefix=#{package}-#{version}/ --format=zip #{version} > pkg/#{package}-#{version}.zip"
end
