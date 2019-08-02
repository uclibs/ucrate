#!/bin/bash
MODE=$1
tmux kill-session -t localhost 2> /dev/null
source "$HOME/.rvm/scripts/rvm"
cd "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )"
tmux new-session -As localhost -d
tmux split-window -h
tmux select-pane -t 0
tmux split-window -v
tmux select-pane -t 2
tmux split-window -v
tmux send-keys -t 0 "bundle exec fcrepo_wrapper -p 8984" C-m
tmux send-keys -t 1 "bundle exec solr_wrapper -d solr/config/ --collection_name hydra-development" C-m
tmux send-keys -t 2 "redis-server" C-m
tmux send-keys -t 3 "rails server" C-m

if [ $MODE == "migrate" ]; then
    bin/rails hyrax:default_admin_set:create
    bundle exec rails hyrax:default_collection_types:create
    bin/rails hyrax:workflow:load
fi