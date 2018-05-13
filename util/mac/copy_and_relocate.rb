#!/usr/bin/env ruby
require 'macho'
require 'set'
require 'fileutils'

@deps = Hash.new []
@fixed = Set.new []
@target_dir = '/Library/Application Support/obs-studio/plugins/libtext-pango/bin'

def pull_deps(lib_file)
	lib = MachO::MachOFile.new(lib_file)
	ndeps = Hash.new []
	for d in lib.linked_dylibs
	            .select{|c| not (/^(\/System|\/usr\/lib|@rpath)/ =~ c)}
		lib.change_install_name(d, "#{@target_dir}/deps/#{File.basename(d)}")
		ndeps[File.basename(d)] = d
	end
	lib.write!
	ndep_files = Set.new(ndeps.keys) - Set.new(@deps.keys)
	for d in ndep_files
		@deps[d] = ndeps[d]
		FileUtils.cp(ndeps[d], "./deps/#{d}")
		FileUtils.chmod(0644, "./deps/#{d}")
	end
end

pull_deps(ARGV[0]) # seed deps/fixed
puts "Pulled deps for #{ARGV[0]}"
unfixed = Set.new(@deps.keys) - @fixed
until unfixed.empty?
	for u in unfixed
		@fixed.add(u)
		u = "./deps/#{u}"
		puts "Pulling deps for #{u}"
		pull_deps(u)
	end
	unfixed = Set.new(@deps.keys) - @fixed
end
