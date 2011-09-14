# Guard::Jasmine [![Build Status](https://secure.travis-ci.org/netzpirat/guard-jasmine.png)](http://travis-ci.org/netzpirat/guard-jasmine)

Guard::Jasmine automatically tests your Jasmine specs when files are modified.

Tested on MRI Ruby 1.8.7, 1.9.2, REE and the latest versions of JRuby & Rubinius.

If you have any questions please join us on our [Google group](http://groups.google.com/group/guard-dev) or on `#guard`
(irc.freenode.net).

## Highlights

* Continuous testing based on file modifications by [Guard][], manifold configurable rules
with RegEx and Ruby.

* Fast headless testing on [PhantomJS][], a full featured WebKit browser with native support for
various web standards: DOM handling, CSS selector, JSON, Canvas, and SVG.

* You can write your [Jasmine][] specs in [CoffeeScript][], fully integrated into the
[Rails 3.1 asset pipeline][] with [Jasminerice][].

* Runs on Mac OS X, Linux and Windows.

## How it works

![Guard Jasmine](https://github.com/netzpirat/guard-jasmine/raw/master/resources/guard-jasmine.png)

1. Guard is triggered by a file modification.
2. Guard::Jasmine executes the [PhantomJS script][].
3. The PhantomJS script requests the Jasmine test runner via HTTP.
4. Rails uses the asset pipeline to get the Jasmine runner, the code to be tested and the specs.
5. The asset pipeline prepares the assets, compiles the CoffeeScripts if necessary.
6. The asset pipeline has finished to prepare the needed assets.
7. Rails returns the Jasmine runner HTML.
8. PhantomJS requests linked assets and runs the Jasmine tests headless.
9. The PhantomJS script extracts the result from the DOM and returns a JSON report.
10. Guard::Jasmine reports the results to the console and system notifications.

## Install

### Guard and Guard::Jasmine

Please be sure to have [Guard][] installed.

Install the gem:

    $ gem install guard-jasmine

Add it to your `Gemfile`, preferably inside the development group:

    gem 'guard-jasmine'

Add guard definition to your `Guardfile` by running this command:

    $ guard init jasmine

### Jasminerice

With Rails 3.1 you can write your Jasmine specs in addition to JavaScript with CoffeeScript, fully integrated into the
Rails 3.1 asset pipeline with Jasminerice.

Please read the detailed installation and configuration instructions at [Jasminerice][].

In short, you add it to your `Gemfile`:

    group :development, :test do
      gem 'jasminerice'
    end

and add a route for the Jasmine Test Runner to `config/routes.rb`:

    if ["development", "test"].include? Rails.env
      mount Jasminerice::Engine => "/jasmine"
    end

Next you create the directory `spec/javascripts` where your CoffeeScript tests go into. You define the Rails 3.1
asset pipeline manifest in `spec/javascripts/spec.js.coffee`:

    #=require_tree ./

### PhantomJS

You need the PhantomJS browser installed on your system. You can download binaries for Mac OS X and Windows from
[the PhantomJS download section][].

Alternatively you can install [Homebrew][] on Mac OS X and install it with:

    $ brew install phantomjs

If you are using Ubuntu 10.10, you can install it with apt:

    $ sudo add-apt-repository ppa:jerome-etienne/neoip
    $ sudo apt-get update
    $ sudo apt-get install phantomjs

You can also build it from source for several other operating systems, please consult the
[PhantomJS build instructions][].

## Usage

Please read the [Guard usage documentation](https://github.com/guard/guard#readme).

## Guardfile

Guard::Jasmine can be adapted to all kind of projects. Please read the
[Guard documentation](https://github.com/guard/guard#readme) for more information about the Guardfile DSL.

    guard 'jasmine' do
      watch(%r{app/assets/javascripts/(.+)\.(js\.coffee|js)}) { |m| "spec/javascripts/#{m[1]}_spec.#{m[2]}" }
      watch(%r{spec/javascripts/(.+)_spec\.(js\.coffee|js)})  { |m| "spec/javascripts/#{m[1]}_spec.#{m[2]}" }
      watch(%r{spec/javascripts/spec\.(js\.coffee|js)})       { "spec/javascripts" }
    end

## Options

There are many options that can customize Guard::Jasmine to your needs. Options are simply supplied as hash when
defining the Guard in your `Guardfile`:

    guard 'jasmine', :all_on_start => false, :specdoc => :always do
      ...
    end

### General options

The general options configures the environment that is needed to run Guard::Jasmine:

    :jasmine_url => 'http://192.168.1.5/jasmine'  # URL where Jasmine is served.
                                                  # default: http://127.0.0.1/jasmine

    :phantomjs_bin => '~/bin/phantomjs'           # Path to phantomjs.
                                                  # default: '/usr/local/bin/phantomjs'

### Spec runner options

The spec runner options configures the behavior driven development (or BDD) cycle:

    :all_on_start => false                        # Run all suites on start.
                                                  # default: true

    :keep_failed => false                         # Keep failed suites and add them to the next run again.
                                                  # default: true

    :all_after_pass => false                      # Run all suites after a suite has passed again after failing.
                                                  # default: true

The `:keep_failed` failed option remembers failed suites and not failed specs. The reason for this decision is to
avoid additional round trip time to request the Jasmine test runner for each single spec, which is mostly more expensive
than running a whole suite.

### Specdoc options

Guard::Jasmine can generate an RSpec like specdoc in the console after running the specs and you can set when it will
be shown in the console:

    :specdoc => :always                           # Specdoc output options, either :always, :never or :failure
                                                  # default: :failure

With the option set to :always, the specdoc is shown with and without errors in your spec, whereas on with the option
set to :never, there is no output at all, instead just a summary of the spec run is shown. The default option :failure
shows the specdoc when at least one spec failed.

### System notifications options

These options affects what system notifications (growl, libnotify or notifu) are shown after a spec run:

    :notifications => false                       # Show success and error notifications.
                                                  # default: true

    :hide_success => true                         # Disable successful spec run notification.
                                                  # default: false

    :max_error_notify => 5                        # Maximum error notifications to show.
                                                  # default: 3

## A note on Rails 2 and 3

This readme describes the use of Guard::Jasmine with Jasminerice through the asset pipeline, but it is not really
a requirement for Guard::Jasmine. As long as you serve the Jasmine test runner under a certain url,
it's freely up to you how you'll prepare the assets and serve the Jasmine runner.

You can use [the Jasmine Gem][], configure the test suite in `jasmine.yml` and start the Jasmine test runner with
the supplied Rake task:

    $ rake jasmine

Next follows an example on how to configure your `Guardfile` with the Jasmine gem:

    guard 'jasmine', :url => 'http://127.0.0.1:8888' do
      watch(%r{public/javascripts/(.+)\.js})                  { |m| "spec/javascripts/#{m[1]}_spec.js" }
      watch(%r{spec/javascripts/(.+)_spec\.js})               { |m| "spec/javascripts/#{m[1]}_spec.js" }
      watch(%r{spec/javascripts/support/jasmine\.yml})        { "spec/javascripts" }
      watch(%r{spec/javascripts/support/jasmine_config\.rb})  { "spec/javascripts" }
    end

It is also possible to use CoffeeScript in this setup, by using [Guard::CoffeeScript][] to compile your code and even
specs. Just add something like this *before* Guard::Jasmine:

    guard 'coffeescript', :input => 'app/coffeescripts',  :output => 'public/javascripts'
    guard 'coffeescript', :input => 'spec/coffeescripts', :output => 'spec/javascripts'

## Alternatives

* [guard-jasmine-headless-webkit][], a Guard for [jasmine-headless-webkit][], but doesn't run on JRuby.
* [Evergreen][], runs CoffeeScript specs headless, but has no
continuous testing support.
* [Jezebel][] a Node.js REPL and continuous test runner for [Jessie][], a Node runner for Jasmine, but has no full
featured browser environment.

## Development

- Documentation hosted at [RubyDoc](http://rubydoc.info/github/guard/guard-jasmine/master/frames).
- Source hosted at [GitHub](https://github.com/netzpirat/guard-jasmine).
- Report issues and feature requests to [GitHub Issues](https://github.com/netzpirat/guard-jasmine/issues).

Pull requests are very welcome! Please try to follow these simple "rules", though:

- Please create a topic branch for every separate change you make.
- Make sure your patches are well tested.
- Update the README (if applicable).
- Please **do not change** the version number.

### The guard-jasmine executable

This Guard comes with a small executable `guard-jasmine` that can be used to run the Jasmine test runner on PhantomJS
and see the JSON result that gets evaluated by Guard::Jasmine. This comes handy when there is an issue with your specs
and you want to see the output of the PhantomJS script.

    $ guard-jasmine

The only argument that the script takes is the URL to the Jasmine runner, which defaults to
`http://127.0.0.1:3000/Jasmine`. So you can for example just run a subset of the specs by changing the URL:

    $ guard-jasmine http://127.0.0.1:3000/Jasmine?spec=YourSpec

### Questions

For questions please join us on our [Google group](http://groups.google.com/group/guard-dev) or on `#guard`
(irc.freenode.net).

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
