# Padrino Integration

## Preface

As we approach 1.0, we want to get solid release processes in place. We have setup hudson with our unit tests. This project will serve as additional integration tests to ensure that Padrino works as expected for various generators and components to improve the robustness of our releases.

## Installation

Clone and install dependencies:

    git clone https://github.com/padrino/padrino-integration
    bundle install

Run the integration test suite:

   $ rake spec

and that will output the results of comprehensive integration tests, before a release they should always pass! We will eventually get this set
