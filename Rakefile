require 'pathname'

def pod_binary
  ENV['CP_TEST_POD_BINARY'] || "pod"
end

desc "Updates the before folders"
task :install_before_folders do
  Pathname.pwd.children.each do |child|
    if child.directory?
      Dir.chdir(child + 'before') do |sub_child|
        sub_child = Pathname.new(sub_child)
        pods_dir = sub_child + 'Pods'
        if (pods_dir).exist?
          podfile_before = sub_child + 'Podfile-before'
          podfile = sub_child + 'Podfile'
          podfile_after = sub_child + 'Podfile-after-tmp'
          FileUtils.mv(podfile, podfile_after)
          FileUtils.mv(podfile_before, podfile)

          FileUtils.rm_rf(pods_dir.to_s)
          puts "\nDIR: #{sub_child}"
          puts `#{pod_binary}`

          FileUtils.mv(podfile, podfile_before)
          FileUtils.mv(podfile_after, podfile)
        end
      end
    end
  end
end
