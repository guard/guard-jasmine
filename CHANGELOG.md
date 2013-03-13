# Changelog

## Master

- [#118](https://github.com/netzpirat/guard-jasmine/pull/118): Fix Rake task execution on Windows. ([@twill88][])
- [#117](https://github.com/netzpirat/guard-jasmine/issues/117): Fix load path issues on Windows. ([@twill88][])

## 1.13.1 - March 12, 2013

- [#116](https://github.com/netzpirat/guard-jasmine/pull/116): Actually respect the server timeout option. ([@eventualbuddha][])

## 1.13.0 - February 19, 2013

- [#112](https://github.com/netzpirat/guard-jasmine/pull/112): Faster Jasmine runner exception detection.
- [#112](https://github.com/netzpirat/guard-jasmine/pull/112): Do not output a failing runner html on startup.
- [#111](https://github.com/netzpirat/guard-jasmine/pull/108): Configured Guardfile to watch for changes in fixtures directory. ([@andyw8][])

## 1.12.2 - February 4, 2013

- [#108](https://github.com/netzpirat/guard-jasmine/pull/108): Minor cleanups to coverage info. ([@ronen][])
- [#109](https://github.com/netzpirat/guard-jasmine/pull/109): Add `--coverage-html` and `--coverage-summary` support to cli. ([@ronen][])
- [#110](https://github.com/netzpirat/guard-jasmine/pull/110): Fix coverage hang for large files. ([@ronen][])

## 1.12.1 - January 28, 2013

- Increase default server and runner timeout.

## 1.12.0 - January 24, 2013

- [#102](https://github.com/netzpirat/guard-jasmine/pull/102): Jasmine gem server doesn't respond to `/jasmine` path.
- Switch coverage from [jscoverage](http://siliconforks.com/jscoverage/) to [Istanbul](https://github.com/gotwarlost/istanbul).
- [#77](https://github.com/netzpirat/guard-jasmine/pull/77): Add coverage support. ([@alexspeller][])

## 1.11.1 - January 11, 2013

- [#99](https://github.com/netzpirat/guard-jasmine/pull/99): Allowed passing custom rackup config via CLI. ([@arr-ee][])
- Output the runner response body on the CLI when the runner fails to start.

## 1.11.0 - December 17, 2012

- [#95](https://github.com/netzpirat/guard-jasmine/pull/95): Add Puma as a rack-compatible server. ([@mrship][])

## 1.10.1 - November 19, 2012

- [#90](https://github.com/netzpirat/guard-jasmine/issues/90): Fix wrong port in the default Jasmine url.

## 1.10.0 - November 19, 2012

- [#89](https://github.com/netzpirat/guard-jasmine/issues/89): Randomize server port if not specified.

## 1.9.4 - November 11, 2012

- [#88](https://github.com/netzpirat/guard-jasmine/issues/88): Guard::Jasmine leaves server running on timeout.
- The `:timeout` options takes now seconds and not milliseconds.

## 1.9.3 - October 30, 2012

- Fix starting the Unicorn test server.

## 1.9.2 - October 19, 2012

- [#85](https://github.com/netzpirat/guard-jasmine/issues/85): Improve server timeout handling.

## 1.9.1 - October 17, 2012

- Fix automatic server detection.
- [#84](https://github.com/netzpirat/guard-jasmine/issues/84): Fix server start from the CLI.

## 1.9.0 - October 17, 2012

- Add timeout to the initial server startup.
- [#83](https://github.com/netzpirat/guard-jasmine/pull/83): Make it possible to run within mountable engine within a dummy app (using jasminerice). ([@pschyska][])
- [#82](https://github.com/netzpirat/guard-jasmine/issues/82): Enable the `:auto` server to detection unicorn, thin and mongrel.

## 1.8.3 - September 19, 2012

- [#81](https://github.com/netzpirat/guard-jasmine/issues/81): Make the Guardfile template catch `.js.coffee` again.

## 1.8.2 - September 18, 2012

- [#78](https://github.com/netzpirat/guard-jasmine/issues/78): Use vanilla JS runner to make it run on Ubuntu 12.04 and PhantomJS 1.4.0.

## 1.8.1 - August 30, 2012

- [#76](https://github.com/netzpirat/guard-jasmine/issues/76): Remove nesting limitation on the JSON parser.

## 1.8.0 - August 29, 2012

- [#75](https://github.com/netzpirat/guard-jasmine/pull/75): Make sure the server process dies on error. ([@mutru][])
- Add Guard and cli option to define the number of seconds to wait for the Jasmine spec server to start.
- Remove cli short aliases `-c`, `-x` and `-f`, use the long form instead.

## 1.7.0 - August 10, 2012

- [#73](https://github.com/netzpirat/guard-jasmine/issues/73): Add `:run_all` option to overwrite normal options.

## 1.6.1 - August 3, 2012

- [#72](https://github.com/netzpirat/guard-jasmine/pull/72): Add specdoc option to CLI runner. ([@robotarmy][])

## 1.6.0 - August 2, 2012

- [#71](https://github.com/netzpirat/guard-jasmine/pull/71): Add focus option to CLI runner. ([@robotarmy][])

## 1.5.1 - Juli 19, 2012

- [#70](https://github.com/netzpirat/guard-jasmine/issues/70): Ensure the description is always a String.

## 1.5.0 - June 4, 2012

- [#68](https://github.com/netzpirat/guard-jasmine/pull/68) Use RAILS_ENV as server environment default if exists. ([@richo][])

## 1.4.0 - June 4, 2012

- [#65](https://github.com/netzpirat/guard-jasmine/pull/65): Support unicorn as server. ([@pushbang][] and [@clumsysnake][])

## 1.3.0 - June 2, 2012

- Upgrade for Guard 1.1.0

## 1.2.2 - Mai 29, 2012

- [#64](https://github.com/netzpirat/guard-jasmine/issues/64): Suite result specs may be undefined and makes the runner fail.

## 1.2.1 - Mai 25, 2012

- [#63](https://github.com/netzpirat/guard-jasmine/issues/63): The failures are not logged in the right order when there are nested describes.

## 1.2.0 - Mai 21, 2012

- [#62](https://github.com/netzpirat/guard-jasmine/pull/62): Show console log messages and errors independently from specdocs in Guard. ([@esposito][])

## 1.1.4 - Mai 18, 2012

- [#60](https://github.com/netzpirat/guard-jasmine/pull/60): Test if spec file exists. ([@huyhoang1970][])

## 1.1.3 - Mai 9, 2012

- [#57](https://github.com/netzpirat/guard-jasmine/issues/57): Fix error trace notification.

## 1.1.2 - Mai 1, 2012

- Add timeout to availability checker.
- The availablity checker prints it's url before starting.

## 1.1.1 - April 25, 2012

- Change CLI default port to 3001.
- Fix Rake task options.

## 1.1.0 - March 27, 2012

- PhantomJS 1.5 compatibility.
- Add onError handler for catching PhantomJS errors
- Filter logs and errors depending on the runner setting to speed up result parsing.
- Add errors to the spec doc.

## 1.0.4 - March 13, 2012

- Fix server start when not running in context of Guard.

## 1.0.3 - March 13, 2012

- [#45](https://github.com/netzpirat/guard-jasmine/issues/45): Cannot start Rack server.

## 1.0.2 - March 10, 2012

- [#44](https://github.com/netzpirat/guard-jasmine/pull/44): Allow a Guardfile to specify a custom rake task as the server. ([@eventualbuddha][])

## 1.0.1 - March 9, 2012

- Optimize PhantomJS runner result passing to improve speed.

## 1.0.0 - March 9, 2012

- Add a console.log implementation that supports formatting and pretty printing.
- [#43](https://github.com/netzpirat/guard-jasmine/issues/43): Fix Rake rask for Ruby 1.9.3p125

## 0.9.14 - March 8, 2012

- [#42](https://github.com/netzpirat/guard-jasmine/issues/42):  Add the possibility to start a custom Rake based server.
- [#42](https://github.com/netzpirat/guard-jasmine/issues/42):  Add option to configure the Jasmine spec directory.
- [#41](https://github.com/netzpirat/guard-jasmine/pull/41): Clean up Guardfile template. ([@DouweM][])

## 0.9.13 - February 29, 2012

- [#40](https://github.com/netzpirat/guard-jasmine/pull/40): Add clean option to skip the spec path cleaning. ([@andersjanmyr][])

## 0.9.12 - February 20, 2012

- Fix broken Rake task.

## 0.9.11 - February 21, 2012

- [#39](https://github.com/netzpirat/guard-jasmine/issues/39): Add proper return code for the Rake task.
- [#38](https://github.com/netzpirat/guard-jasmine/pull/38): Proper server shutdown. ([@darrinholst][])
- Fix command line version output.

## 0.9.10 - February 13, 2012

- [#36](https://github.com/netzpirat/guard-jasmine/pull/36): Fix CLI runner server startup test. ([@darrinholst][])

## 0.9.9 - February 13, 2012

- [#35](https://github.com/netzpirat/guard-jasmine/issues/35): Fix spec count in the results.
- [#33](https://github.com/netzpirat/guard-jasmine/issues/33): Exit code wrong on CI helper when runner fails.

## 0.9.8 - February 2, 2012

- Clean paths after last failed specs have been added.

## 0.9.7 - February 1, 2012

- [#31](https://github.com/netzpirat/guard-jasmine/issues/31): Don't try to stop a server when no server is running.
- [#30](https://github.com/netzpirat/guard-jasmine/issues/30): Provide a Rake task that wraps the Thor CLI.

## 0.9.6 - January 24, 2012

- [#28](https://github.com/netzpirat/guard-jasmine/issues/28): Relax gem dependencies.
- Improve spec file inspector.

## 0.9.5 - January 11, 2012

- [#26](https://github.com/netzpirat/guard-jasmine/issues/26): Fix version parser for PhantomJS 1.5. ([@antono][])

## 0.9.4 - January 10, 2012

- Switch to ChildProcess for managing the servers.

## 0.9.3 - January 9, 2012

- [#22](https://github.com/netzpirat/guard-jasmine/pull/22): Remove version gem dependency. ([@rymai][])

## 0.9.2 - January 5, 2012

- [#21](https://github.com/netzpirat/guard-jasmine/issues/21): Remove version from Rack and Thor dependencies.

## 0.9.1 - December 30, 2011

- Avoid log output from the server in the console

## 0.9.0 - December 19, 2011

- Add Mongrel and Thin as servers.

## 0.8.8 - December 15, 2011

- [#19](https://github.com/netzpirat/guard-jasmine/pull/19): Fix PhantomJS runner when iFrames are used. ([@obrie][])

## 0.8.7 - December 10, 2011

- [#17](https://github.com/netzpirat/guard-jasmine/pull/17): Fix CI helper for Bundler 1.1. ([@darrinholst][])

## 0.8.6 - November 30, 2011

- [#16](https://github.com/netzpirat/guard-jasmine/pull/16): Allow the server env to be configured in the CI helper. ([@mkdynamic][])

## 0.8.5 - November 23, 2011

- Set server env as default back to development for better debugging.

## 0.8.4 - November 22, 2011

- Add `:server_env` option to set rack environment.
- Fix JSON decoding problem.

## 0.8.3 - November 22, 2011

- [#14](https://github.com/netzpirat/guard-jasmine/pull/14): Set server env to test. ([@dmathieu][])

## 0.8.2 - November 6, 2011

- [#10](https://github.com/netzpirat/guard-jasmine/issues/10): Add `.coffee` to the allowed file types in the inspector.
- [#9](https://github.com/netzpirat/guard-jasmine/pull/9): Autodetect PhantomJS location. ([@dnagir][])
- [#12](https://github.com/netzpirat/guard-jasmine/issues/12): Fix timeout in the PhantomJS runner.
- [#8](https://github.com/netzpirat/guard-jasmine/pull/8): Update README with quicker setup instructions for Rails 3.1. ([@dnagir][])
- [#11](https://github.com/netzpirat/guard-jasmine/pull/11): Improve default Guardfile definition. ([@dnagir][])
- Set port on the default jasmine_url.

## 0.8.1 - November 1, 2011

- Automatically start either a Rails or Jasmine Gem server.
- Rethrow SystemExit in spec run for proper exit status.

## 0.8.0 - October 31, 2011

- Add cli helper to run guard-jasmine on CI server.

## 0.7.2 - October 19, 2011

- Quote spec runner suite argument.
- Add `:timeout` option.

## 0.7.1 - October 12, 2011

- Ensure console.log capturing before the spec run is ignored.
- More robust error handling..

## 0.7.0 - October 10, 2011

- Change default Jasmine url to http://localhost:3001/jasmine
- Add `:focus` option.
- Add `:console` option.
- Ensure PhantomJS bin is available in the right version.

## 0.6.1 - October 1, 2011

- Disable :task_has_failed until new Guard version is available.

## 0.6.0 - September 30, 2011

- Make use of :task_has_failed to abort Guard groups.
- [#3](https://github.com/netzpirat/guard-jasmine/pull/3): Correct :jasmine_url in README.md ([@dnagir][])
- Improved formatting.

## 0.5.0 - September 14, 2011

- Add an executable to request the results from the command line.
- Never run a old failed spec when only invalid paths are passed.
- When the inspector finds spec/javascripts, it only returns this path.

## 0.4.0 - September 12, 2011

- Introduce `:max_error_notify` to limit error system notifications.

## 0.3.2 - September 9, 2011

- Multiple enhancements for phantom spec runner
- Format known error message styles for better readability

## 0.3.1 - September 9, 2011

- Fix url to Jasmine runner for a single suite.

## 0.3.0 - September 8, 2011

- Better system notifications
- Catch connection refused from the Jasmine availability check.
- Test if Jasmine runner is available on start.

## 0.2.2 - September 8, 2011

- [#1](https://github.com/netzpirat/guard-jasmine/issues/1): Fix filter Regex.

## 0.2.1 - September 8, 2011

- Ensure the console.log output in the test won't go to the JSON result.

## 0.2.0 - September 7, 2011

- Do not pass the spec dir through the Inspector.
- Add `:all_on_start` option.
- `Run all` triggers all specs at once, not all specs sequentially.

## 0.1.0 - September 7, 2011

- Fix inspector glob to get also non-coffee specs.
- Finish the runner phantomjs bridge.

[@alexspeller]: https://github.com/alexspeller
[@andersjanmyr]: https://github.com/andersjanmyr
[@andyw8]: https://github.com/andyw8
[@antono]: https://github.com/antono
[@arr-ee]: https://github.com/arr-ee
[@clumsysnake]: https://github.com/clumsysnake
[@darrinholst]: https://github.com/darrinholst
[@dmathieu]: https://github.com/dmathieu
[@dnagir]: https://github.com/dnagir
[@DouweM]: https://github.com/DouweM
[@esposito]: https://github.com/esposito
[@eventualbuddha]: https://github.com/eventualbuddha
[@huyhoang1970]: https://github.com/huyhoang1970
[@jasonm]: https://github.com/jasonm
[@mkdynamic]: https://github.com/mkdynamic
[@mrship]: https://github.com/mrship
[@mutru]: https:///github.com/mutru
[@obrie]: https://github.com/obrie
[@pushbang]: https://github.com/pushbang
[@pschyska]: https://github.com/pschyska
[@richo]: https://github.com/richo
[@robotarmy]: https://github.com/robotarmy
[@ronan]: https://github.com/ronan
[@rymai]: https://github.com/rymai
[@twill88]: https://github.com/twill88
