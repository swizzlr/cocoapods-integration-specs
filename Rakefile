require 'pathname'

desc "Updates the before folders"
task :update_before_folders do
  Pathname.pwd.children.each do |child|
    if child.directory?
      Dir.chdir(child + 'before') do |sub_child|
        pods_dir = Pathname.new(sub_child) + 'Pods'
        if (pods_dir).exist?
          FileUtils.rm_rf(pods_dir.to_s)
          puts "\nDIR: #{sub_child}"
          puts `pod`
        end
      end
    end
  end
end
