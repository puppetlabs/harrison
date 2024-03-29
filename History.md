0.9.2
-------------------
- Bumped dependencies on highline and bundler to latest majors

0.9.1
-------------------
- Bumped dependencies on net-ssh and net-scp to latest majors

0.9.0
-------------------
- Added ability to package via Docker
- Added ability to generate multiple builds from a single invocation (when building via Docker)

0.8.0
-------------------
- BREAKING: Bumped required Ruby version to >= 2.3.1
- Bumped net-ssh to 5.2.x
- Bumped net-scp to 2.0.x

0.7.0
-------------------
- Added ability to calculate build host dynamically in package task.

0.6.0
-------------------
- Added ability to package from forks. When packaging from HEAD or a branch,
  harrison will now check to see if that branch is tracking a remote branch.
  If so, it will attempt to package code from that remote. If the branch
  being packaged is not tracking a remote branch, or if what is being packaged
  is not a branch, harrison will look for a remote named "origin" and package
  from there. Lastly, if there is not a remote named "origin", it will package
  from the configured "git_src".

0.5.0
-------------------
- BREAKING: Bumped net-ssh to 3.2.x which results in Harrison now
  requiring Ruby >= 2.0.

0.4.0b1
-------------------
- Fixed a bug where config changes inside of one task could leak into
  other tasks. (#22)

- Added the ability to limit the number of times a given phase will be
  invoked during a deploy. (E.g. run a task on only the first host
  deployed to.)

- Added the ability for target hosts to be a Proc so that hosts can be
  dynamically computed.

- Added the ability to require interactive confirmation of target hosts
  before proceeding with a deploy.

0.3.0
-------------------
- BREAKING: Definition of "deploy" task has significantly changed. Deploys
  are now comprised of 1 or more phases and each phase must complete
  successfully on all hosts before proceeding to the next phase. If an
  error is encountered, Harrison will attempt to unwind any changes made
  by previously completed phases by invoking the code block supplied to
  each phase's "on_fail" method. There are several built-in phases to
  perform common deployment related tasks. See the README for more
  information.

- BREAKING: Commands executed with remote_exec() inside the "run" block of
  the "package" task will now execute in your commit working directory, so
  you no longer need to prefix commands with "cd #{h.commit}". You will
  need to update existing Harrisonfile "package" run blocks to reflect the
  change of execution context.

- Allow multiple users to execute the "package" task for the same project
  simultaneously.

- Added "rollback" command which will create a new deploy pointing to the
  previously active release.

0.2.0
-------------------
- Implemented the ability to purge old releases after a successful deploy.

0.1.0
-------------------
- Renamed --pkg_dir option of 'package' task to --destination
- Implemented remote destinations for 'package' task.
- Implemented remote artifact sources for 'deploy' task.
- Added a default timeout of 10 seconds when establishing an SSH connection.

0.0.1
-------------------
- Initial public release.
