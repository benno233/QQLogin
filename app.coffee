request  = require 'request'
fs       = require 'fs'
encode 	 = require './lib/encode'
readline = require 'readline' 
qqinfo 	 = require './config.json'
QQ       = require './QQ/entity.coffee'



QQEntity = new QQ.QQEntity(qqinfo);
id = 0
host = "http://115.28.2.165:8000/"
# #console.log QQEntity.qq
# fresh = ()->
# 	QQEntity.getEmotionIndexPage (err,body)->
# 		console.log "Like Monster GO!"
# 		#console.log body
# 		matches = body.match /data-curkey="http:\/\/user.qzone.qq.com\/\d*?\/mood\/(.*?)"/g
# 		#console.log matches
# 		#idR = new RegExp('data-curkey="http:\/\/user.qzone.qq.com\/\d*?\/mood\/(.*?)"','g')
# 		if matches 	
# 			for match in matches 
# 				mts = match.match /data-curkey="http:\/\/user.qzone.qq.com\/(\d*?)\/mood\/(.*?)"/
# 				if mts 
# 					qq = mts[1]
# 					id = mts[2]
# 					QQEntity.like qq,id, (err,body)->
# 						console.log err if err


getNews = () ->
  	
	request {url:host+"latest"},(err,res,body)->
		news = JSON.parse body
		content = "News:#{news.title} Link:http://ssdut.dlut.edu.cn#{news.link}"
		if id != news.id
			console.log   "source is #{news.source}" 
			QQEntity.emotionPost content, (err,body)->
				console.log "post #{news.id}:\n #{content}"
			id = news.id

QQEntity.login ()->

	setInterval getNews,1000*2



