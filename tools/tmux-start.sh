#!/bin/bash

tmux new -d -s saltconf17_demo

# window 0 - main
tmux rename-window main

# set up window 1 - salt-master
tmux new-window -n salt-master
tmux send-keys "salt-master -l debug" C-m

# set up window 2 - salt-minion
tmux new-window -n salt-minion
tmux send-keys "salt-minion -l debug" C-m

# set up window 3 - salt-api
tmux new-window -n salt-api
tmux send-keys "salt-api -l debug" C-m

# back to window 0 - main
tmux select-window -t 0

tmux -2 attach-session -d
