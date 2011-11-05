# Guard::Jasmine [![Build Status](https://secure.travis-ci.org/netzpirat/guard-jasmine.png)](http://travis-ci.org/netzpirat/guard-jasmine)

Guard::Jasmine automatically tests your Jasmine specs on Rails when files are modified.

Tested on MRI Ruby 1.8.7, 1.9.2, 1.9.3, REE and the latest versions of JRuby & Rubinius.

If you have any questions please join us on our [Google group](http://groups.google.com/group/guard-dev) or on `#guard`
(irc.freenode.net).

## Highlights

* Continuous testing based on file modifications by [Guard][], manifold configuration by writing rules with RegExp and
Ruby.

* Fast headless testing on [PhantomJS][], a full featured WebKit browser with native support for
various web standards: DOM handling, CSS selector, JSON, Canvas, and SVG.

* Runs the standard Jasmine test runner, so you can use [Jasminerice][] for integrating [Jasmine][] into the
[Rails 3.1 asset pipeline][] and write your specs in [CoffeeScript][].

* Command line helper for CI server integration.

* Runs on Mac OS X, Linux and Windows.

## Install

### Guard and Guard::Jasmine

The simplest way to install Guard is to use [Bundler](http://gembundler.com/).
Please make sure to have [Guard][] installed.

Add Guard::Jasmine to your `Gemfile`:

```ruby
group :development, :test do
  gem 'guard-jasmine'
end
```

Add the default Guard::Jasmine template to your `Guardfile` by running:

```bash
$ guard init jasmine
```

### PhantomJS

You need the PhantomJS browser installed on your system. You can download binaries for Mac OS X and Windows from
[the PhantomJS download section][].

Alternatively you can install [Homebrew][] on Mac OS X and install it with:

```bash
$ brew install phantomjs
```

If you are using Ubuntu 10.10, you can install it with apt:

```bash
$ sudo add-apt-repository ppa:jerome-etienne/neoip
$ sudo apt-get update
$ sudo apt-get install phantomjs
```

You can also build it from source for several other operating systems, please consult the
[PhantomJS build instructions][].

## Rails 3.1 setup

With Rails 3.1 you can write your Jasmine specs in addition to JavaScript with CoffeeScript, fully integrated into the
Rails 3.1 asset pipeline with [Jasminerice][]. You have full access to your running Rails app, but it's a good practice
to fake the server response. Check out the excellent [Sinon.JS][] documentation to learn more about this topic.

Guard::Jasmine will start a Rails Rack server to run your specs.

### How it works

![Guard Jasmine](https://github.com/netzpirat/guard-jasmine/raw/master/resources/guard-jasmine-rails31.jpg)

1. Guard is triggered by a file modification.
2. Guard::Jasmine executes the [PhantomJS script][].
3. The PhantomJS script requests the Jasmine test runner via HTTP.
4. Rails uses the asset pipeline to get the Jasmine runner, the code to be tested and the specs.
5. The asset pipeline prepares the assets, compiles the CoffeeScripts if necessary.
6. The asset pipeline has finished to prepare the needed assets.
7. Rails returns the Jasmine runner HTML.
8. PhantomJS requests linked assets and runs the Jasmine tests headless.
9. The PhantomJS script collects the Jasmine runner results and returns a JSON report.
10. Guard::Jasmine reports the results to the console and system notifications.

### Jasminerice

Please read the detailed installation and configuration instructions at [Jasminerice][].

In short, you add it to your `Gemfile`:

```ruby
group :development, :test do
  gem 'jasminerice'
end
```

And run following from the Terminal:
```bash
mkdir -p spec/javascripts
echo -e "#=require application\n#=require_tree ./" > spec/javascripts/spec.js.coffee
echo -e "/*\n * add css using =require application\n */" > spec/javascripts/spec.css
```

This creates the directory `spec/javascripts` where your CoffeeScript tests go into. You define the Rails 3.1
asset pipeline manifest in `spec/javascripts/spec.js.coffee`:

```coffeescript
#=require application
#=require_tree ./
```

It also creates an empty `spec/javascripts/spec.css` file as it is always requested when running specs.

Now you can access `/jasmine` url when you start rails server normally.

## Rails 2 & Rails 3 setup

With Rails 2 or Rails 3 you can use [the Jasmine Gem][] to configure your Jasmine specs and server the Jasmine
runner. You don't have full access to your running Rails app, but it's anyway a good practice to fake the server
response. Check out the excellent [Sinon.JS][] documentation to learn more about this topic.

Guard::Jasmine will start a Jasmine Gem Rack server to run your specs.

### How it works

![Guard Jasmine](https://github.com/netzpirat/guard-jasmine/raw/master/resources/guard-jasmine-rails23.jpg)

1. Guard is triggered by a file modification.
2. Guard::Jasmine executes the [PhantomJS script][].
3. The PhantomJS script requests the Jasmine test runner via HTTP.
4. The Jasmine Gem reads your configuration and get the assets.
5. The Jasmine Gem serves the the code to be tested and the specs.
6. PhantomJS runs the Jasmine tests headless.
7. The PhantomJS script collects the Jasmine runner results and returns a JSON report.
8. Guard::Jasmine reports the results to the console and system notifications.

### Jasmine Gem

Please read the detailed installation and configuration instructions at [the Jasmine Gem][].

In short, you add it to your `Gemfile`:

```ruby
group :development, :test do
  gem 'jasmine'
end
```

and generate the configuration files:

#### for Rails 3

```bash
$ rails g jasmine:install
```

#### for Rails 2

```bash
$ script/generate jasmine
```

Now you can configure your spec suite in the Jasmine configuration file `specs/javascripts/support/jasmine.yml`.

#### Writing CoffeeScript specs

It is also possible to use CoffeeScript in this setup, by using [Guard::CoffeeScript][] to compile your code and even
specs. Just add something like this *before* Guard::Jasmine:

```ruby
guard 'coffeescript', :input => 'app/coffeescripts',  :output => 'public/javascripts'
guard 'coffeescript', :input => 'spec/coffeescripts', :output => 'spec/javascripts'
```

## Usage

Please read the [Guard usage documentation](https://github.com/guard/guard#readme).

## Guardfile

Guard::Jasmine can be adapted to all kind of projects. Please read the
[Guard documentation](https://github.com/guard/guard#readme) for more information about the Guardfile DSL.

```ruby
guard 'jasmine' do
  watch(%r{app/assets/javascripts/(.+)\.(js\.coffee|js)}) { |m| "spec/javascripts/#{m[1]}_spec.#{m[2]}" }
  watch(%r{spec/javascripts/(.+)_spec\.(js\.coffee|js)})  { |m| "spec/javascripts/#{m[1]}_spec.#{m[2]}" }
  watch(%r{spec/javascripts/spec\.(js\.coffee|js)})       { "spec/javascripts" }
end
```

## Options

There are many options that can customize Guard::Jasmine to your needs. Options are simply supplied as hash when
defining the Guard in your `Guardfile`:

```ruby
guard 'jasmine', :all_on_start => false, :specdoc => :always do
  ...
end
```

### General options

The general options configures the environment that is needed to run Guard::Jasmine:

```ruby
:server => :jasmine_gem                       # Jasmine server to use, either :auto, :rack, :jasmine_gem or :none
                                              # default: :auto

:port => 9292                                 # Jasmine server port to use.
                                              # default: 8888

:phantomjs_bin => '~/bin/phantomjs'           # Path to phantomjs.
                                              # default: auto-detect 'phantomjs'

:timeout => 20000                             # The time in ms to wait for the spec runner to finish.
                                              # default: 10000
```

If you're setting the `:server` option to `:none`, you can supply the Jasmine runner url manually:

```ruby
:jasmine_url => 'http://192.168.1.5/jasmine'  # URL where Jasmine is served.
                                              # default: http://127.0.0.1:8888/jasmine
```

### Spec runner options

The spec runner options configures the behavior driven development (or BDD) cycle:

```ruby
:all_on_start => false                        # Run all suites on start.
                                              # default: true

:keep_failed => false                         # Keep failed suites and add them to the next run again.
                                              # default: true

:all_after_pass => false                      # Run all suites after a suite has passed again after failing.
                                              # default: true
```

The `:keep_failed` failed option remembers failed suites and not failed specs. The reason for this decision is to
avoid additional round trip time to request the Jasmine test runner for each single spec, which is mostly more expensive
than running a whole suite.

### Specdoc options

Guard::Jasmine can generate an RSpec like specdoc in the console after running the specs and you can set when it will
be shown in the console:

```ruby
:specdoc => :always                           # Specdoc output options, either :always, :never or :failure
                                              # default: :failure

:focus => false                               # Specdoc focus to hide successful specs when at least one spec fails.
                                              # default: true

:console => :always                           # Console.log output options, either :always, :never or :failure
                                              # default: :failure
```

With the option set to `:always`, the specdoc is shown with and without errors in your spec, whereas on with the option
set to `:never`, there is no output at all, instead just a summary of the spec run is shown. The default option
`:failure` shows the specdoc when at least one spec failed.

When `:focus` is enabled, only the failing specs are shown in the specdoc when at least one spec is failing.

The `:console` options adds captured console logs from the spec runner and adds them to the specdoc. Please note
that PhantomJS only support capturing of `console.log`, so the other log functions like `debug`, `warn`, `info` and
`error` are missing. Please vote on [Issue 232](http://code.google.com/p/phantomjs/issues/detail?id=232) if you like
to see support for more console methods coming to PhantomJS.

Another restriction on console logging is that currently only the first log parameter is passed. So instead of writing

```javascript
console.log('Debug of %o with %s', object, string)
```

your should write

```javascript
console.log('Debug of ' + object.toString() + ' width ' + string)
```

You can also give your vote on [Issue 36](http://code.google.com/p/phantomjs/issues/detail?id=36) to see support for
multiple console arguments.

### System notifications options

These options affects what system notifications (growl, libnotify or notifu) are shown after a spec run:

```ruby
:notifications => false                       # Show success and error notifications.
                                              # default: true

:hide_success => true                         # Disable successful spec run notification.
                                              # default: false

:max_error_notify => 5                        # Maximum error notifications to show.
                                              # default: 3
```

## Guard::Jasmine for your CI server

Guard::Jasmine includes a little command line utility to run your specs once and output the specdoc to the console.

```bash
$ guard-jasmine
```

You can get help on the available options with the `help` task:

```bash
Usage:
  guard-jasmine spec

Options:
  -s, [--server=SERVER]    # Server to start, either `auto`, `rack`, `jasmine_gem` or `none`
                           # Default: auto
  -p, [--port=N]           # Server port to use
                           # Default: 8888
  -u, [--url=URL]          # The url of the Jasmine test runner
                           # Default: http://127.0.0.1:8888/jasmine
  -b, [--bin=BIN]          # The location of the PhantomJS binary
                           # Default: /usr/local/bin/phantomjs
  -t, [--timeout=N]        # The maximum time in milliseconds to wait for the spec runner to finish
                           # Default: 10000
  -c, [--console=CONSOLE]  # Whether to show console.log statements in the spec runner, either `always`, `never` or `failure`
                           # Default: failure

Run the Jasmine spec runner
```

By default all specs are run, but you can supply multiple paths to your specs to run only a subset:

```bash
$ guard-jasmine spec/javascripts/a_spec.js.coffee spec/javascripts/another_spec.js.coffee
```

### Travis CI integration

With the given `guard-jasmine` script you're able to configure [Travis CI](http://travis-ci.org/) to run Guard::Jasmine.
Simply use the `script` setting in your `.travis.yml`:

```yaml
script: 'bundle exec guard-jasmine'
```

You can also run your Guard::Jasmine specs after your specs that are ran with `rake` by using `after_script`:

```yaml
after_script: 'bundle exec guard-jasmine'
```

## Alternatives

There are many ways to get your Jasmine specs run within a headless environment. If Guard::Jasmine isn't for you,
I recommend to check out these other brilliant Jasmine runners:

### Guards

* [guard-jasmine-headless-webkit][], a Guard for [jasmine-headless-webkit][], but doesn't run on JRuby.
* [guard-jasmine-node][] automatically & intelligently executes Jasmine Node.js specs when files are modified.
* [guard-jessie][] allows to automatically run you Jasmine specs under Node.js using Jessie runner.

### Standalone

* [Evergreen][], runs CoffeeScript specs headless, but has no continuous testing support.
* [Jezebel][] a Node.js REPL and continuous test runner for [Jessie][], a Node runner for Jasmine, but has no full
featured browser environment.

## Issues

You can report issues and feature requests to [GitHub Issues](https://github.com/netzpirat/guard-jasmine/issues). Try to figure out
where the issue belongs to: Is it an issue with Guard itself or with Guard::Jasmine? Please don't
ask question in the issue tracker, instead join us in our [Google group](http://groups.google.com/group/guard-dev) or on
`#guard` (irc.freenode.net).

When you file an issue, please try to follow to these simple rules if applicable:

* Make sure you run Guard with `bundle exec` first.
* Add debug information to the issue by running Guard with the `--debug` option.
* Add your `Guardfile` and `Gemfile` to the issue.
* Make sure that the issue is reproducible with your description.

## Development

- Documentation hosted at [RubyDoc](http://rubydoc.info/github/guard/guard-jasmine/master/frames).
- Source hosted at [GitHub](https://github.com/netzpirat/guard-jasmine).

Pull requests are very welcome! Please try to follow these simple rules if applicable:

* Please create a topic branch for every separate change you make.
* Make sure your patches are well tested.
* Update the [Yard](http://yardoc.org/) documentation.
* Update the README.
* Update the CHANGELOG for noteworthy changes.
* Please **do not change** the version number.

For questions please join us in our [Google group](http://groups.google.com/group/guard-dev) or on
`#guard` (irc.freenode.net).

### The guard-jasmine-debug executable

This Guard comes with a small executable `guard-jasmine-debug` that can be used to run the Jasmine test runner on PhantomJS
and see the JSON result that gets evaluated by Guard::Jasmine. This comes handy when there is an issue with your specs
and you want to see the output of the PhantomJS script.

```bash
$ guard-jasmine-debug
```

The only argument that the script takes is the URL to the Jasmine runner, which defaults to
`http://127.0.0.1:3000/Jasmine`. So you can for example just run a subset of the specs by changing the URL:

```bash
$ guard-jasmine-debug http://127.0.0.1:3000/Jasmine?spec=YourSpec
```
## Contributors

* [Dmytrii Nagirniak](https://github.com/dnagir)

## Acknowledgment

- [Ariya Hidayat][] for [PhantomJS][], a powerful headless WebKit browser.
- [Brad Phelan][] for [Jasminerice][], an elegant solution for [Jasmine][] in the Rails 3.1 asset pipeline.
- [Pivotal Labs][] for their beautiful [Jasmine][] BDD testing framework that makes JavaScript testing fun.
- [Jeremy Ashkenas][] for [CoffeeScript][], that little language that compiles into JavaScript and makes me enjoy the
front-end.
- The [Guard Team][] for giving us such a nice piece of software that is so easy to extend, one *has* to make a plugin
for it!
- All the authors of the numerous [Guards][] available for making the Guard ecosystem so much growing and comprehensive.

## License

(The MIT License)

Copyright (c) 2011 Michael Kessler

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[Guard]: https://github.com/guard/guard
[Guards]: https://github.com/guard
[Guard Team]: https://github.com/guard/guard/contributors
[Ariya Hidayat]: http://twitter.com/#!/AriyaHidayat
[PhantomJS]: http://www.phantomjs.org/
[the PhantomJS download section]: http://code.google.com/p/phantomjs/downloads/list
[PhantomJS build instructions]: http://code.google.com/p/phantomjs/wiki/BuildInstructions
[Brad Phelan]: http://twitter.com/#!/bradgonesurfing
[Jasminerice]: https://github.com/bradphelan/jasminerice
[Pivotal Labs]: http://pivotallabs.com/
[Jasmine]: http://pivotal.github.com/jasmine/
[the Jasmine Gem]: https://github.com/pivotal/jasmine-gem
[Jeremy Ashkenas]: http://twitter.com/#!/jashkenas
[CoffeeScript]: http://jashkenas.github.com/coffee-script/
[Rails 3.1 asset pipeline]: http://guides.rubyonrails.org/asset_pipeline.html
[Homebrew]: http://mxcl.github.com/homebrew/
[Jezebel]: https://github.com/benrady/jezebel
[Jessie]: https://github.com/futuresimple/jessie
[guard-jasmine-headless-webkit]: https://github.com/johnbintz/guard-jasmine-headless-webkit
[jasmine-headless-webkit]: https://github.com/johnbintz/jasmine-headless-webkit/
[Evergreen]: https://github.com/jnicklas/evergreen
[PhantomJS script]: https://github.com/netzpirat/guard-jasmine/blob/master/lib/guard/jasmine/phantomjs/run-jasmine.coffee
[Guard::CoffeeScript]: https://github.com/guard/guard-coffeescript
[Sinon.JS]: http://sinonjs.org
[guard-jasmine-node]: https://github.com/guard/guard-jasmine-node
[guard-jessie]: https://github.com/guard/guard-jessie
