#!/usr/bin/env ruby
require 'macho'
require 'set'
require 'fileutils'

@deps = Set.new []
@fixed = Set.new []
@target_dir = '/Library/Application Support/obs-studio/plugins/libtext-pango/bin'

def pull_deps(lib_file)
	lib = MachO::MachOFile.new(lib_file)
	ndeps = Set.new []
	for d in lib.linked_dylibs
	            .select{|c| not (/^(\/System|\/usr\/lib|@rpath)/ =~ c)}
		lib.change_install_name(d, "#{@target_dir}/deps/#{File.basename(d)}")
		ndeps << d
	end
	lib.write!
	ndeps = ndeps - @deps
	@deps.merge(ndeps)
	for d in ndeps
		FileUtils.cp(d, "./deps/#{File.basename(d)}")
		FileUtils.chmod(0644, "./deps/#{File.basename(d)}")
	end
end

pull_deps(ARGV[0]) # seed deps/fixed
puts "Pulled deps for #{ARGV[0]}"
unfixed = @deps - @fixed
until unfixed.empty?
	for u in unfixed
		@fixed.add(u)
		u = "./deps/#{File.basename(u)}"
		puts "Pulling deps for #{u}"
		pull_deps(u)
	end
	unfixed = @deps - @fixed
end
