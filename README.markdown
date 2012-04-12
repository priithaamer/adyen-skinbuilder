# Adyen Skinbuilder [![Build Status](https://secure.travis-ci.org/priithaamer/adyen-skinbuilder.png?branch=master)](http://travis-ci.org/priithaamer/adyen-skinbuilder)

Simple Sinatra server to make Adyen skin authoring easier. It performs the template rendering on your local machine, which is very much similar to the end result generated in Adyen. Given adyen admin credentials provided, it allows to upload and test skins with just one click.

## Install

    sudo gem install adyen-skinbuilder


## Usage

Adyen Skinbuilder provides a Index page for full overview on all remote and local skins and options to up-/download etc. To load the page, start the server by providing the local path to your skin directory:

    $ adyen-skinbuilder ~/Documents

Alternatively provide the full path to a skin which opens the browser and shows the rendered result directly.

$ adyen-skinbuilder ~/Documents/DV3tf95f


See `adyen-skinbuilder --help` for more options to run server on different port or with logging etc. Run `adyen-skinbuilder -k` to shutdown.


## Skin Strucutre

Usually Adyen requires to split up the skin page in up to four different files. But no worries, Skinbuilder does that for you. Yes, you read right: you just put all the html content in one file called `skin.html.erb` - Skinbuilder will auto split, zip and even upload the skin. Within the skin file you can make use of handy helper methods to define the adyen form and payment fields or even to render other partials.

A most minimal file would look like:

```html
<h1> exmaple skin</h1>

<% adyen_form_tag do %>
  <h3>header</h3>
  <%= adyen_payment_fields %>
<% end %>

```

### Code Sharing

Witha large number of skins it makes sense to reuse code + styling among several skins. This gem supports several ways how to share code in between:

#### Shared Partials

Similar as in rails, Skinbuilder allows to render other files inline, e.g.:


```html
<h1>Exmaple Skin with partial</h1>

<%= render_partial 'header.html' %>

<% adyen_form_tag do %>
  <h3>header</h3>
  <%= adyen_payment_fields %>
<% end %>

```

This will load and render `header.html.erb` for your skin root on top of the form.

#### Base directory

_Deprecated since Version 0.3_

Another way is to create a `base` directory to provide fallback files that will be included in all skins without the need to duplicate them. Let's consider this example:

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

## Interacting with remote Adyen Admin

To interact with the remote Adyen Admin interface, Skinbuilder makes use of the [adyen-admin](https://github.com/rngtng/adyen-admin) gem. This
allows to download/upload skins easily. To enable remote admin, provide the Adyen Admin credentials within the `.adyenrc` file, either in you home- or execution root directory. !!We encourage to set up a dedicated useraccount with low rights for that!!

An example `.adyenrc` file:

    scope: test
    accountname: <your account>
    username: <your username>
    password: <your password>


Navigate to the index page `/` and hit `Sync once and you'll find the option to upload the skins. In anycase you always can download the zipped skinfile via the `compile` link. *By now, only adyen test is provided*

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

