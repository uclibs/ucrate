# UCRATE

## About

UCRATE is a [Hydra-based](https://github.com/projecthydra/) digital content management back-end, in development to support digital content stewarded by the [University of Cincinnati Libraries](https://www.libraries.uc.edu/).

## Installing development instance

Using Ruby 2.3.1, clone this repository and do:

```bash
bundle install
rake db:migrate
```

Then in new windows, in the root application directory, start Solr Wrapper:
```bash
solr_wrapper -p 8983 -d solr/config/ --collection_name hydra-development
```

And Fedora Wrapper:
```bash
fcrepo_wrapper -p 8984 --no-jms
```

And start with `rails server`

## User accuonts

There is no current restriction on user account abilities.

## Testing

For specs, run these with the following commands (for different ports):
```bash
solr_wrapper -p 8985 -d solr/config/ --collection_name hydra-test
fcrepo_wrapper -p 8986 --no-jms
rspec
```

Or just run: `rake ci`

## Development guidelines

TBD: brief notes about review guidelines and link to more extensive wiki page
