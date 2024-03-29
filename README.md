# spin-dojo-image

*NOTE:* _This is not a ready-to-use project, it's more like an executable cocktail napkin that I'm using to sketch out ideas for building, testing, and delivering infrastructure projects._

This project builds a docker image that you can use with the [dojo](https://github.com/kudulab/dojo) tool to have a consistent local development environment for working with infrastructure code, with useful tools preinstalled. It is the base image for [spin-tools](https://github.com/cloudspinners/spin-tools), which adds some scripts that help to manage infrastructure projects.

Tested and released images are published to dockerhub as [kiefm/spin-dojo-image](https://hub.docker.com/r/kiefm/spin-dojo-image).


## What's in here

In addition to basic useful utilities, the image includes terraform, inspec (rspec-based testing framework), bats (shell script-based testing framework), the aws CLI (note, this is an old version because of compatibility issues with Alpine linux not having glibc).


# How-to guides

## How to add the Dojo image to a project

Create a Dojofile:

```
DOJO_DOCKER_IMAGE="kiefm/spin-dojo-image:latest"
```

By default, the current directory in the docker instance is `/dojo/work`.


## How to use the Dojo image

Prerequisites:

1. Docker (I use colima to install it on my Mac)
2. [Dojo](https://github.com/kudulab/dojo) (I install it on my Mac with homebrew)

Usage:

Change into the project folder. Make sure it has a Dojofile. Then run 'dojo' to download and start the image. You should end up on a prompt, where you can run commands.


## How to make changes to and build this Dojo image

Set up docker hub so the image can be built and published.

Set environment variable: `DOCKERHUB_TOKEN`

(I like to do this in a .direnv file)

Install bats for running tests (I use [homebrew for bats-core](https://github.com/bats-core/homebrew-bats-core))


## Lifecycle

1. Build locally: `./tasks build_local`
2. Run tests: `./tasks itest`
3. Repeat above steps until ready
4. Push changes to build and publish a new "latest"
5. Edit the CHANGELOG and increment the version number in the first line to trigger a new release


# Reference: What's in this docker image

Check out the image/Dockerfile to understand what's in the image. A summary:

 * base image is alpine Linux, to make this image as small as possible
 * terraform binary on the PATH
 * `jq` to parse JSON from bash scripts
 * `dot` to generate infrastructure graphs from terraform
 * a minimal ssh and git setup - to clone terraform modules


## Configuration
Those files are used inside the docker image:

1. `~/.ssh/` -- is copied from host to dojo's home `~/.ssh`
1. `~/.ssh/config` -- will be generated on docker container start. SSH client is configured to ignore known ssh hosts.
1. `~/.aws/` -- is copied from host to dojo's home `~/.aws`
2. `~/.gitconfig` -- if exists locally, will be copied
3. `~/.profile` -- will be generated on docker container start, in
   order to ensure current directory is `/dojo/work`.
4. For openstack access - environment variables must be locally set:
 `[ 'OS_AUTH_URL', 'OS_TENANT_NAME', 'OS_USERNAME',
   'OS_PASSWORD']`. Dojo will pass them to the docker image.
5. For AWS access `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` must be set.

To enable debug output:
```
OS_DEBUG=1 TF_LOG=debug
```

Full spec is [ops-base](https://github.com/kudulab/ops-base)


Based on [docker-terraform-dojo](https://github.com/kudulab/docker-terraform-dojo) from Ewa Czechowska, Tomasz Sętkowski

