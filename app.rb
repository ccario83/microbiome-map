#!/usr/bin/env ruby

# Application
class App < Sinatra::Base
    
    # To handle coffee script
    get "/js/*.js" do
        coffee "coffee/#{params[:splat].first}".to_sym
    end
    
    # To handle sass
    get '/css/*.css' do
        sass "sass/#{params[:splat].first}".to_sym
    end
    
    # Route Handlers
    get '/' do
        redirect '/map/diabetictestAnmeanCHRR.tab'
    end

    get '/map/*.tab' do
        @files = Dir.glob(File.join(settings.root, "data/", "*"))
        @files.map!{|file| File.basename(file, ".*")}
        @datafile = "/data/#{params[:splat].first}.tab"
        annotation = JSON.parse(File.read("views/json/dataset_metadata.json"))

        file = params[:splat].first+'.tab'
        @description = annotation[1][file]['Description']
        slim :"slim/map"
    end

    # 4 OH 4
    not_found do
        slim :"slim/404"
    end

    # The county map
    get '/json/*.json' do
        content_type :json
        File.read("views/json/#{params[:splat].first}.json")
    end

    # To handle data
    get '/data/*.tab' do
        File.read("data/#{params[:splat].first}.tab")
    end

end
