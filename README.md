# Private Pub Custom

Private Pub is a Ruby gem for use with Rails to publish and subscribe to messages through [Faye](http://faye.jcoglan.com/). It allows you to easily provide real-time updates through an open socket without tying up a Rails process. All channels are private so users can only listen to events you subscribe them to.

Inspired by [Private pub Gem](https://github.com/ryanb/private_pub)
Watch [RailsCasts Episode 316](http://railscasts.com/episodes/316-private-pub) for a demonstration of Private Pub.


## Setup

Add the gem to your Gemfile and run the `bundle` command to install it. You'll probably want to add "thin" to your Gemfile as well to serve Faye.

```ruby
gem "private_pub", git: "git://github.com/amritsingh/private_pub.git"
gem "thin"
```

Run the generator to create the initial files.

```
rails g private_pub:install
```
This will generate a file in Rails root directory - 'private_pub.ru'.
Authentication of subscribe and publish messages can be modified based on the needs of the application.


Next, start up Faye using the rackup file that was generated.

```
rackup private_pub.ru -s thin -E production
```

**In Rails 3.1** add the JavaScript file to your application.js file manifest.

```javascript
//= require private_pub
```


## Usage

Use the `publish_to` method to send data to that channel.

```ruby
PrivatePub.publish_to "/messages/new", :chat_message => "Hello, world!" do |channel, data|
  # construct a message here. This message is sent to the subscribed clients e.g.
  # {:channel => channel, :data => {:channel => channel, :data => data, :time => Time.now}}
end
```

