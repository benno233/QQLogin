request  = require 'request'
fs       = require 'fs'
encode 	 = require './lib/encode'
readline = require 'readline' 
qqinfo 	 = require './config.json'
QQ       = require './QQ/entity.coffee'



QQEntity = new QQ.QQEntity(qqinfo);

#console.log QQEntity.qq

QQEntity.login ()->
	console.log "Login Ok!"
	# QQEntity.emotionDelte 1, (err,body)->
	# 	console.log "delte"
	fresh = ()->
		QQEntity.getEmotionIndexPage (err,body)->
			console.log "Like Monster GO!"
			#console.log body
			matches = body.match /data-curkey="http:\/\/user.qzone.qq.com\/\d*?\/mood\/(.*?)"/g
			#idR = new RegExp('data-curkey="http:\/\/user.qzone.qq.com\/\d*?\/mood\/(.*?)"','g')
			for match in matches 
				mts = match.match /data-curkey="http:\/\/user.qzone.qq.com\/(\d*?)\/mood\/(.*?)"/
				qq = mts[1]
				id = mts[2]
				QQEntity.like qq,id, (err,body)->
					console.log err if err

	setInterval fresh,1000*3




