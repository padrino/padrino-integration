# Padrino Integration

> **This suite is no longer maintained.** padrino-framework now tests generated projects itself: its smoke runner (`bundle exec rake smoke:list`, then `bundle exec rake 'smoke[<combination>]'`, with the combinations in [`smoke/combinations.yml`](https://github.com/padrino/padrino-framework/blob/master/smoke/combinations.yml)) generates a project for each combination of components, bundles, migrates, renders, runs the project's own tests and boots it, and CI runs it nightly and on pull requests that change the generators or the admin. This repository is kept for reference.

[![Build Status](https://secure.travis-ci.org/padrino/padrino-integration.png?branch=master)](http://travis-ci.org/padrino/padrino-integration)

As we approach 1.0, we want to get solid release processes in place.
This project will serve as additional integration tests to ensure that Padrino works as expected
for various generators and components to improve the robustness of our releases.

## Installation

Clone and install dependencies:

```
git clone https://github.com/padrino/padrino-integration
bundle install
```

Run the integration test suite:

```
$ rake spec                     # run only padrino specs
$ rake spec:padrino             # run only padrino specs
$ rake spec:single_apps         # run only single-apps specs
$ rake launch app=padrino_basic # launch the single-app padrino_basic
```

That will output the results of comprehensive integration tests, before a release they should always pass!
