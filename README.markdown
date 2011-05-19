Simple Rack server to make Adyen skin authoring easier. Also includes rake tasks to bundle skin directories into deployable bundles (not yet implemented):

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

    adyen-skinbuilder ~/Documents/DV3tf95f

And go to http://localhost:8888 to see the generated page.

See `adyen-skinbuilder --help` for options when running this server.
