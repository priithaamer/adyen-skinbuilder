# Adyen Skinbuilder [![Build Status](https://secure.travis-ci.org/priithaamer/adyen-skinbuilder.png?branch=master)](http://travis-ci.org/priithaamer/adyen-skinbuilder)

Simple Sinatra server to make Adyen skin authoring easier. Also includes rake tasks to bundle skin directories into deployable bundles.

## Install

    sudo gem install adyen-skinbuilder

## Usage

Make sure you have directory with basic Adyen skin structure, that looks something like this:

    +- ~/Documents
      +- DV3tf95f
        +- css
        +- img
        +- inc
          +- cfooter.txt
          +- cheader.txt
        +- js

To view something that is very much similar to the end result generated in Adyen, fire up adyen-skinbuilder sinatra server, that does the template rendering on your local machine:

    $ adyen-skinbuilder ~/Documents/DV3tf95f

Your browser will open and show you the rendered result.

See `adyen-skinbuilder --help` for more options to run server on different port or with logging etc. Run `adyen-skinbuilder -k` to shutdown.

### Base directory

If you have multiple skin directories, this gem supports base directory that can provide files that will be included in all skins without the need to duplicate them. Let's consider this example:

    +- ~/Documents
      +- base
        +- inc
          +- cfooter.txt
          +- cheader.txt
      +- DV3tf95f
        +- inc
          +- cheader.txt

File in specific skin directory takes precedence when building skin zip file. In this example, `cheader.txt` will be bundled from skin directory `DV3tf95f/inc` but `cfooter.txt` comes from `base/inc`.

## Order Data

Adyen let's you post order data that will be shown in shopping cart view as part of html. You can put `order_data.txt` file into `inc/` folder in the skin directory. This file will be included automatically in the same place, where adyen would put it.

## Building skin for upload

There is a convenient Rake task that will create zip file of the skin file. It can be used either by providing directories as rake task arguments:

    rake adyen:skin:build['/path/to/skin/directory','/path/to/target']

Also, providing environment variables will work:

    rake adyen:skin:build SKIN=/path/to/skin/directory TARGET=/path/to/target

### More meaningful file naming

Adyen requires the name of root directory within the zip file to exactly match the skincode, e.g. `DV3tf95f`.
These skincodes are not very meaningful and hard to remember.

Therefore, the skin builder allows you to name the skin directories more meaningful by prepending the skin code, e.g. like this:
`BrandX-shop-DV3tf95f`, where the only thing that matters is that it ends with `-SKINCODE`.
The zip file will be named like the original folder name (with `.zip` appended), but the root directory within the zip has the skin code as its name.
So in this example, the zip file would be called `BrandX-shop-DV3tf95f.zip`, and the root directory whithin it `DV3tf95f`.

If the skin directory does not match this pattern, the zip and root directory within the zip will both be named after the original skin directory name.

## Contributors

[See the list of contributiors](https://github.com/priithaamer/adyen-skinbuilder/network/members)


## Contributing

We'll check out your contribution if you:

- Provide a comprehensive suite of tests for your fork.
- Have a clear and documented rationale for your changes.
- Package these up in a pull request.

We'll do our best to help you out with any contribution issues you may have.


## License

The license is included as LICENSE in this directory.

