require 'pathname'
require 'rubygems'
require 'bacon'
require 'pretty_bacon'
require 'colored'
require 'diffy'
require 'xcodeproj'

# @return [Pathname] The root of the repo.
#
ROOT = Pathname.new(File.expand_path('../', __FILE__)) unless defined? ROOT

# @return [Pathname The folder where the CocoaPods binary should operate.
#
TMP_DIR = ROOT + 'tmp' unless defined? TMP_DIR

# @return [String] The path of the CocoaPods binary to use for the tests.
#
def pod_binary
  ENV['CP_TEST_POD_BINARY'] || "pod"
end

#-----------------------------------------------------------------------------#

TMP_DIR.rmtree if TMP_DIR.exist?
TMP_DIR.mkpath
require "#{ROOT}/test_runner_helper"
include IntegrationRunnerHelpers

puts "Using `#{pod_binary}` pod binary"


#-----------------------------------------------------------------------------#

describe "Integration" do

  describe "Pod install" do

    # TODO: Test installation with no integration
    # TODO: Test subspecs inheritance

    describe "Integrates a project" do
      check "install --no-repo-update", "install_new"
    end

    describe "Adds a Pod to an existing installation" do
      check "install --no-repo-update", "install_add_pod"
    end

    describe "Removes a Pod from an existing installation" do
      check "install --no-repo-update", "install_remove_pod"
    end

    describe "Creates an installation with multiple target definitions" do
      check "install --no-repo-update", "install_multiple_targets"
    end

    describe "Adds an aggregate target to an existing installation" do
      check "install --no-repo-update", "install_multiple_targets_add_target/"
    end

    describe "Removes an aggregate target from an existing installation" do
      check "install --no-repo-update", "install_multiple_targets_remove_target/"
    end

    describe "Installs a Pod with different subspecs activated across different targets" do
      check "install --no-repo-update", "install_subspecs"
    end

    describe "Installs a Pod with a local source" do
      check "install --no-repo-update", "install_local_source"
    end

    describe "Installs a Pod with an external source" do
      check "install --no-repo-update", "install_external_source"
    end

    describe "Installs a Pod given the podspec" do
      check "install --no-repo-update", "install_podspec"
    end

    describe "Performs an installation using a custom workspace" do
      check "install --no-repo-update", "install_custom_workspace"
    end

    # @todo add tests for all the hooks API
    #
    describe "Runs the Podfile callbacks" do
      check "install --no-repo-update", "install_podfile_callbacks"
    end

    describe "Runs the specification callbacks" do
      check "install --no-repo-update", "install_spec_callbacks"
    end

  end

  #--------------------------------------#

  describe "Pod update" do

    describe "Updates an existing installation" do
      check "update --no-repo-update", "update"
    end

  end

  #--------------------------------------#

  describe "Pod lint" do

    describe "Lints a Pod" do
      check "spec lint --quick", "spec_lint"
    end

  end

  #--------------------------------------#

  describe "Pod init" do

    describe "Initializes a Podfile with a single platform" do
      check "init", "init_single_platform"
    end

  end
end


