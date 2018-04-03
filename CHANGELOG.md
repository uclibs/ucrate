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
