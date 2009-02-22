require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'nokogiri'

LOREM = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed
do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim
ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut
aliquip ex ea commodo consequat. Duis aute irure dolor in
reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
culpa qui officia deserunt mollit anim id est laborum. " unless defined?(LOREM)

class GistPicker
  def initialize
    doc = Nokogiri::HTML(open("http://gist.github.com/gists"))
    @gists = doc.css('#files .file .meta .info span a')
  end

  def next
    @gists[rand(@gists.size - 1)]['href']
  end
end

helpers do
  def g(p, c)
    ((1..p).collect { rand(3) } + Array.new(c, :c)).
      sort_by { rand }
  end
end

get "/:p/:c" do
  @gists = GistPicker.new
  haml(:index)
end

__END__

@@ index

%html
  %head
    %title Lorem.me
    %style
      :sass
        body
          :font-family Georgia
        #title
          :font-size 5em
        #container
          :margin 0 auto
          :width 800px
        #content
          :text-align left
          .lorem
            :margin-top 1em
            :margin-bottom 1em
  %body
    #container
      #title Lorem.me
      #content
        - for s in g(params[:p].to_i, params[:c].to_i)
          - if s == :c
            %script{ :src => "http://gist.github.com#{@gists.next}.js" }
          - else
            .lorem= LOREM * s
