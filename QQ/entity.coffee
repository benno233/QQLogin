request  = require 'request'
fs       = require 'fs'
encode 	 = require '../lib/encode'
gtk      = require '../lib/encode_g_tk'
readline = require 'readline' 
c               =  require '../cookie.json'
qqinfo 	 = require '../config.json'
J      = request.jar()

qqinfo.header = c.header
qqinfo.uri = c.uri


request  = request.defaults {jar:J}

if qqinfo.header.length > 0
	if qqinfo.header instanceof Array
		cookies = qqinfo.header.map (c) ->
			request.cookie(c)
	else
		cookies = request.cookie(qqinfo.header)

	for cookie in cookies 

		J.setCookie(cookie, qqinfo.uri)

Head = {
		'User-Agent' : "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36"
		'Content-Type' : "application/x-www-form-urlencoded"
		'RA-Sid':"D21E61BB-20140629-052631-608f42-564722"
		'RA-Ver':'2.4.10'
		'Cache-Control':'max-age=0'
		'Content-Type':'application/x-www-form-urlencoded'
	}

class QQ
	constructor:(qqinfo)->

		@login_sig = {}
		@code = {}
		#加密后的密码
		@skey = {}
		@ptz = {}
		@skey = ''
		{@qq,@password,@gtk,@header} = qqinfo

	emotionPost:(content,cb)->
		postUrl =  "http://taotao.qq.com/cgi-bin/emotion_cgi_publish_v6?g_tk=#{@gtk}&"
		#console.log "sending request to #{postUrl}"
		Head.Host = "taotao.qq.com"
		Head.Origin = "http://user.qzone.qq.com"
		Head.Referer = "http://user.qzone.qq.com/#{@qq}/311"
		form  = 
			syn_tweet_verson:1
			who:1
			con:content
			feedversion:1
			ver:1
			ugc_right:1
			to_tweet:0
			to_sign:0
			hostuin:@qq
			code_version:1
			format:"fs"
			qzreferrer:"http://user.qzone.qq.com/#{@qq}"
			
		post =
			url:postUrl
			headers:Head
			method:"POST"
			form:form
		that = @
		request post,(err,res,body)->
			console.log if err 
			loginR = /"message":"请先登录空间"/g
			feedR = /"feedinfo"/g

			if body.match feedR
				#err = "send too fast"
				#console.log body
				return cb(err,body)

			if body.match(loginR)
				qqinfo.header = []
				qqinfo.uri = []
				err  = "login first"
				console.log err
				return that.login ()->
					that.emotionPost content,cb
			else
				return cb(err,body)

	emotionDelete:(id,cb)->
		if @gtk is ''
			err = "login not inited."
			cb(err,null)
		else
			console.log "sending request to http://taotao.qq.com/cgi-bin/emotion_cgi_delete_v6?g_tk=#{@gtk}\n___"
			
			Head.Host = "taotao.qq.com"
			Head.Origin = "http://user.qzone.qq.com"
			Head.Referer = "http://user.qzone.qq.com/#{@qq}/311"

			post = 
				url : "http://taotao.qq.com/cgi-bin/emotion_cgi_delete_v6?g_tk=#{@gtk}"
				headers:Head
				method:'POST'
				form:
					qzreferrer:"http://user.qzone.qq.com/#{@qq}/311"
					hostuin:@qq
					tid:"47e497a34401f35390390a00"
					t1_source:1
					code_version:1
					format:'fs'

			request post,(err,res,body)->
					cb(err,body)

	like:(account,id,cb)->
		console.log "like #{account}'s #{id}"
		if @gtk is ''
			err = 'login not inited'
			cb(err,null)
		else
			#console.log "sending request to http://w.edu.qzone.qq.com/cgi-bin/likes/internal_dolike_app?g_tk=#{@gtk}"
			
			post = 
				url: "http://w.edu.qzone.qq.com/cgi-bin/likes/internal_dolike_app?g_tk=#{@gtk}"
				header:Head
				method:'POST'
				form:
					qzreferrer:"http://user.qzone.qq.com/#{@qq}/311"
					opuin:@qq
					unikey:"http://user.qzone.qq.com/#{account}/mood/#{id}"
					curkey:"http://user.qzone.qq.com/#{account}/mood/#{id}"
					from:-100
					fupdate:1
					face:0

			request post, (err,res,body)->
				cb(err,body)

	getEmotionIndexPage: (cb)->

			get = 
				url:"http://user.qzone.qq.com/#{@qq}/infocenter"
				header:Head
				method:'GET' 
			
			request get,(err,res,body)->
				#console.log body
				cb(err,body)


	login:(cb)->
		console.log "GTK is #{@gtk}\n"

		if qqinfo.header.length >0
			console.log "have logined"
			return cb()

		rl = readline.createInterface {
				input:process.stdin,
				output:process.stdout
		}
		#一些必要的头

		# #获取验证信息
		# captchaUrl= "http://check.ptlogin2.qq.com/check?regmaster=&uin=#{@qq}&appid=549000912&js_ver=10051&js_type=1&login_sig=#{@login_sig}&u1=http%3A%2F%2Fqzs.qq.com%2Fqzone%2Fv5%2Floginsucc.html%3Fpara%3Dizone&r=#{Math.random()}"

		# #获取验证码图片
		# captchaImage = "http://captcha.qq.com/getimage?uin=#{@qq}&aid=549000912&0.6652378559988166"

		#获取login_sig
		initUrl = "http://ui.ptlogin2.qq.com/cgi-bin/login?hide_title_bar=1&low_login=0&qlogin_auto_login=1&no_verifyimg=1&link_target=blank&appid=549000912&style=12&target=self&s_url=http%3A//qzs.qq.com/qzone/v5/loginsucc.html?para=izone&pt_qr_app=%CA%D6%BB%FAQQ%BF%D5%BC%E4&pt_qr_link=http%3A//z.qzone.com/download.html&self_regurl=http%3A//qzs.qq.com/qzone/v6/reg/index.html&pt_qr_help_link=http%3A//z.qzone.com/download.html"



		getInit = 
			url:initUrl
			method:'GET'
			headers:Head


		that = @

		console.log "Getting init data... sendding request to\n#{getInit.url}\n____________________"
		console.log "QQ is #{that.qq}"
		request getInit , (err,res,body)->
			login_sigR = new RegExp 'login_sig:"(.*?)",clientip','g'
			login_sigR.exec body

			that.login_sig = RegExp.$1

			#这两个参数好像自己是不用获取的
			aid = "549000912"
			verjs = "10051"
			console.log "sig is #{that.login_sig}"
			console.log "Finished!"

			#verify code
			captchaUrl= "http://check.ptlogin2.qq.com/check?regmaster=&uin=#{that.qq}&appid=549000912&js_ver=10051&js_type=1&login_sig=#{that.login_sig}&u1=http%3A%2F%2Fqzs.qq.com%2Fqzone%2Fv5%2Floginsucc.html%3Fpara%3Dizone&r=#{Math.random()}"
			captchaImage = "http://captcha.qq.com/getimage?uin=#{that.qq}&aid=549000912&0.6652378559988166"
			Head.Host = 'check.ptlogin2.qq.com'

			getcaptcha = 
				url:captchaUrl
				method:'GET'
				headers:Head

			console.log "Getting verifycode... sendding request to\n#{getcaptcha.url}\n____________________"

			request getcaptcha,(err,res,body)->
				Head.Host = null
				needVerifyPic = false
				verifyR =  new RegExp ',\'([^,]*)\',','g'
				verifyR.exec(body)
				that.code 	= RegExp.$1
				console.log "Finished ! QQ.code is #{that.code}\n"

				if that.code.indexOf('!') is -1 
					console.log 'Need verify picture'
					needVerifyPic = true

				

				if needVerifyPic 
					getcaptcha.url = captchaImage

					console.log "Downloading captcha image...."
					request(getcaptcha).pipe(fs.createWriteStream('captcha.JPEG'))

					rl.question 'Check out captcha get input it\n', (answer)->
						that.code = answer
						console.log "thanks! input is #{that.code}."
						rl.close()

						that.p = encode.P(that.qq,that.password,that.code)
						
						loginGet =   "http://ptlogin2.qq.com/login?u=#{that.qq}&p=#{that.p}&verifycode=#{that.code}&aid=549000912&u1=http%3A%2F%2Fqzs.qq.com%2Fqzone%2Fv5%2Floginsucc.html%3Fpara%3Dizone&h=1&ptredirect=0&ptlang=2052&from_ui=1&dumy=&low_login_enable=0&regmaster=&fp=loginerroralert&action=10-33-1383187964077&mibao_css=&t=1&g=1&js_ver=10091&js_type=1&login_sig=#{that.login_sig}&pt_rsa=0"
						Head.Host = 'ptlogin2.qq.com'
						loginRequest = 
							url:loginGet
							headers:Head
							method:'GET'
						console.log "Logining... sendding request to\n#{loginRequest.url}\n____________________"
						request loginRequest , (err,res,body)->
							#console.log loginGet
							# ptuiCB('4','0','','0','您输入的验证码不正确，请重新输入。', '2905260776');
							# ptuiCB('0','0','http://qzs.qq.com/qzone/v5/loginsucc.html?para=izone','0','登录成功！', 'SSDUT学生周知');
							#console.log res.headers

							if body 
								codeR =  /ptuiCB\('(\d)',/g
								codeR.exec(body)
								code = RegExp.$1
								#console.log code
								if code != "0"
									console.log "login fail!"
									process.exit()
								else
									console.log "login success!"

							#console.log res
							cookies = J.getCookies(loginGet)
							cookieString = J.getCookieString(loginGet)
							# console.log cookieString
							# qqinfo.cookie = cookieString
							c.header = res.headers["set-cookie"]
							c.uri  = loginGet
							#这些是必要的cookie
							for cookie in cookies
								if cookie.key is 'skey'
						 			that.skey = cookie.value
								#console.log cookie


							that.gtk = gtk.getGTK(that.skey)
							qqinfo.gtk = that.gtk
							#qqinfo.jar = J
							fs.writeFile './cookie.json',JSON.stringify(c),()->
								fs.writeFile('./config.json',JSON.stringify(qqinfo),cb)
							# console.log cookies
							# skey = cookies.skey
							# ptcz = cookies.ptcz
							# uin  = "o0"+that.qq
							# console.log skey,ptcz,uin
							# console.log "\n\n"
							# console.log body
							
				else
					console.log 'Need no captcha'

					that.p = encode.P(that.qq,that.password,that.code)
					loginGet =  "http://ptlogin2.qq.com/login?u=#{that.qq}&p=#{that.p}&verifycode=#{that.code}&aid=549000912&u1=http%3A%2F%2Fqzs.qq.com%2Fqzone%2Fv5%2Floginsucc.html%3Fpara%3Dizone&h=1&ptredirect=0&ptlang=2052&from_ui=1&dumy=&low_login_enable=0&regmaster=&fp=loginerroralert&action=10-33-1383187964077&mibao_css=&t=1&g=1&js_ver=10091&js_type=1&login_sig=#{that.login_sig}&pt_rsa=0"
						
					Head.Host = 'ptlogin2.qq.com'
					loginRequest = 
						url:loginGet
						headers:Head
						method:'GET'

					console.log "Logining... sendding request to\n#{loginRequest.url}\n____________________"
					request loginRequest , (err,res,body)->
						cookies = J.getCookies(loginGet)
						cookieString = J.getCookieString(loginGet)
						#这些是必要的cookie
						# console.log cookieString
						# qqinfo.cookie = cookieString
						c = {}
						c.header = res.headers["set-cookie"]
						c.uri = loginGet
						qqinfo.header = res.headers["set-cookie"]
						for cookie in cookies
							if cookie.key is 'skey'
					 			that.skey = cookie.value
							#console.log(cookie)


						# console.log skey,ptcz,uin
						#skey 用来生成GTK
						that.gtk = gtk.getGTK(that.skey)
						qqinfo.gtk = that.gtk
						#qqinfo.jar = J
						fs.writeFile './cookie.json',JSON.stringify(c),()->
							fs.writeFile('./config.json',JSON.stringify(qqinfo),cb)

exports.QQEntity = QQ
