#!/bin/sh
MIGRATE=$1
tmux new-session -As localhost -d
tmux split-window -h
tmux select-pane -t 0
tmux split-window -v
tmux select-pane -t 2
tmux split-window -v
tmux send-keys -t 0 "bundle exec fcrepo_wrapper -p 8984" C-m
tmux send-keys -t 1 "bundle exec solr_wrapper -d solr/config/ --collection_name hydra-development" C-m
tmux send-keys -t 2 "redis-server" C-m
tmux send-keys -t 3 "bundle exec rails server" C-m
# tmux select-pane -t 1
# tmux split-window -v
# tmux send-keys -t 2 "bundle exec sidekiq" C-m
# Note: You only need to run the migrations if you have not on the host
if [[ $MIGRATE == "migrate" ]]; then
    bundle exec rake db:migrate
    wait
    bin/rails hyrax:default_admin_set:create
    bundle exec rails hyrax:default_collection_types:create
    bin/rails hyrax:workflow:load
fi