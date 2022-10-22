# Cli_cmd
This project is to automated-install modern linux commands by `Ansible`.

The following commands are installed.

- [range](https://github.com/ranger/ranger)
- [htop](https://htop.dev/images/htop-2.0.png)
- [fd](https://github.com/sharkdp/fd)
- [bat](https://github.com/sharkdp/bat)
- [gdu](https://github.com/dundee/gdu)
- [duf](https://github.com/muesli/duf)

## Usage
Clone the project
```
git clone https://github.com/git-ogawa/cli_cmd.git
cd cli_cmd
```

Set the ansible properties of the nodes where you want to install commands in `inventory`.

```yml
---
all:
  children:
    targets:
      hosts:
        host1:
          ansible_host: 10.10.10.10
          ansible_user: rocky
          ansible_ssh_port: 22
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

Then, run playbooks.
```
$ ansible-playbook install.yml
```

## Notes
- Debian-based and RHEL-based platforms are supported.
- Only x86_64 (amd64) is supported.
