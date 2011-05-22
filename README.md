# Padrino Integration

## Preface

As we approach 1.0, we want to get solid release processes in place. We have [setup Jenkins](http://jenkins.lipsiasoft.com) with our unit tests. This project will serve as additional integration tests to ensure that Padrino works as expected for various generators and components to improve the robustness of our releases.

## Installation

Clone and install dependencies:

```
git clone https://github.com/padrino/padrino-integration
bundle install
```

Run the integration test suite:

```
$ gem install couchrest_model # generated projects need a stable version but during tests we use git version
$ gem install data_mapper     # generated projects need this but we use separated gem because dm-serialize has a conflict with couchrest_model
$ rake spec
$ rake spec:padrino # => to run only padrino specs
$ rake spec:single_apps # => to run only single-apps specs
$ rake spec:padrino/single_apps 30 # to run only a spec at line 30
$ rake launch app=padrino_basic # to launch the single-app padrino_basic
```

and that will output the results of comprehensive integration tests, before a release they should always pass! We will eventually get this set