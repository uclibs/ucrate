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
