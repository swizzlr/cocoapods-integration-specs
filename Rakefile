require 'pathname'

def pod_binary
  ENV['CP_TEST_POD_BINARY'] || "pod"
end

#-----------------------------------------------------------------------------#

desc "Runs the tests"
task :run do
  sh "bacon test_runner.rb"
end

task :default => :run

#-----------------------------------------------------------------------------#

desc "Installs the required gems"
task :install_gems do
  gems = [
    "colored",
    "xcodeproj",
    "diffy",
    "mocha-on-bacon",
    "rake",
    'bacon',
    'prettybacon',
  ]
  sh "gem install #{gems.join(' ')}"
end

#-----------------------------------------------------------------------------#

desc "Updates the before folders"
task :install_before_folders do
  Pathname.pwd.children.each do |test_dir|
    if test_dir.directory?
      test_dir = Pathname.new(test_dir)
      before_dir = test_dir + 'before'
      pods_dir = before_dir + 'Pods'

      if (pods_dir).exist?
        Dir.chdir(before_dir) do |dir|
          podfile_before = 'Podfile-before'
          podfile = 'Podfile'
          podfile_after = 'Podfile-after-tmp'
          FileUtils.mv(podfile, podfile_after)
          FileUtils.mv(podfile_before, podfile)

          FileUtils.rm_rf(pods_dir.to_s)
          puts "\nDIR: #{before_dir}"
          puts `#{pod_binary}`

          FileUtils.mv(podfile, podfile_before)
          FileUtils.mv(podfile_after, podfile)
        end
      end
    end
  end
end

#-----------------------------------------------------------------------------#

desc "Remove files not used for the comparison from the after folders"
task :clean do
  files_to_delete = FileList['*/after/{Podfile,Podfile-before,*.podspec,**/*.xcodeproj,PodTest-hg-source}']
  files_to_delete.exclude('/init_single_platform/**/*.*')
  files_to_delete.each do |file_to_delete|
    sh "rm -rf #{file_to_delete}"
  end
end

#-----------------------------------------------------------------------------#

desc "Rebuilds the after folders from scratch with the results produced by running the tests"
task :rebuild_after_folders do
  puts 'Running tests'
  `bacon test_runner.rb`

  puts 'Storing after folders'
  FileList['tmp/*'].each do |source|
    destination = "#{source.gsub('tmp/','')}/after"
    if File.exists?(destination)
      sh "rm -rf #{destination}"
      sh "mv #{source} #{destination}"
    end
  end
  Rake::Task[:clean].invoke

  puts
  puts "Integration fixtures updated"
end

#-----------------------------------------------------------------------------#

desc "Rebuilds everything with the given pod binary"
task :rebuild_all => [:install_before_folders, :rebuild_after_folders]
