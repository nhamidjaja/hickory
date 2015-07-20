[![Dependency Status](https://gemnasium.com/86405ecb00aa118efc5c6504680ffd54.svg)](https://gemnasium.com/527867820b8060dce1015e8c946eb481)

# Hickory

## Rails


Rails is a web-application framework that includes everything needed to create database-backed web applications according to the Model-View-Control pattern.

Follow the guidelines to start developing your application. You can find
the following resources handy:

* The Getting Started Guide: <http://guides.rubyonrails.org/getting_started.html> <-- **New at rails? At least read this doc**
* Railscasts: <http://railscasts.com>
* Ruby on Rails Tutorial Book: <http://www.railstutorial.org>
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
$ cp config/database.example.yml config/database.yml
$ cp config/cequel.example.yml config/cequel.yml  // ORM for Cassandra
```
And adjust the config if needed.

#### PostgreSQL

Install and run **mysql**, with brew:

```
$ brew install postgres
```
Follow the instructions to start postgres.

#### Redis

Install and run **redis**, with brew:

```
$ brew install redis
```
Follow the instructions to start postgres.

#### Cassandra

Install and run **cassandra** with brew by following this guide <http://christopher-batey.blogspot.com/2013/05/installing-cassandra-on-mac-os-x.html>

#### Run test suite
To verify that everything works run the test suite:

```
$ rake db:create
$ rake db:migrate
$ rake db:test:prepare   // sync test database with development database
$ rake cequel:keyspace:create
$ rake cequel:keyspace:create RAILS_ENV=test
$ rake cequel:migrate
$ rake cequel:migrate RAILS_ENV=test
$ rspec

Finished in 0.70621 seconds (files took 2.23 seconds to load)
47 examples, 0 failures, 9 pending
```
Verify that you have **0 failures**.

#### Run rails server

Then you're finally ready to see the working app :)

```
$ rails s
```


#### Ready to go!
Open it on <http://localhost:3000>

## Contributing

#### Branching
First, create a feature/release/hotfix branch as according to git flow. For this example, we will be creating a feature branch *user-authentication*:

```
$ git flow feature start user-authentication
```

#### Completing
##### Rubocop
Use rubocop <https://github.com/bbatsov/rubocop> to analyze your code for proper style:

``` 
$ rubocop
Inspecting 67 files
...................................................................

67 files inspected, no offenses detected
```
Verify that you have **no offenses detected**. Otherwise make the suggested corrections.

##### Rspec
Run the test suite again to make sure that you are not submitting breaking changes.

```
$ rake db:test:prepare
$ rake cequel:migrate RAILS_ENV=test
$ rspec

Finished in 0.70621 seconds (files took 2.23 seconds to load)
47 examples, 0 failures, 9 pending
```
Again, verify that you have **0 failures**.


#### Submitting
Once you have completed, create a **merge request** through the git repository dashboard.

***

## Updating dependencies
[![Dependency Status](https://gemnasium.com/86405ecb00aa118efc5c6504680ffd54.svg)](https://gemnasium.com/527867820b8060dce1015e8c946eb481)

### If dependencies are out-of-date:

Update all gems with bundler:

```
$ bundle update
```

Verify that it hasn't caused breaking changes:

```
$ rspec
```

### If *rails* is out-of-date:

Go to <http://railsdiff.com> to track the required changes.
Modify source code with the changes, for example if upgrading to Rails 4.2.3:

```
# Gemfile

gem 'rails', '4.2.3'
```

Use bundler to update rails:

```
$ bundle update rails
```

Verify that it hasn't caused breaking changes:

```
$ rspec
```
