fx_version 'bodacious'
game 'gta5'

ui_page "hud.html"

files {
	"hud.html",
	"hud.js",
	"hud.css",
	"fonts/Rubik-Regular.ttf",
	"fonts/Rubik-Bold.ttf",
	"fonts/Rubik-Black.ttf",
	"fonts/Rubik-Medium.ttf",
	"fonts/Rubik-SemiBold.ttf",
	"fonts/Rubik-Light.ttf",
	"fonts.css",
	"images/*.png"
}

client_scripts {
	'client.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	"@malteBase/server.lua",
	'server.lua'
}