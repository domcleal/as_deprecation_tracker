# as_deprecation_tracker

Tracks known ActiveSupport (Rails) deprecation warnings and catches new issues
when an unknown warning is seen.

This allows for easier upgrades of Rails and other AS-based apps because as
each deprecation warning is fixed, it's removed from the whitelist and any
attempt to reintroduce the deprecated call will fail. It's also useful when the
app runs on multiple versions of Rails and newer deprecation warnings can't be
fixed yet without breaking the older version.

The library maintains the whitelist in a configuration file that's usually
initially written by running the app test suite with an environment variable
set. When the tests are run normally, deprecation warnings triggered that
aren't in the config file will raise an exception. The call can then be fixed
or added to the whitelist with the provided instructions.

If you'd prefer just to fix all deprecation warnings at once then this gem is
unnecessary! Just use:

```ruby
ActiveSupport::Deprecation.behavior = :raise
```

in your test environment config.

## Installation

    $ gem install as_deprecation_tracker

or in your Gemfile:

    gem 'as_deprecation_tracker', '~> 1.0', group: 'test'

This gem and its API is versioned according to semver.

It's recommended to only add the gem to the test Bundler group as raising
errors in production and development isn't desirable.

## Usage

### Automatic whitelisting

To set up an initial whitelist, run:

    AS_DEPRECATION_RECORD=yes bin/rake test

This will generate `config/as_deprecation_whitelist.yaml` with a list of
specific instances of deprecated calls which can be committed. Subsequent `rake
test` runs will then automatically raise errors for new occurrences.

Re-run tests with `AS_DEPRECATION_RECORD=yes` to append new instances to the
existing whitelist file, if you wish to permit rather than fix them.

Use `AS_DEPRECATION_WHITELIST=~/rails_engine` to set a different root directory
or whitelist file to update, e.g. for a Rails engine.

### Whitelist configuration

The whitelist may be broad, permitting any call causing a particular
deprecation message or be precise, only permitting known calls identified by
their backtrace. With broad whitelists, more instances of the same deprecated
call may be added, but precise whitelists require more maintenance if code is
moved and the backtrace changes.

The whitelist is stored in the Rails root at
`config/as_deprecation_whitelist.yaml` and is a YAML file containing a single
array of hashes:

```yaml
---
- message: "Deprecated call to X, use Y instead"
- message: "Deprecated call to Z"
  callstack: "app/models/foo.rb:23:in `example_method'"
```

Accepted keys are:

* `message`, matching the exact deprecation message
* `callstack`, a string or an array forming the backtrace of the deprecation.
  If an array is given for the callstack, all entries must match the caller.
* `engine`, a Rails `engine_name` string, matching any call within the engine

The callstack will match on as much data as is provided - if only a file is
given, any matching deprecation within the file will be whitelisted. The line
number and method specification may be given for more specificity. The line
number may vary by up to ten lines from the recorded number by default (see
`line_tolerance` to tune). Usually the filename and method name are sufficient
to match the caller without needing line numbers.

The message is an exact string match on the _start_ of the deprecation message,
so not all of the original deprecation message needs to be specified.

Additional whitelist files may be placed below the root of each Rails engine
and will be loaded at startup in addition to the main Rails root config file.

Entries can be added programmatically by calling
`ASDeprecationTracker.whitelist.add(message: ...)` with any of the supported
keys above supplied as keyword arguments.

### Configuration

Use an initializer to change ASDT's behaviour at startup:

```ruby
ASDeprecationTracker.config.envs = %w(test development)
```

Supported options:

* `envs` is an array of string Rails environment names that ASDT will monitor
  and raise errors for unpermitted deprecation warnings (defaults to
  `['test']`)
* `line_tolerance` is the number of lines that callstack line numbers may
  differ from the deprecated call (defaults to 10)
* `register_behavior` controls whether to change the AS::Deprecation behavior
  to ASDeprecationTracker::Receiver at startup, may be disabled to use multiple
  behaviors (defaults to true)
* `whitelist_file` to customise the location of the whitelist YAML file
  (defaults to `config/as_deprecation_whitelist.yaml`)

### Environment variables

Both `AS_DEPRECATION_` or the shorter `ASDT_` prefixes work with all
environment variables listed below.

* `AS_DEPRECATION_DISABLE` - set to any value will prevent ASDT from monitoring
  deprecations and throwing exceptions. Rails will use default deprecation
  behaviour.
* `AS_DEPRECATION_RECORD` - set to any value will prevent ASDT from throwing
  exceptions and will append entries to the `whitelist_file` for every
  deprecation seen.
* `AS_DEPRECATION_WHITELIST` - set to the root or full path of a whitelist
  configuration file, overrides `whitelist_file`.

### Pause/resume

The processing of deprecation warnings can be suspended and resumed via the
`ASDeprecationTracker.pause!` and `ASDeprecationTracker.resume!` methods.

This is useful when programmatically building whitelist entries during Rails
initialisation, as deprecation processing can be disabled until the whitelist
is fully formed. ASDT will queue events while paused and processes them when
`resume!` is called.

## Alternatives

Shopify have open-sourced a gem that works very similarly to ASDT and is worth
a look. It supports more configuration options when seeing a new or removed
deprecation warning, and also supports `Kernel#warn`.

* [Shopify: Introducing the deprecation toolkit](https://engineering.shopify.com/blogs/engineering/introducing-the-deprecation-toolkit)
* [deprecation_toolkit (GitHub)](https://github.com/shopify/deprecation_toolkit)

## License

Copyright (c) 2016-2022 Dominic Cleal.  Distributed under the MIT license.
