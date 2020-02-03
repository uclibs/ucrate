
#!/bin/bash

# Runs a fixity check to check everything
# Runs as a cron job daily just after midnight

cd "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )"
bundle exec rake scholar:fixity_check 
