# [![Build Status](http://travis-ci.org/lmarburger/altum.png)](http://travis-ci.org/lmarburger/altum)
#
# **Altum** uses the magic of Pusher and websockets to drive a [ShowOff][]
# presentation remotely.
#
# Altum consists of a piece of Rack middleware and some JavaScript that keeps
# viewers in sync with the presenter. Getting started is easy.
#
# Install Altum with Rubygems:
#
#     gem install altum
#
# ShowOff will create a `config.ru` file when using the command `showoff heroku`
# or simply create one yourself. Add Altum as you would any other Rack
# middleware supplying it with your Pusher connection URL and a key used to
# identify the presenter.
#
#     require 'showoff'
#     require 'altum'
#
#     use Altum, :pusher_url => ENV['PUSHER_URL'], :key => 'sekret'
#     run ShowOff.new
#
# Next, download [altum.js][] into your presentation directory. Copy the code
# from the latest [pusher.min.js][] and paste it at the top of `altum.js`.
#
# Start the presentation locally with `rackup` or deploy it to heroku using
# `showoff heroku`. You're ready to present! Open the presentation as the
# presenter by visiting
# [http://_your-app-name_.heroku.com?presenter=sekret][presenter] and ask those
# observing to follow along with you at
# [http://_your-app-name_.heroku.com][observer]. Your observer's browsers will
# follow along with you as you move through your deck; forward, backward, and
# jumping to a specific slide.
#
#
# [showoff]:       https://github.com/schacon/showoff
# [altum.js]:      https://github.com/lmarburger/altum/blob/master/altum.js
# [pusher.min.js]: http://js.pusherapp.com/1.9/pusher.min.js
# [presenter]:     http://your-app-name.heroku.com?presenter=sekret
# [observer]:      http://your-app-name.heroku.com

require 'altum/version'
require 'pusher'

# `Altum.new` takes the downstream `app` and an `options` hash. The `options`
# hash respects two members:
#
# * `:pusher_url`: the Pusher connection URL passed to `Pusher.url=`. If you're
#   using Pusher as a Heroku add-on, it will be in the environment variable
#   `PUSHER_URL`.
#
# * `:key`: an optional secret key to identify the presenter pass as a query
#   string parameter. If `:key` is nil or doesn't exist, the default "sekret" is
#   used. Append `?presenter=sekret` to the ShowOff URL to drive the
#   presentation.
class Altum

  def initialize(app, options)
    @app = app
    @key = options[:key] || 'sekret'

    Pusher.url = options[:pusher_url]
  end

  # Listen for slide change commands from the presenter and send the current
  # slide out to all those watching. Silently ignore requests from a presenter
  # using an incorrect key.
  def call(env)
    request = Rack::Request.new env

    if slide_path? request
      change_slide request if presenter?(request)

      [ 204, {}, [] ]
    else
      @app.call env
    end
  end

protected

  # Respond only to requests for `/slide`.
  def slide_path?(request)
    request.path == '/slide'
  end

  # Match the key supplied in the request with the key used when the middlware
  # was configured.
  def presenter?(request)
    request.params['key'] == @key
  end

  # Grab the current slide number from the `number` parameter of the request.
  # Pass it to those observing by triggering the `presenter` channel's
  # `slide_change` event.
  def change_slide(request)
    Pusher['presenter'].trigger('slide_change', {
      'slide' => request.params['number']
    })
  end

end
