1.6.0 (Scholar 4.6.0) 3/29/2022
* Configured x-ray logs
* Update gems (nokogiri, addressable, rexml, rack, puma, browse_everything
* Sets custom URI parsers for access controls
* Adds brakeman and bundler_audit
* Upgrade to Ruby 2.7.5
* Upgrade to Hyrax 2.9.6
* New contact form created with jot form
* Upgrade to Rails 5.2.4.6
* Bug Fixes
         * Escape output for mark_helper
         * Fix catalog popup bug
         * Unhide share tab
         * Fix capatability list security vulnerability
         * Redirect deny access users to uc central login

1.5.0 (Scholar 4.5.0) 4/3/2021
* Removed link to What’s New
* Movd collection information on show page
* Hid relationship partial if empty
* Highlight search terms in discovery
* Installed and configured Bulkrax admin tool
* Added filesystem to BrowseEverything
* Updated the FAQ
* Updated to Hyrax 2.9.4
* Updatesd to Ruby 2.7.2
* Installed clamby for virus protection.
* Installed cloudwatch and x-ray for monitoring.
* Bug Fixes
	 * Attribute label overlap
	 * Human readable video type in catalog

1.4.0 (Scholar 4.4.0) 2/7/2020
* Added Research Directory to user profile
* Built Rest API
* Added support for Dropbox and Google Drive
* Updated to Hyrax 2.6.0
* Pinned sidekiq to version 5.2.7
* Updated puma to version 4.3.1
* Updated ruby to version 2.5.5
* Updated nokogiri to version 1.10.5
* Added fixity checking task
* Added all of the fields to the works manifest
* Bug Fixes
   * Fixed broken links on home page
   * Fixed travis bundler errors

1.3.0 (Scholar 4.3.0) 11/21/2019
* Add Docker support
* Update welcome email
* Upgrade Hyrax gem to 2.5.1
* update FAQ page
* Add Capistrano support
* Bug Fixes
    * Fix auto-fill for the publisher field
    * Change DOI link on work show page
    * Change Discovery to Visibility
    * Stop parameterizing worktype in work show view
    * Fix auto-populate creator
    * Resolve blacklight deprecation
    * Set flash message for publisher/doi validation
    * Always show english worktype in work show view
    * Fix DOI emabrgo change
    * Reinstate orcid about page

1.2.0 (Scholar 4.2.0) 7/25/2019
* Added seeds for each work type with all metadata filled out 
* Upgraded riiif to version 2.0
* Updated chromedriver version on Travis to match Chrome version
* Added date uploaded and date modified to work show page
* Updated DOI labels to use explicite name
* Updated bootstrap-sass gem version
* Updated change_manager gem version
* Replaced chromedriver with webdrivers for capybara tests
* Enabled notifications for editor removal
* Added college field to user profile page
* Updated the welcome page
* Updated vulnerable gems
* Limited description to 5 lines on catalog index page
* Added support for DataCite JSON API
* Added link to parent work when viewing child work
* Updated Chinese and Spanish translations
* Bug fixes
    * Aligned time period field on Media work form                    
    * Updated shibboleth attributes on every login
    * Corrections to collections export 
    * Re-enabled DOI in bulk ingest
    * Implemented changes to static page line lengths
    * Users are prevented from adding themselves as a proxy
    * Fixed contact form error messages
    * Added missing fields to works manifest
    * Fixed file labels in create work
    * Changed padding to margin to avoid visible text after ellipses
    * Fixed broken links in static pages

1.1.0 (Scholar 4.1.0) 2/27/2019
* Collections can now be exported to .csv files
* The order that fields are displayed on work pages has been updated
* Work pages now display the last modified date
* Bug fixes
    * Solr reindexing no longer times out
    * Collection descriptions are now displayed
    * The featured work image on the home page is now properly aligned
    * The CAPTCHA on the contact form now works properly
    * The Department facet now only shows after the College facet has been selected
    * User atrributes for UC Central Logins are now properly used
    * Description and Date Created fields are now singular on batch create
    * The user's language choice now persists in all parts of the application
    * Field labels are not shown for empty metadata fields
    * The password reset from address is now scholar@uc.edu
    * Batch create now requires files to be uploaded to be saved
    * Creating and then immediately deleting a proxy no longer errors
    * The ETD work page now shows proper labels for Degree and Degree Program

1.0.0 (Scholar 4.0) 1/24/2019
* Updated to Hyrax version 2.3.3
* Updated to Ruby version 2.5.3
* Ported over from Scholar
    * Proxy removal
    * Facet configuration
    * 404 error page instead of template
    * Change Manager
    * Sorting and reverse sorting alphabetically.
    * Footer elements
    * Toolbar links
    * ETD committe members
    * Flash message wording
* Disabled Hyrax features
    * Citation features
    * BrowseEverything on batch create
    * Rights on all forms
    * Collection export
    * Search label
* Enhancements
    * Updated collection form by removing unnecessary fields
    * Updated license view in collections
    * Set new collection default visibility to public
    * Added contextual help for proxy management
    * Implemented autocomplete on specific new work form fields
    * Enabled the collection facet
    * Added a What's New page
    * Made session and login cookies secure on production
    * Updated Spanish and Mandarin translations 
    * Added batch upload
    * Added noid initializer
    * Restructured file uploader and added new CSS classes
* Bug Fixes
    * Added Mendely meta-tags
    * Fixed collection license persistence
    * Implemented accessibility violation fixes
    * Fixed owner file permission problem with proxy deposit
    * Got original filename for box files
    * Deleted the double quote if the description or note ends in double quote
    * Handled slashes in paths for riiif
    * Fixed Etd type_field and publisher field
    * Fixed managed works title wrapping in Dashboard
    * Resolved bug that shows department field incorrectly

0.6.0 7/20/2018
* Ported over Scholar features
    * Replicated home page content
    * Replicated "jumbotron" home page image
    * Replicated featured researcher/collection/work
    * Migrated metadata profiles for all work types
    * Updated content on static pages
    * Updated the embargo notify task
    * Updated the sitemap generator
    * Applied bug fix to welcome page
    * Removed the group sharing option from works
    * Added help message to Dataset work type
    * Fixed bug that broke user search with trailing white space
    * New works now default to public visibility
    * Replicated the "What are you uploading?" page
    * Removed admin set controls from works

0.5.0 7/6/2018
* Updated to Hyrax version 2.1.0 (final)
* Added the bixby gem (for rubocop inheritance)
* Ported over Scholar features
    * Added a "Browse" button to the main search bar
    * Added permalinks to works, files, collections, and profiles
    * Changed the product name to "Scholar@UC"
    * Updated the navbar menu links to match Scholar's navbar
    * Incorporated recent changes from Scholar's People page
    * Updated the text in the Visibility pane to match Scholar
    * Line breaks are now preserved for work description fields

0.4.0 05/30/2018
* Update to ruby 2.5.1
* Updated to Hyrax v2.1.0.rc3
* Added /show/ path for works, files, and collections
* Removed the lease choice for work visibility options
* Enable support for virus scanning with ClamAV
* Added deploy status to the footer
* Removed all language translations expect for Mandarin and Spanish
* Added ability for users to export metadata for all works in a collection
* Ported over Scholar features
    * Show same fields as Scholar on user profile page
    * Show welcome page and send welcome email to new users
    * Added /sitemap.xml
    * Generated Scholar work types
    * Added all Scholar help and about pages
    * Boosted collections to top of search results
    * Allowed works to be created without files attached
    * The creator field is now set to the current users when creating works
    * Integrated ORCID support into user profiles

0.3.0 3/27/2018
* Updated to Hyrax gem reference 01d8ad5ecdf5b5658e6800d23d570c5d7b2c9cdc
* Added an RSS feed of recently added works (/feed.rss)
* The /users page now hides admins and users without content (Admin users can still see all users)
* Removed several deprecations
* Removed the option for users to set a lease on works
* Renamed app/service to app/services
* Added task to seed test users and works (rails db:seed)
* Copied new and modified feature specs from Hyrax
* Added the ability for users to change their account password
* Removed the ability for Shibboleth users to change their password

0.2.0 3/2/2018
* Updated to Hyrax gem version 2.1.0.beta1
* Created services to export a collection's work metadata to a CSV file
* Added first and last name fields to user profiles
* Users that have added their name into their profiles will have their name displayed in the application instead of email address
* Allow users to log in via UC's Central Login service (Shibboleth)
* Users are now required to complete a CAPTCHA on the contact form if they are not logged in
* Uploaded files are limited to a maximum size of 3 GB (per file)
* Users can now upload files from cloud providers

0.1.0 2/18/2018
* Turned on the IIIF image viewer
* Set the ruby verion and gemset
* Configured Travis CI
* Configured Coveralls
* Configured Rubocop
* Configured Sidekiq
* Configured an 'admin' role
* Copied feature specs from Hyrax
* Added README
