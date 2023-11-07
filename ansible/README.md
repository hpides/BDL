# Big Data Lab

This folder contains a collection of ansible playbooks to setup a Big Data Lab on a pi cluster. Before being able to
apply the playbooks, you need to follow steps [1](../tutorial_01_ubuntu_connection_to_pi_cluster.md) and
[2](../tutorial_02_adding_pi_os_to_sd_cards.md) of the tutorial to setup the cluster.

> If you have any questions or problems regarding the ansible playbooks, please reach out to
> [Felix Hoffmann](mailto:felix.hoffmann@student.hpi.uni-potsdam.de).

## Getting Started

To provide a more convenient way to execute the playbooks, `just`[^1] is used. To install it, follow the
[docs](https://github.com/casey/just#installation). Additionally, `poetry` is used to manage the python dependencies. To
install it, follow the provided [docs](https://python-poetry.org/docs/#installation).

Next you should be able to run `just` and `poetry` from the command line.

1. Install the dependencies with `poetry install`
2. Run `just` to see the available commands
3. Run `just <command>` to execute a command

To start and stop hadoop, and other services, you still need to ssh into the name node and run the commands manually.
Alternatively, you can see if there are additional scripts in the [scripts](../scripts/) folder provided.

[^1]: Just is a handy command runner for project-specific tasks

## Playbooks, Roles, and Configuration

- All hosts are defined in the [inventory](./inventory) file
- The [playbooks](./playbooks) folder contains all playbooks
  - A playbook is a collection of roles and tasks to be applied to a set of hosts
- The [roles](./roles) folder contains all roles
  - A role is a collection of tasks and files to be applied to a host
