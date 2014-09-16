request  = require 'request'
fs       = require 'fs'
encode 	 = require './lib/encode'
readline = require 'readline' 
qqinfo 	 = require './config.json'
QQ       = require './QQ/entity.coffee'



QQEntity = new QQ.QQEntity(qqinfo);
id = 0
init = true
fetch = true

host = "http://115.28.2.165:8000/"
# #console.log QQEntity.qq

globalNew = []

getNews = (cb) ->

	#console.log "get news"
	request {url:host+"latest"},(err,res,body)->
		news = JSON.parse body
		
		if init
			
			request {url:host+"date/"+qqinfo.lastTime+"/"+news.date},(err,res,body) ->
				console.log host+qqinfo.lastTime+"/"+news.date
				init = false
				newsArr = JSON.parse body
				for news in  newsArr
					globalNew.push news

		else	
			
			if fetch and  id != news.id
				console.log "get new  news" , news.id
				#Critical Section	
				fetch = false
				tmpId = qqinfo.lastId
				request {url:host+"id/"+tmpId+"-"+news.id},(err,res,body)->
					console.log host+"id/"+tmpId+"-"+news.id
					newsArr = JSON.parse body
					count = 0
					console.log "--"
					for news in  newsArr
						console.log news.id
						globalNew.push news
					console.log "--"

					if newsArr.length > 0
						id = newsArr[0].id
					fetch = true
			else
				#console.log "id #{id} i== news.id #{news.id},no new news"

						
sendNews = () ->

		news = globalNew.pop()
		if news
			console.log "send news"
			content = "News:#{news.title} Link:http://ssdut.dlut.edu.cn#{news.link}"
			console.log "post #{news.id}:\n#{content}"
			QQEntity.emotionPost content,(err,body)->
				if err 
					console.log err
					return 
				id = news.id
				qqinfo.lastTime = news.date
				qqinfo.lastId = news.id
				fs.writeFile './config.json',JSON.stringify(qqinfo),(err)->
					fetch = true
					console.log err if err
					console.log 'time saved!'
		else
			cosole.log "no new to send"

QQEntity.login ()->
	setInterval getNews,1000*2

	setInterval sendNews , 1000*60*30 
	