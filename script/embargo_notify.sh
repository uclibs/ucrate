cd /srv/apps/curate_uc
export PATH=$PATH:/srv/apps/.gem/ruby/2.7.0/bin
RAILS_ENV=production bundle exec rake embargo_notify
