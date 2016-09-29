# as_deprecation_tracker

Tracks known ActiveSupport (Rails) deprecation warnings and catches new issues
when an unknown warning is seen.

This allows for easier upgrades of Rails and other AS-based apps because as
each deprecation warning is fixed, it's removed from the whitelist and any
attempt to reintroduce the deprecated call will fail.

The library maintains the whitelist in a configuration file that's usually
initially written by running the app test suite with an environment variable
set. When the tests are run normally, deprecation warnings triggered that
aren't in the config file will raise an exception. The call can then be fixed
or added to the whitelist with the provided instructions.

## Installation

    $ gem install as_deprecation_tracker

or in your Gemfile:

    gem 'as_deprecation_tracker', '~> 1.0', group: 'test'

This gem and its API is versioned according to semver.

It's recommended to only add the gem to the test Bundler group as raising
errors in production and development isn't desirable.

## Usage

### Whitelisting

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
- message: Deprecated call to X, use Y instead
- message: Deprecated call to Z
  callstack:
    - app/models/foo.rb:23
```

Accepted keys are `message`, matching the exact deprecation message and
`callstack`, an array forming the backtrace of the deprecation, which must
match exactly.

### Configuration

Use an initializer to change ASPT's behaviour at startup:

```ruby
ASDeprecationTracker.config.envs = %w(test development)
```

Supported options:

* `envs` is an array of string Rails environment names that ASPT will monitor
  and raise errors for unpermitted deprecation warnings (defaults to
  `['test']`)
* `register_behavior` controls whether to change the AS::Deprecation behavior
  to ASDeprecationTracker::Receiver at startup, may be disabled to use multiple
  behaviors (defaults to true)

## License

Copyright (c) 2016 Dominic Cleal.  Distributed under the MIT license.
