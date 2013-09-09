
module IntegrationRunnerHelpers

  #---------------------------------------------------------------------------#

  # Performs the checks for the test with the given folder using the given
  # arguments.
  #
  # @param [String] arguments
  #        The arguments to pass to the Pod executable.
  #
  # @param [String] folder
  #        The name of the folder which contains the `before` and `after`
  #        sub-folders.
  #
  def check(arguments, folder)
    focused_check(arguments, folder)
  end

  # Shortcut to focus on a test: Comment the implementation of #check and
  # call this from the relevant test.
  #
  def focused_check(arguments, folder)
    copy_files(folder)
    executed = launch_binary(arguments, folder)
    run_post_execution_actions(folder)
    check_with_folder(folder) if executed
  end

  #---------------------------------------------------------------------------#

  # Copies the before subdirectory of the given tests folder in the temporary
  # directory.
  #
  # @param  [String] folder
  #         the name of the folder of the tests.
  #
  def copy_files(folder)
    source = File.expand_path("#{ROOT}/#{folder}/before", __FILE__)
    destination = TMP_DIR + folder
    destination.mkpath
    FileUtils.cp_r(Dir.glob("#{source}/*"), destination)
  end

  # Runs the Pod executable with the given arguments in the temporary directory.
  #
  # @param  [String] arguments
  #         the arguments to pass to the CocoaPods binary.
  #
  # @note   If the pod binary is called with the ruby executable it requires
  #         bundler ensuring that the execution is performed in the correct
  #         environment.
  #
  def launch_binary(arguments, folder)
    it "$ pod #{arguments}" do
      Dir.chdir(TMP_DIR + folder) do
        command = "CP_AGGRESSIVE_CACHE=TRUE #{pod_binary} #{arguments} --verbose --no-color 2>&1"
        output = `#{command}`
        $?.should.satisfy("Pod binary failed\n\n#{output}") do
          $?.success?
        end

        File.open('execution_output.txt', 'w') do |file|
          file.write(command.gsub(pod_binary, '$ pod'))
          file.write(output.gsub(ROOT.to_s, 'ROOT').gsub(%r[/Users/.*/Library/Caches/CocoaPods/],"CACHES_DIR/"))
        end
      end
    end
    $?.success?
  end

  # Creates a YAML representation of the Xcodeproj files which should be used as
  # a reference.
  #
  def run_post_execution_actions(folder)
    Dir.glob("#{TMP_DIR + folder}/**/*.xcodeproj") do |project_path|
      xcodeproj = Xcodeproj::Project.open(project_path)
      require 'yaml'
      pretty_print = xcodeproj.pretty_print
      sections = []
      sorted_keys = ['File References', 'Targets', 'Build Configurations']
      sorted_keys.each do |key|
        yaml =  { key => pretty_print[key]}.to_yaml
        sections << yaml
      end
      file_contents = (sections * "\n\n").gsub!("---",'')
      File.open("#{project_path}.yaml", 'w') do |file|
        file.write(file_contents)
      end
    end
  end

  # Creates a requirement which compares every file in the after folder with the
  # artifacts created by the pod executable in the temporary directory according
  # to its file type.
  #
  # @param  [String] folder
  #         the name of the folder of the tests.
  #
  def check_with_folder(folder)
    source = File.expand_path("#{ROOT}/#{folder}", __FILE__)
    Dir.glob("#{source}/after/**/*") do |expected_path|
      next unless File.file?(expected_path)
      relative_path = expected_path.gsub("#{source}/after/", '')
      expected = Pathname.new(expected_path)
      produced = TMP_DIR + folder + relative_path

      case expected_path
      when %r[/xcuserdata/], %r[\.pbxproj$]
        # Projects are compared through the more readable yaml representation
        next
      when %r[execution_output.txt$]
        # TODO The output from the caches changes on Travis
        next
      end

      it relative_path do
        case expected_path
        when %r[Podfile\.lock$], %r[Manifest\.lock$], %r[xcodeproj\.yaml$]
          file_should_exist(produced)
          yaml_should_match(expected, produced)
        else
          file_should_exist(produced)
          file_should_match(expected, produced)
        end
      end
    end
  end


  # @!group File Comparisons
  #---------------------------------------------------------------------------#

  # Checks that the file exits.
  #
  # @param [Pathname] file
  #        The file to check.
  #
  def file_should_exist(file)
    file.should.exist?
  end

  # Compares two lockfiles because CocoaPods 0.16 doesn't oder them in 1.8.7.
  #
  # @param [Pathname] expected
  #        The reference in the `after` folder.
  #
  # @param [Pathname] produced
  #        The file in the temporary directory after running the pod command.
  #
  def yaml_should_match(expected, produced)
    expected_yaml = YAML::load(File.open(expected))
    produced_yaml = YAML::load(File.open(produced))
    # Remove CocoaPods version
    expected_yaml.delete('COCOAPODS')
    produced_yaml.delete('COCOAPODS')

    desc = []
    unless expected_yaml == produced_yaml
      desc << "YAML comparison error `#{expected}`"

      desc << ("--- YAML DIFF " << "-" * 65)
      diffy_diff = ''
      Diffy::Diff.new(expected.to_s, produced.to_s, :source => 'files', :context => 3).each do |line|
        case line
        when /^\+/ then diffy_diff << line.green
        when /^-/ then diffy_diff << line.red
        else diffy_diff << line
        end
      end
      desc << diffy_diff
      desc << ("--- END " << "-" * 70)
    end

    expected_yaml.should.satisfy(desc * "\n\n") do
      if RUBY_VERSION < "1.9"
        true # CP is not sorting array derived from hashes whose order is
        # undefined in 1.8.7
      else
        expected_yaml == produced_yaml
      end
    end
  end

  # Compares two files to check if they are identical and produces a clear diff
  # to highlight the differences.
  #
  # @param [Pathname] expected @see #yaml_should_match
  # @param [Pathname] produced @see #yaml_should_match
  #
  def file_should_match(expected, produced)
    is_equal = FileUtils.compare_file(expected, produced)
    description = []
    unless is_equal
      description << "File comparison error `#{expected}`"
      description << ""
      description << ("--- DIFF " << "-" * 70)
      Diffy::Diff.new(expected.to_s, produced.to_s, :source => 'files', :context => 3).each do |line|
        case line
        when /^\+/ then description << line.gsub("\n",'').green
        when /^-/ then description << line.gsub("\n",'').red
        else description << line.gsub("\n",'')
        end
      end
      description << ("--- END " << "-" * 70)
      description << ""
    end
    is_equal.should.satisfy(description * "\n") do
      is_equal == true
    end
  end
end
