Simple Rack server to make Adyen skin authoring easier. Also includes rake tasks to bundle skin directories into deployable bundles (not yet implemented).

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

To view something that is very much similar to the end result generated in Adyen, fire up adyen-skinbuilder rack server, that does the template rendering on your local machine:

    $ adyen-skinbuilder ~/Documents/DV3tf95f

And go to http://localhost:8888 to see the generated page.

See `adyen-skinbuilder --help` for more options to run server on different port or with logging etc.

## Order Data

Adyen let's you post order data that will be shown in shopping cart view as part of html. You can put `order_data.txt` file into `inc/` folder in the skin directory. This file will be included automatically in the same place, where adyen would put it.

## Building skin for upload

There is a convenient Rake task that will create zip file of the skin file. It can be used either by providing directories as rake task arguments:

    rake adyen:skin:build['/path/to/skin/directory','/path/to/target']

Also, providing environment variables will work:

    rake adyen:skin:build SKIN=/path/to/skin/directory TARGET=/path/to/target

Why is it better than just zipping together skin directory by yourself? Just because we can and it also looks into base directory for shared files if you happen to have several skin directories.
