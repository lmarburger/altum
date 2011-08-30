#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs    << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

desc 'Default: run tests'
task :default => 'test'
