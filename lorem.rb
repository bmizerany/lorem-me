require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'hpricot'
require 'time'
require 'rest_client'

LOREM = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed
do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim
ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut
aliquip ex ea commodo consequat. Duis aute irure dolor in
reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
culpa qui officia deserunt mollit anim id est laborum. " unless defined?(LOREM)

helpers do

  def gh
    @c ||= RestClient::Resource.new("http://gist.github.com")
  end

  def g(p, c)
    lorems = Array.new(p) {
      "<div class='lorem'>#{LOREM * (rand(3) + 1)}</div>"
    }
    gists = Array.new(c) {
      doc = Hpricot(gh["/gists"].get)
      gists = doc / '#files .file .meta .info span a'
      gist = gists[rand(gists.length - 1)]['href']
      "<script src='http://gist.github.com#{gist}.js'></script>"
    }
    (lorems + gists).sort_by { rand }
  end

  def one_year_from_now
    (Time.now + (60 * 60 * 24 * 365) - 1)
  end

  def expires(date)
    response['Expires'] = date.httpdate.to_s
  end

end

get('/m.css') { expires one_year_from_now ; sass :m }

get '/' do
  expires one_year_from_now
  i = params ; redirect "/#{i[:p].to_i}/#{i[:c].to_i}" if i.has_key?('p')
  haml(:index)
end

get "/:p/:c" do
  @sections = g(params[:p].to_i, params[:c].to_i)
  haml(:generator)
end

get '/:p/:c.raw' do
  @sections = g(params[:p].to_i, params[:c].to_i)
  haml(:sections, :layout => false)
end
