request  = require 'request'
fs       = require 'fs'
encode 	 = require '../lib/encode'
readline = require 'readline' 
qqinfo 	 = require '../config.json'

request  = request.defaults {jar: true}

class QQ
	constructor:(qqinfo)->

		@login_sig = {}
		@code = {}
		#加密后的密码
		@p = ''
		{@qq,@password} = qqinfo

	login:->
		rl = readline.createInterface {
				input:process.stdin,
				output:process.stdout
		}
		#一些必要的头

		Head = 
			'User-Agent' : 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'
			'Content-Type' : 'application/x-www-form-urlencoded'
			'RA-Sid':'D21E61BB-20140629-052631-608f42-564722'
			'RA-Ver':'2.4.10'
			
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

		console.log "Getting init data... sendding request to \n #{getInit.url}\n____________________"
		console.log "QQ is #{that.qq}"
		request getInit , (err,res,body)->
			login_sigR = new RegExp 'login_sig:"(.*?)",clientip','g'
			login_sigR.exec body

			that.login_sig = RegExp.$1
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

			console.log "Getting verifycode... sendding request to \n #{getcaptcha.url}\n____________________"

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
						code = answer
						console.log "thanks! input is #{that.code}."
						rl.close()

						that.p = encode.P(that.qq,that.password,that.code)
						
						loginGet =   "http://ptlogin2.qq.com/login?u=#{that.qq}&p=#{that.p}&verifycode=#{that.code}&aid=549000912&u1=http%3A%2F%2Fqzs.qq.com%2Fqzone%2Fv5%2Floginsucc.html%3Fpara%3Dizone&h=1&ptredirect=0&ptlang=2052&from_ui=1&dumy=&low_login_enable=0&regmaster=&fp=loginerroralert&action=10-33-1383187964077&mibao_css=&t=1&g=1&js_ver=10091&js_type=1&login_sig=#{that.login_sig}&pt_rsa=0"
						Head.Host = 'ptlogin2.qq.com'
						loginRequest = 
							url:loginGet
							headers:Head
							method:'GET'
						console.log "Logining... sendding request to \n #{loginRequest.url}\n____________________"
						request loginRequest , (err,res,body)->
							#console.log loginGet
							#console.log res.headers
							console.log "\n\n"
							console.log body

				else
					console.log 'Need no captcha'

					that.p = encode.P(that.qq,that.password,that.code)
					loginGet = "http://ptlogin2.qq.com/login?u=#{that.qq}&verifycode=#{that.code}&pt_vcode_v1=0&pt_verifysession_v1=h01459340307056a706c16be0cc01cf271a90209d251d994563b6d915b894ddcf6c605f73f1c5dad5127e228ada1bf29b63&p=#{that.p}&pt_rsa=0&u1=http%3A%2F%2Fqzs.qq.com%2Fqzone%2Fv5%2Floginsucc.html%3Fpara%3Dizone&ptredirect=0&h=1&t=1&g=1&from_ui=1&ptlang=2052&action=5-50-1408377343482&js_ver=10090&js_type=1&login_sig=#{that.login_sig}&pt_uistyle=32&aid=549000912&daid=5&pt_qzone_sig=1&"
					Head.Host = 'ptlogin2.qq.com'
					loginRequest = 
						url:loginGet
						headers:Head
						method:'GET'

					console.log "Logining... sendding request to \n #{loginRequest.url}\n____________________"
					request loginRequest , (err,res,body)->
						console.log body


exports.QQEntity = QQ