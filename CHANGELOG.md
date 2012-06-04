# Changelog

## 1.4.0 - June 4, 2012

- [Pull #65](https://github.com/netzpirat/guard-jasmine/pull/65): Support unicorn as server. ([@pushbang][] and [@clumsysnake][])

## 1.3.0 - June 2, 2012

- Upgrade for Guard 1.1.0

## 1.2.2 - Mai 29, 2012

- [Issue #64](https://github.com/netzpirat/guard-jasmine/issues/64): Suite result specs may be undefined and makes the runner fail.

## 1.2.1 - Mai 25, 2012

- [Issue #63](https://github.com/netzpirat/guard-jasmine/issues/63): The failures are not logged in the right order when there are nested describes.

## 1.2.0 - Mai 21, 2012

- [Pull #62](https://github.com/netzpirat/guard-jasmine/pull/62): Show console log messages and errors independently from specdocs in Guard. ([@esposito][])

## 1.1.4 - Mai 18, 2012

- [Pull #60](https://github.com/netzpirat/guard-jasmine/pull/60): Test if spec file exists. ([@huyhoang1970][])

## 1.1.3 - Mai 9, 2012

- [Issue #57](https://github.com/netzpirat/guard-jasmine/issues/57): Fix error trace notification.

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

- [Issue #45](https://github.com/netzpirat/guard-jasmine/issues/45): Cannot start Rack server.

## 1.0.2 - March 10, 2012

- [Pull #44](https://github.com/netzpirat/guard-jasmine/pull/44): Allow a Guardfile to specify a custom rake task as the server. ([@eventualbuddha][])

## 1.0.1 - March 9, 2012

- Optimize PhantomJS runner result passing to improve speed.

## 1.0.0 - March 9, 2012

- Add a console.log implementation that supports formatting and pretty printing.
- [Issue #43](https://github.com/netzpirat/guard-jasmine/issues/43): Fix Rake rask for Ruby 1.9.3p125

## 0.9.14 - March 8, 2012

- [Issue #42](https://github.com/netzpirat/guard-jasmine/issues/42):  Add the possibility to start a custom Rake based server.
- [Issue #42](https://github.com/netzpirat/guard-jasmine/issues/42):  Add option to configure the Jasmine spec directory.
- [Pull #41](https://github.com/netzpirat/guard-jasmine/pull/41): Clean up Guardfile template. ([@DouweM][])

## 0.9.13 - February 29, 2012

- [Pull #40](https://github.com/netzpirat/guard-jasmine/pull/40): Add clean option to skip the spec path cleaning. ([@andersjanmyr][])

## 0.9.12 - February 20, 2012

- Fix broken Rake task.

## 0.9.11 - February 21, 2012

- [Issue #39](https://github.com/netzpirat/guard-jasmine/issues/39): Add proper return code for the Rake task.
- [Pull #38](https://github.com/netzpirat/guard-jasmine/pull/38): Proper server shutdown. ([@darrinholst][])
- Fix command line version output.

## 0.9.10 - February 13, 2012

- [Pull #36](https://github.com/netzpirat/guard-jasmine/pull/36): Fix CLI runner server startup test. ([@darrinholst][])

## 0.9.9 - February 13, 2012

- [Issue #35](https://github.com/netzpirat/guard-jasmine/issues/35): Fix spec count in the results.
- [Issue #33](https://github.com/netzpirat/guard-jasmine/issues/33): Exit code wrong on CI helper when runner fails.

## 0.9.8 - February 2, 2012

- Clean paths after last failed specs have been added.

## 0.9.7 - February 1, 2012

- [Issue #31](https://github.com/netzpirat/guard-jasmine/issues/31): Don't try to stop a server when no server is running.
- [Issue #30](https://github.com/netzpirat/guard-jasmine/issues/30): Provide a Rake task that wraps the Thor CLI.

## 0.9.6 - January 24, 2012

- [Issue #28](https://github.com/netzpirat/guard-jasmine/issues/28): Relax gem dependencies.
- Improve spec file inspector.

## 0.9.5 - January 11, 2012

- [Issue #26](https://github.com/netzpirat/guard-jasmine/issues/26): Fix version parser for PhantomJS 1.5. ([@antono][])

## 0.9.4 - January 10, 2012

- Switch to ChildProcess for managing the servers.

## 0.9.3 - January 9, 2012

- [Pull #22](https://github.com/netzpirat/guard-jasmine/pull/22): Remove version gem dependency. ([@rymai][])

## 0.9.2 - January 5, 2012

- [Issue #21](https://github.com/netzpirat/guard-jasmine/issues/21): Remove version from Rack and Thor dependencies.

## 0.9.1 - December 30, 2011

- Avoid log output from the server in the console

## 0.9.0 - December 19, 2011

- Add Mongrel and Thin as servers.

## 0.8.8 - December 15, 2011

- [Pull #19](https://github.com/netzpirat/guard-jasmine/pull/19): Fix PhantomJS runner when iFrames are used. ([@obrie][])

## 0.8.7 - December 10, 2011

- [Pull #17](https://github.com/netzpirat/guard-jasmine/pull/17): Fix CI helper for Bundler 1.1. ([@darrinholst][])

## 0.8.6 - November 30, 2011

- [Pull #16](https://github.com/netzpirat/guard-jasmine/pull/16): Allow the server env to be configured in the CI helper. ([@mkdynamic][])

## 0.8.5 - November 23, 2011

- Set server env as default back to development for better debugging.

## 0.8.4 - November 22, 2011

- Add `:server_env` option to set rack environment.
- Fix JSON decoding problem.

## 0.8.3 - November 22, 2011

- [Pull #14](https://github.com/netzpirat/guard-jasmine/pull/14): Set server env to test. ([@dmathieu][])

## 0.8.2 - November 6, 2011

- [Issue #10](https://github.com/netzpirat/guard-jasmine/issues/10): Add `.coffee` to the allowed file types in the inspector.
- [Pull #9](https://github.com/netzpirat/guard-jasmine/pull/9): Autodetect PhantomJS location. ([@dnagir][])
- [Issue #12](https://github.com/netzpirat/guard-jasmine/issues/12): Fix timeout in the PhantomJS runner.
- [Pull #8](https://github.com/netzpirat/guard-jasmine/pull/8): Update README with quicker setup instructions for Rails 3.1. ([@dnagir][])
- [Pull #11](https://github.com/netzpirat/guard-jasmine/pull/11): Improve default Guardfile definition. ([@dnagir][])
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
- [Pull #3](https://github.com/netzpirat/guard-jasmine/pull/3): Correct :jasmine_url in README.md ([@dnagir][])
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

- [Issue #1](https://github.com/netzpirat/guard-jasmine/issues/1): Fix filter Regex.

## 0.2.1 - September 8, 2011

- Ensure the console.log output in the test won't go to the JSON result.

## 0.2.0 - September 7, 2011

- Do not pass the spec dir through the Inspector.
- Add `:all_on_start` option.
- `Run all` triggers all specs at once, not all specs sequentially.

## 0.1.0 - September 7, 2011

- Fix inspector glob to get also non-coffee specs.
- Finish the runner phantomjs bridge.

[@andersjanmyr]: https://github.com/andersjanmyr
[@antono]: https://github.com/antono
[@clumsysnake]: https://github.com/clumsysnake
[@darrinholst]: https://github.com/darrinholst
[@dmathieu]: https://github.com/dmathieu
[@dnagir]: https://github.com/dnagir
[@DouweM]: https://github.com/DouweM
[@esposito]: https://github.com/esposito
[@eventualbuddha]: https://github.com/DouweM
[@huyhoang1970]: https://github.com/huyhoang1970
[@jasonm]: https://github.com/jasonm
[@mkdynamic]: https://github.com/mkdynamic
[@obrie]: https://github.com/obrie
[@pushbang]: https://github.com/pushbang
[@rymai]: https://github.com/rymai
