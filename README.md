# Hickory

## Rails


Rails is a web-application framework that includes everything needed to create database-backed web applications according to the Model-View-Control pattern.

Follow the guidelines to start developing your application. You can find
the following resources handy:

* The Getting Started Guide: <http://guides.rubyonrails.org/getting_started.html> <-- **New at rails? At least read this doc**
* Ruby on Rails Tutorial Book: <http://www.railstutorial.org/>
* Debugging rails: <http://guides.rubyonrails.org/debugging_rails_applications.html>


## Installing Rails



For Mac OS X I recommend you to use [Homebrew](http://mxcl.github.io/homebrew/) for package manager.

And use [Ruby Version Manager](https://rvm.io/), and here's the [link](http://www.stewgleadow.com/blog/2011/12/10/installing-rvm-on-os-x-lion/) to install it on Mac.


Make sure you have the latest update from 'brew'

```
$ brew update
$ git clone git@gitlab.com:nhamidjaja/hickory.git
$ cd hickory // the PROJECT DIRECTORY
$ git checkout develop // cause we use git flow
```

*More about [git flow](http://nvie.com/posts/a-successful-git-branching-model/)*


Now that the gemset is set, run this

```
$ echo gem: --no-ri --no-rdoc > ~/.gemrc  // this option is to skip gem docs
$ bundle install  // this will install the gems
```

Next, copy config/create database.yml and other configurations. Don't worry we have a template

```
$ cp config/database.template.yml config/database.yml
$ cp config/cequel.template.yml config/cequel.yml  // ORM for Cassandra
```
And adjust the config if needed.

#### MySQL

Install and run **mysql**, with brew:

```
$ brew install mysql
$ mysql.server start
```
#### Cassandra

Install and run **cassandra** with brew by following this guide [http://christopher-batey.blogspot.com/2013/05/installing-cassandra-on-mac-os-x.html](http://christopher-batey.blogspot.com/2013/05/installing-cassandra-on-mac-os-x.html)


#### Run rails server

Then you're finally ready to see the working app :)

```
$ rake db:setup
$ rake db:migrate
$ rails s
```


#### Ready to go!
Open it on <http://localhost:3000>


***


## Console

The console is a Ruby shell, which allows you to interact with your
application's domain model. Here you'll have all parts of the application
configured, just like it is when the application is running. You can inspect
domain models, change values, and save to the database. Starting the script
without arguments will launch it in the development environment.

To start the console, run <tt>rails console</tt> from the application
directory.

Options:

* Passing the <tt>-s, --sandbox</tt> argument will rollback any modifications
  made to the database.
* Passing an environment name as an argument will load the corresponding
  environment. Example: <tt>rails console production</tt>.

To reload your controllers and models after launching the console run
<tt>reload!</tt>

More information about irb can be found at:
link:http://www.rubycentral.org/pickaxe/irb.html


## dbconsole

You can go to the command line of your database directly through <tt>rails
dbconsole</tt>. You would be connected to the database with the credentials
defined in database.yml. Starting the script without arguments will connect you
to the development database. Passing an argument will connect you to a different
database, like <tt>rails dbconsole production</tt>. Currently works for MySQL,
PostgreSQL and SQLite 3.

##Description of Contents

The default directory structure of a generated Ruby on Rails application:

    |-- app
    |   |-- assets
    |   |   |-- images
    |   |   |-- javascripts
    |   |   `-- stylesheets
    |   |-- controllers
    |   |-- helpers
    |   |-- mailers
    |   |-- models
    |   `-- views
    |       `-- layouts
    |-- config
    |   |-- environments
    |   |-- initializers
    |   `-- locales
    |-- db
    |-- doc
    |-- lib
    |   |-- assets
    |   `-- tasks
    |-- log
    |-- public
    |-- script
    |-- test
    |   |-- fixtures
    |   |-- functional
    |   |-- integration
    |   |-- performance
    |   `-- unit
    |-- tmp
    |   `-- cache
    |       `-- assets
    `-- vendor
        |-- assets
        |   |-- javascripts
        |   `-- stylesheets
        `-- plugins

app
:  Holds all the code that's specific to this particular application.

app/assets
:  Contains subdirectories for images, stylesheets, and JavaScript files.

app/controllers
:  Holds controllers that should be named like weblogs_controller.rb for
  automated URL mapping. All controllers should descend from
  ApplicationController which itself descends from ActionController::Base.

app/models
:  Holds models that should be named like post.rb. Models descend from
  ActiveRecord::Base by default.

app/views
:  Holds the template files for the view that should be named like
  weblogs/index.html.erb for the WeblogsController#index action. All views use
  eRuby syntax by default.

app/views/layouts
:  Holds the template files for layouts to be used with views. This models the
  common header/footer method of wrapping views. In your views, define a layout
  using the <tt>layout :default</tt> and create a file named default.html.erb.
  Inside default.html.erb, call <% yield %> to render the view using this
  layout.

app/helpers
:  Holds view helpers that should be named like weblogs_helper.rb. These are
  generated for you automatically when using generators for controllers.
  Helpers can be used to wrap functionality for your views into methods.

config
:  Configuration files for the Rails environment, the routing map, the database,
  and other dependencies.

db
:  Contains the database schema in schema.rb. db/migrate contains all the
  sequence of Migrations for your schema.

doc
:  This directory is where your application documentation will be stored when
  generated using <tt>rake doc:app</tt>

lib
:  Application specific libraries. Basically, any kind of custom code that
  doesn't belong under controllers, models, or helpers. This directory is in
  the load path.

public
:  The directory available for the web server. Also contains the dispatchers and the
  default HTML files. This should be set as the DOCUMENT_ROOT of your web
  server.

script
:  Helper scripts for automation and generation.

test
:  Unit and functional tests along with fixtures. When using the rails generate
  command, template test files will be generated for you and placed in this
  directory.

vendor
:  External libraries that the application depends on. Also includes the plugins
  subdirectory. If the app has frozen rails, those gems also go here, under
  vendor/rails/. This directory is in the load path.

