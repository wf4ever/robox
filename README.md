# ROBox - Connecting Research Objects in your Dropbox

This is being developed as part of the Prototype 1 work in the [Wf4Ever](http://www.wf4ever-project.org/) project.

It allows users to register their Dropbox accounts and have their folders of Research Objects sychronise with a Research Object repository.

## How it Works

See [the wiki page for Dropbox RO Connector (ROBox)](http://www.wf4ever-project.org/wiki/display/docs/Dropbox+RO+Connector+%28ROBox%29)

Check out the *doc* directory for some diagrams

## Installation (for Production use)

### Dependencies

* Ruby 1.9.2 and development headers (ruby-dev)
* MySQL 5 and development headers (mysql-dev)
* Git 1.7\+


### Set up (*not finished*)

* `gem install bundler`
* `git clone git://github.com/wf4ever/prototype1-dropbox.git`
* `bundle --deployment`
* Set up config/database.yml
* Set up config/settings/custom.yml
* `rake db:setup && rake db:migrate && rake db:seed`
* `jammit`
* `gem install passenger`
* Set up passenger in Apache
* Set up application in Apache
* ... more to come

## Running

### Test the web server

    rails server RAILS_ENV=production

Then open http://localhost:3000 in your browser

### How to run the background sync jobs

First, run the background job worker:

    ruby script/delayed_job start

This will run in the background until you stop it using:

    ruby script/delayed_job stop

To then submit a fresh batch of sync jobs:

    rake robox:sync_jobs

## Development

Follow the installation instructions above, except:
* Do `git clone git@github.com:wf4ever/prototype1-dropbox.git` instead.
* Run `bundle install` instead of `bundle --deployment`.
* Don't do the Passenger and Apache set up.

### To run the tests

    rake spec

### To have tests running continually in the background

    autotest

This will run the appropriate test(s) when file(s) are changed

### To run a local development server

    rails server

Then open http://localhost:3000 in your browser

### To completely delete your database and create a fresh new one

    rake db:drop && rake db:create && rake db:migrate && rake db:seed && rake db:test:prepare

### To re-annotate Models with database schema info

    annotate --position=before --show-migration --show-indexes

### To re-annotate the Routes file with a list of routes

    annotate --routes

### To generate the diagrams in the doc folder

    rake diagram:all

MUST have **dot**, **neato** and **sed** available on the command line

### Useful development links

* [**Rails** docs](http://railsapi.com/)
* [**RubyDocs** (Ruby docs + docs for all Ruby gems)](http://rubydoc.info)
* [**Devise** docs](https://github.com/plataformatec/devise/wiki)
* [**CanCan** docs](https://github.com/ryanb/cancan/wiki)
* [**Haml** And **Sass** In 15 Minutes](http://www.slideshare.net/mokolabs/haml-and-sass-in-15-minutes)
* [**Haml** tutorial](http://haml-lang.com/tutorial.html)
* [**Haml** reference](http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html)
* [**Sass** tutorial](http://sass-lang.com/tutorial.html)
* [**Sass** reference](http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html)