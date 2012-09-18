%w[sinatra dm-core dm-migrations slim sass].each{ |lib| require lib }

#DataMapper.setup(:default, ENV['DATABASE_URL'] || File.join("sqlite  ://",settings.root,"dev.db"))
#'postgres://asqd117@gmail.com:ee2mc9fnbm9p@heroku.com/data/dev.db')

class Character
	include DataMapper::Resource

	property :id, Serial
	property :first, Integer, :default => proc { |m,p| 1+rand(8) }
	property :second, Integer, :default => proc { |m,p| 1+rand(8) }
	property :third, Integer, :default => proc { |m,p| 1+rand(8) }

end

DataMapper.finalize

### Routes for our awesome app ###

#get('/application.js') { content_type 'text/javascript' ; render :str, :javascript, :layout => false }
get '/stylesheets/:name.css' do
	content_type 'text/css', :charset => 'utf-8'
	scss(:"#{params[:name]}")
end

get '/' do 
	@characters = Character.all
	slim :index
end

post '/create/character' do
	character = Character.create

	if request.xhr?
		slim :character, { :layout => false, :locals => { :character => character } }
	else
		redirect to('/')
	end
end

delete '/delete/character/:id' do
	Character.get(params[:id]).destroy
	redirect to('/') unless request.xhr?
end

__END__

@@layout
doctype html
html
  head
  meta charset="utf-8"
  title Cutie Creator
  script src="http://cdn.rightjs.org/right.js"
  script src="/application.js"

  link rel="shortcut icon" href="/fav.ico"
  link href="http://fonts.googleapis.com/css?family=Megrim|Ubuntu&v2" rel='stylesheet'
  link rel="stylesheet" media="screen, projection" href="styles.css"
  /[if lt IE 9]
    script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"
  body
    == yield
    footer role="contentinfo"
      p Creating Character teams since 2012

@@index
h1 Cutie Creator
form.build action="/create/character" method="POST"
  input.button type="submit" value="Create a team of your dream!"
-if @characters.any?
  ul#characters
    - @characters.each do |character|
      ==slim :character, :locals => { :character => character }
- else
  h2 Feel lucky, create a firs team!

@@character
li.character
  img src="/character_0#{character.first}.gif"
  img src="/character_0#{character.second}.gif"
  img src="/character_0#{character.third}.gif"
  form.destroy action="/delete/character/#{character.id}" method="POST"
    input type="hidden" name="_method" value="DELETE"
    input type="submit" value="!"

@@styles
html,body,div,span,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote, pre,abbr,address,cite,code,del,dfn,em,img,ins,kbd,q,samp,small,strong,sub,sup,var,b,i,dl,dt, dd,ol,ul,li,fieldset,form,label,legend,table,caption,tbody,tfoot,thead,tr,th,td,article, aside, canvas, details,figcaption,figure,footer,header,hgroup,menu,nav,section, summary,time,mark,audio,video{margin:0;padding:0;border:0;outline:0;font-size:100%;vertical-align:baseline;background:transparent;line-height:1;}

body{font-family:ubuntu,sans;}

footer{display:block;margin-top:20px;border-top:3px solid #4b947d;padding:10px;}

h1{color:#95524C;margin:5px 40px;font-size:72px;font-weight:bold;font-family:Georgia,sans;}
.button{
  background:#4b7194;color:#fff;
  text-transform:uppercase;
  border-radius:6px;border:none;
  font-weight:bold;font-size:16px;
  padding: 6px 12px;margin-left:40px;
  cursor:pointer;
  &:hover{background:#54A0E7;}}
  
#characters{list-style:none;overflow:hidden;margin:20px;}

.character{
  float:left;
  width:375px;padding:10px 10px;border:dashed #4b7194; border-width:0px 1px 1px 0px;
  position:relative;
  
  form{display:none;position:absolute;top:0;right:0;}
  &:hover form{display:block;}

  form input{background:rgba(#000,0.7);padding:0 4px;color:white;cursor:pointer; font-size:32px;font-weight:bold;text-decoration:none;border-radius:16px;line-height:0.8;border:none; }
  

  img{display:block;padding:0 0px; float:left;} }

@@javascript
"form.destroy".onSubmit(function(event) {
	this.parent().fade();
	event.stop();
	this.send();
});

"form.build".onSubmit(function(event) {
	event.stop();
	this.send({
		onSuccess: function(xhr){
			$('characters').insert(xhr.responseText);
		}
		});

	});

