require 'minitest/autorun'
require 'minitest/spec'
require 'webmock/minitest'
require 'wrong/adapters/minitest'

require 'altum'
require 'rack/mock'

class DummyApp
  def call(env)
    [ 200, {}, ["Hello World"] ]
  end
end

describe Altum do

  def pusher_url
    'http://1234:4321@api.pusherapp.com/apps/1324'
  end

  def request(options = {})
    options = options.merge :pusher_url => pusher_url

    Rack::MockRequest.new Altum.new(DummyApp.new, options)
  end

  def stub_push
    stub_request(:post, %r{\Ahttp://api\.pusherapp\.com/apps/1324/channels/presenter/events\?auth_key=1234&.*&name=slide_change\Z}).
      to_return(:status => 202)
  end

  it 'sets up Pusher' do
    Altum.new(DummyApp.new, :pusher_url => pusher_url)

    assert { Pusher.host   == 'api.pusherapp.com' }
    assert { Pusher.port   == 80 }
    assert { Pusher.key    == '1234' }
    assert { Pusher.secret == '4321' }
    assert { Pusher.app_id == '1324' }
  end

  it 'passes along irrlevant requests' do
    res = request.get '/'

    assert { res.ok? }
    assert { res.body == 'Hello World' }
  end

  it 'responds to requests' do
    stub_push
    res = request.get '/slide?key=sekret&number=1'

    assert { res.status == 204 }
    assert { res.empty? }

    assert_requested :post,
                     %r{http://api\.pusherapp\.com},
                     :body => JSON(:slide => '1')
  end

  it 'responds without pushing with an incorrect key' do
    res = request.get '/slide?key=wrong'

    assert { res.status == 204 }
    assert { res.empty? }
  end

  it 'overrides the default key' do
    stub_push
    res = request(:key => 'super-sekret').get '/slide?key=super-sekret&number=1'

    assert { res.status == 204 }
    assert { res.empty? }

    assert_requested :post,
                     %r{http://api\.pusherapp\.com},
                     :body => JSON(:slide => '1')
  end

  it 'uses the default key when nil' do
    stub_push
    res = request(:key => nil).get '/slide?key=sekret&number=1'

    assert { res.status == 204 }
    assert { res.empty? }

    assert_requested :post,
                     %r{http://api\.pusherapp\.com},
                     :body => JSON(:slide => '1')
  end

end
