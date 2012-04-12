# Adyen Skinbuilder [![Build Status](https://secure.travis-ci.org/priithaamer/adyen-skinbuilder.png?branch=master)](http://travis-ci.org/priithaamer/adyen-skinbuilder)

Simple Sinatra server to make Adyen skin authoring easier. It does the template rendering on your local machine, which is very much similar to the end result generated in Adyen. Given adyen admin credentials provided, it also allows to upload and test skin within just one click.

## Install

    sudo gem install adyen-skinbuilder

## Usage

Adyen Skinbuilder provides to different pages:

### Payment Page

Start the server by providing the local path to your skin

    $ adyen-skinbuilder ~/Documents/DV3tf95f

A browser will open and show the rendered result.

### Index Page

Navigate to root "/" or provide the skin parent directory to access the index page.

    $ adyen-skinbuilder ~/Documents/


There, you get to option to sync local skin with remote ones, upload a local skin or directly jump to a test page.


See `adyen-skinbuilder --help` for more options to run server on different port or with logging etc. Run `adyen-skinbuilder -k` to shutdown.


## Skin Strucutre

Usually Adyen requires to split up the skin page in up to four different files. But no worries, Skinbuilder does that for you. Yes, you read right: you just put all the content in one main file `skin.html.erb` - Skinbuilder will auto split, zip and even upload the skin. Wihtin the skin file you can make use of handy helper methods to define adyen form and payment fields or even to render other partials. A most minimal file would look like:

```html
<h1> exmaple skin</h1>

<% adyen_form_tag do %>
  <h3>header</h3>
  <%= adyen_payment_fields %>
<% end %>

```

### Code Sharing

If you have multiple skin directories, this gem supports several ways how to share code in between:

#### Shared Partials


#### Base directory

_Deprecated since Version 0.3_

 Create a `base` directory to provide files that will be included in all skins without the need to duplicate them. Let's consider this example:

    +- ~/Documents
      +- base
        +- inc
          +- cfooter.txt
          +- cheader.txt
      +- DV3tf95f
        +- inc
          +- cheader.txt

File in specific skin directory takes precedence when building skin zip file. In this example, `cheader.txt` will be bundled from skin directory `DV3tf95f/inc` but `cfooter.txt` comes from `base/inc`.

### Order Data

Adyen let's you post order data that will be shown in shopping cart view as part of html. You can put `order_data.txt` file into `inc/` folder in the skin directory. This file will be included automatically in the same place, where adyen would put it.

## Building skin for upload

For the easiest way to upload a skin, we encourage to provide the Adyen Admin credentials within the `.adyenrc` file, either in you home- or execution root directory.

Exmaple `.adyenrc` file:

```
accountname: <your account>
username: <your username>
password: <your password>
```

Navigate to the index page `/` and find the option to upload the skin. In anycase you can download the zipped skinfile via `compile` link.

## More meaningful file naming

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

