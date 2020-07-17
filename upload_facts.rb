#!/opt/puppetlabs/puppet/bin/ruby
# Uploads yaml files with facts to PuppetDB. These yaml-files are
# in the same format as when created by the Puppet Master when real
# agents report their facts in the beginning of a Puppet Agent execution.
#
# Developed for copying facts from old Puppet Master to new Puppet Master 
# when upgrading Puppet version.
#
# Needs to be ran as a user that has the permissions to read
# the certificate files. Usually root on a Puppet Master.
#
# How to run:
# ./upload_facts.rb /opt/puppetlabs/puppet/cache/yaml/facts/*.yaml
# Or like this:
# ./upload_facts.rb $(puppet config print vardir)/yaml/facts/*.yaml
#
# How to run when developing:
# /opt/puppetlabs/puppet/bin/irb upload_facts.rb

require 'puppet'
require 'puppet/node/facts' # This class is required by the yaml-files.
require 'yaml'
require 'puppet/indirector/facts/puppetdb' # This one might be replaceable with quixoten-puppetdb-terminus.

if ARGV.length < 1
  puts 'usage: upload_facts.rb [files]'
  puts ''
  puts '  files:    A file or a bunch of files to upload to PuppetDB. Should be in yaml-format. Wildcards can be used.'
  puts ''
  exit 1
end

Puppet.initialize_settings
puppetdb = Puppet::Node::Facts::Puppetdb.new

ARGV.each do |file|
  puts "Uploading facts from file: #{file}"
  facts = YAML.load_file(file)
  options = {}
  request = Puppet::Node::Facts.indirection.request(:save, facts.name, facts, options)
  puppetdb.save(request)
end

