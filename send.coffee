request  = require 'request'
fs       = require 'fs'
encode 	 = require './lib/encode'
readline = require 'readline' 
qqinfo 	 = require './config.json'
QQ       = require './QQ/entity.coffee'



QQEntity = new QQ.QQEntity(qqinfo);
options = process.argv
if options.length != 3
	console.log "need input"
	process.exit 0

QQEntity.login ()->
	content = options[2]
	QQEntity.emotionPost content, ()->
		console.log "send"

	
