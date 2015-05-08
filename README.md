# BoostInfo

Simple parser for [Boost INFO format](http://www.boost.org/doc/libs/1_42_0/doc/html/boost_propertytree/parsers.html#boost_propertytree.parsers.info_parser).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'boost_info'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boost_info

## Usage

### Parsing INFO
```ruby
BoostInfo.parse(file, options={})
```

Available options: 

- **symbolize_names**: convert all keys to symbols (default: false)

### Generating INFO

```ruby
{ x: 'y' }.to_info(options={})
```

Available options: 

- **indent**: indentation level (default: 4)

## Contributing

1. Fork it ( https://github.com/zenbro/boost_info/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Credits

Originally created by Igor Vetrov.

## License

Code released under the [MIT License](http://www.opensource.org/licenses/MIT).
