require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
#require "sinatra/activerecord"
require 'sinatra/logger'

configure :development, :production do
  enable :logging
  set :clean_trace, true
  set :logger_level, :info
  set :gitosis_config_file_path, File.expand_path(File.dirname(__FILE__)+"/doc/gitosis.conf")
end

class GitosisAdm
  attr_accessor :gitosis_config_path
  def initialize(conf_path)
    @gitosis_config_path = conf_path
  end

  def get_list_of_repositories
    get_repo_hash.keys
  end

  def get_repo_members(repo)
    get_repo_hash[repo].split(" ")
  end

  def get_repo_hash
    repo=""
    repos=Hash.new()
    regex=/writable/
    regex2=/members/

    File.readlines(@gitosis_config_path).each do |line|
        repo=line.split("=")[1].lstrip.chomp! if (line[regex]);
        repos[repo] = line.split("=")[1].lstrip.chomp! if (line[regex2])
    end

    return repos
  end
end

gitosis=GitosisAdm.new(settings.gitosis_config_file_path)

get '/' do
  @repos = gitosis.get_repo_hash

  erb :index
end

get '/repos/:id' do
  puts "Asking for details about "+params[:id]
  @members = gitosis.get_repo_members(params[:id])
  @repo = params[:id]
  erb :repo
end
