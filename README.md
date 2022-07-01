# spin-dojo-image-base

This project builds a docker image that you can use with the [dojo](https://github.com/kudulab/dojo) tool to have a consistent environment for working with infrastructure stack projects using [cloudspin tools](https://github.com/kief/spin-tools). It's mainly aimed at local development.

So as a stack developer, you set up your stack project to use this dojo image (more info on how to do this below). Then you run the dojo command to start a docker instance which has the various tools and packages installed to run and test your stack code. This avoids you needing to install and configure tools (other than Docker and Dojo), and ensures that everyone who works with the stack code has a consistent local environment, defined as code.

The cloudspin tools give you a consistent way to work with infrastructure stack code across environments, and to integrate multiple stacks into cohesive environments.

This Dojo image is aimed at working with Terraform projects that define infrastructure for AWS.

Tested and released images are published to dockerhub as [kiefm/spin-dojo-image-base](https://hub.docker.com/r/kiefm/spin-dojo-image-base)


This project is very much in progress, and currently has limitations that will make it difficult to use out of the box.


# How-to guides

## How to use this Dojo image on a project that has it installed already

Prerequisites:

1. Docker (I use colima on my Mac)
2. [Dojo](https://github.com/kudulab/dojo) (I install it on my Mac with homebrew)

Usage:

Change into the project folder. Make sure it has a Dojofile. Then run 'dojo' to download and start the image. You should end up on a prompt, where you can run `spin-stack` commands.


## How to add this Dojo image to a stack project

Create a Dojofile:

```
DOJO_DOCKER_IMAGE="kiefm/spin-dojo-image-base:latest"
```

By default, current directory in docker container is `/dojo/work`.


## How to make changes to and build this Dojo image

Set up docker hub so the image can be built and published.

Set environment variable: `DOCKERHUB_TOKEN`

(I like to do this in a .direnv file)

Install bats for running tests (I use [homebrew for bats-core](https://github.com/bats-core/homebrew-bats-core))


## Lifecycle

1. Build locally: `./tasks build_local`
2. Run tests: `./tasks itest`
3. Repeat above steps until ready
4. Update the version in the CHANGELOG: `./tasks set_version x.y.x` to set version in CHANGELOG
5. Push changes
6. CI server (GoCD) tests and releases:
   a. `./tasks release`
   b. `./tasks publish`


# Reference: What's in this docker image

Check out the image/Dockerfile to understand what's in the image. A summary:

 * base image is alpine, to make this image as small as possible
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

