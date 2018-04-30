require 'sinatra'
require 'sqlite3'
require 'active_record'
require 'json'

database  = YAML.load(File.read('database.yml'))
ActiveRecord::Base.establish_connection(database)

class Scan < ActiveRecord::Base ; end

get '/' do
  erb :home
end

get '/scans' do
  erb :index, locals: { scans: Scan.all }
end

get '/scans/new' do
  erb :new, locals: { scan: Scan.new }
end

get '/scans/:id' do
  erb :show, locals: { scan: Scan.find(params[:id]) }
end

post '/scans' do
  content = JSON.parse(params[:data])
  new_scan = Scan.new content
  new_scan.save!
  redirect '/scans'
end
