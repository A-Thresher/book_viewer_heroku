require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @toc = File.readlines("data/toc.txt")
end

get "/" do
  @title = 'The Adventures of Sherlock Holmes'

  erb :home
end

get "/chapters/:number" do
  chp_number = params[:number].to_i

  redirect "/" unless (1..@toc.size).cover?(chp_number)

  @title = "Chapter #{chp_number}: #{@toc[chp_number - 1]}"
  @chapter = File.read("data/chp#{chp_number}.txt")

  erb :chapter
end

get "/search" do
  @search_term = params[:query]

  @files = search(@search_term) if @search_term && @search_term != ''

  erb :search
end

# get "/show/:name" do
#   params[:name]
# end

not_found do
  redirect "/"
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |para, idx|
      "<p id='#{idx}'>#{para}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, "<strong>#{term}</strong>")
  end
end

def search(term)
    files = Dir['./data/*'].each_with_object([]) do |file, memo|
      number = file.gsub(/[^\d]/, '').to_i
      title = @toc[number - 1]
      paragraphs = File.read(file)
                       .split("\n\n")
                       .map.with_index { |para, idx| [idx, para] }
                       .select { |idx, para| para.include?(term)}

      memo << { number: number, title: title, paragraphs: paragraphs }
    end

    files.select { |el| !el[:paragraphs].empty? }.sort_by { |el| el[:number] }
end
