saltconf17_demo:
  docker_container.running:
    - hostname: saltconf-demo
    - interactive: True
    - tty: True
    - image: saltconf17:latest
    - binds:
      - /home/gareth/code/saltconf17/conf/master.d:/etc/salt/master.d
      - /home/gareth/code/saltconf17/conf/pki/master:/etc/salt/pki/master
      - /home/gareth/code/saltconf17/conf/pki/minion:/etc/salt/pki/minion
      - /home/gareth/code/saltconf17/conf/ssl:/etc/salt/ssl
      - /home/gareth/code/saltconf17/conf/minion.d:/etc/salt/minion.d
      - /home/gareth/code/saltconf17/_modules:/srv/salt/_modules
      - /home/gareth/code/saltconf17/reactor:/srv/reactor
      - /home/gareth/code/saltconf17/saltmaster-project:/devops/projects/saltmaster
      - /home/gareth/code/saltconf17/pillar:/srv/pillar
      - /home/gareth/code/saltconf17/tools:/tools
    - command: /tools/tmux-start.sh
