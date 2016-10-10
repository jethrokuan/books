require 'rubygems'
require 'nokogiri'
require 'erb'
require 'date'

INITIAL_FILE_URL = "books.html"
FILE_URL = "index.html"

books_arr = []

Book = Struct.new(:title, :status, :tag)

page = Nokogiri::HTML(File.open(INITIAL_FILE_URL))

page.css('.outline-2 > h2').each do |b| 
  status = b.css('span.todo, span.done').text 
  tag = b.css('span.tag').text
  book = b.css('> text()').text.strip.gsub("\u00A0", "")
  books_arr << Book.new(book, status, tag)
end

def gen_books(books, status, arr)
  books.select{|b| b.status == status}.sort{|b1,b2| b1.title <=> b2.title}.each do |book| 
    arr.push(book)
  end
end

toread_arr = []
next_arr = []
done_arr = []

gen_books(books_arr,"TO-READ", toread_arr)
gen_books(books_arr,"NEXT", next_arr)
gen_books(books_arr,"DONE", done_arr)

current_time = DateTime.now
timestr = current_time.strftime "%d/%m/%Y"

template = ERB.new File.new("./books.html.erb").read
b = binding
b.local_variable_set(:toreadarr, toread_arr)
b.local_variable_set(:nextarr, next_arr)
b.local_variable_set(:donearr, done_arr)
b.local_variable_set(:datestr, timestr)

File.open(FILE_URL,'w') { |file| 
  file.write(template.result(b))
}
