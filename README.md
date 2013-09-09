# CocoaPods Integration Specs

The following integrations tests are based on file comparison.


## Adding a new test

To create a new test follow the following steps:
- Create a folder with a descriptive name for the new test. The naming
  convention is to prepend the CocoaPods sub-command which will be tested.
- Create a before folder and populate it with the environment in which the test
  should be run. If the folder will include a CocoaPods installation name the
  Podfile used to generate it `Podfile-before`. The `Podfile` instead should
  include the contents which will be used by the CocoaPods binary.
- Run the `$ rake install_before_folders` command.
- Run the `$ rake rebuild_after_folders` command.
- Commit the relevant files and push.


## How the tests are performed

1. For each test there is a folder with a `before` and `after` sub-folders.
2. The contents of the before folder are copied to the `TMP_DIR` folder and
   then the given arguments are passed to the `POD_BINARY`.
3. After the pod command completes the execution each file in the `after`
   sub-folder is compared to be to the contents of the temporary directory.  If
   the contents of the file do not match an error is registered. Xcode projects
   are compared in an UUID agnostic way.


## Notes

- The rake tasks of this repo do not use bundler to avoid interference with the
  bundle on the CocoaPods binary. To use the repo with the binary present in
  the path the `install_gems` task can be used. If bundler is used by the
  CocoaPods binary its Gemfile should include all the gems listed in that task.
- The output of the pod command is saved in the `execution_output.txt` file
  which should be added to the `after` folder to test the CocoaPods UI.


## Rationale

- Have a way to track precisely the evolution of the artifacts (and of the
  UI) produced by CocoaPods though the diff provided by the git commits.
- Allow users to submit pull requests with the environment necessary to
  reproduce an issue.
- Have robust tests which don't depend on the programmatic interface of
  CocoaPods. These tests depend only the binary and its arguments an thus are
  suitable for testing CP regardless of the implementation (they could even
  work for an Objective-C one)
