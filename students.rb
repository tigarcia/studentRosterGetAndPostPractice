require 'sinatra'
require 'sinatra/reloader'
require "sinatra/cookies"
require 'pry'
require 'json'

configure do
  root = File.expand_path(File.dirname(__FILE__))
  set :views, File.join(root, 'views')
end

@@students = {:students => []}

def create_student(name, hobby, avatar)
  @@students[:students].push({:name =>name, :hobby => hobby, :avatar => avatar})
end

create_student("Tim", "Sailing", "https://avatars.githubusercontent.com/u/5817502?v=3")
create_student("Colt", "Hiking", "https://avatars.githubusercontent.com/u/5498438?v=3")


get '/' do
  @students = @@students[:students]
  erb :index
end

get '/students' do
  content_type :json
  JSON.generate(@@students)
end

post '/students' do
  content_type :json

  login = cookies[:login]
  json = request.body.read

  student = {}
  if not json.nil?
    student = JSON.parse(json)  
  end

  if login.nil? or login != "g9fullstack"
     status 401
     "{\"error\": \"authentication not valid. The login cookie is missing or does not have the correct value\"}\n"
  elsif not json.nil? and student.has_key? "name" and student.has_key? "hobby" and student.has_key? "avatar"
    create_student(student["name"], student["hobby"], student["avatar"])
    status 200
    "{\"success\":\"new student created\"}"
  else
    status 400
    "{\"error\": \"bad request\"}"
  end
end
