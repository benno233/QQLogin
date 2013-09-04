var request = require('request'),
   readline = require('readline'),
    gm      = require('gm');

var qqinfo = {
    loginType:2,//1：不登录 2：隐身登录 3：在线登录
    qq:18840866963,//qq号
    pwd:'gaopeng19931001'//qq密码
};

var Vdata ={
	sid:''
};
var userAgend = 'Mozilla/5.0 (Linux; U; Android 3.0; en-us; Xoom Build/HRI39) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13';
var PostHead = {'User-Agent' : userAgend , 'Content-Type' : 'application/x-www-form-urlencoded'};
var address  = 'http://pt.3g.qq.com/handleLogin';
var Post = {
			url:address,
			headers:PostHead,
			method:'POST',
			form:qqinfo
			};
var Friends = [];
request(Post,function(err,res,body){
	if(res.statusCode == 302){
		var reg = new RegExp('sid=(.[^&]+)','ig');
		//console.log(res.headers.location);
		reg.exec(res.headers.location);
		var  sid = RegExp.$1
		Vdata.sid = sid;
		//console.log(sid);
		console.log('login!');
		getFriendsPage(1,function(){
			console.log('\nonline friends:'+Friends.length+'\n');
			for(var i = 0 ;i<Friends.length;i++){
				var qqInfo = Friends[i];
				console.log(i+1+':'+qqInfo.qq+' '+'\t['+qqInfo.name+']');
			};
			setRl();
		});
		return;
	}
	if(res.body.indexOf('验证码')>=0){
		console.log('需要输入验证码');
		return;
	}
});

function getFriendsPage(page,cb) {
	Friends =[];
	var chatMain = 'http://q16.3g.qq.com/g/s?sid=$SID&aid=nqqchatMain&p=$Page';
	    chatMain = chatMain.replace('$SID',Vdata.sid);
    	chatMain = chatMain.replace('$Page',page);
    request({url:chatMain,headers:{'User-Agent':userAgend,'Cache-Control':'max-age=0'},method:'GET'},function(err,res,body){
    	var regx = /u=(\d+)[\s\S]+?class="name" >(.*?)<\/span>/ig
    	while(regx.exec(body)){
    		var qqInfo = {qq:RegExp.$1,name:RegExp.$2};
    		Friends.push(qqInfo);
    	};
    	return cb;
    });
};

function sendmsg(index,msg){
	var qqInfo = Friends[index-1];
	var form ={
		'u':qqInfo.qq,
		'msg':msg,
		'aid':'发送'
	}
	if(!qqInfo) return false;
	var pUrl = 'http://q32.3g.qq.com/g/s?sid=$SID';
	pUrl = pUrl.replace('$SID',Vdata.sid);
	request({url:pUrl,form:form,headers:{'User-Agent':userAgend,'Cache-Control':'max-age=0','Content-Type': 'application/x-www-form-urlencoded'},method:'POST'},function(err,res,body){
		if(body.indexOf('重新登录')>=0 && body.indexOf('书签可能有误')>=0){
            console.log('发送失败');
            return false;
        }
	});
	return true;
}
var rl;
function setRl(){
	if(rl)return;
	rl = readline.createInterface(process.stdin,process.stdout,null);
	rl
	.on('line',function(cmd){
		switch(cmd.trim()){
			case '?':
				console.log(['命令列表：',
						     'q:quit',
						     'o:online friends',
						     's [No] [content]:sendmsg'
							].join('\n'));
				break;
			case 'o':
				getFriendsPage(1,function(){
					console.log('\nonline friends:'+Friends.length+'\n');
					for(var i = 0 ;i<Friends.length;i++){
						var qqInfo = Friends[i];
						console.log(i+1+':'+qqInfo.qq+' '+'\t['+qqInfo.name+']');
					};
				});
				break;
			case 'q':
				rl.close();
				console.log('quit!');
				process.exit(0);
				break;
			default:
		          var regexp = new RegExp('s +(\\d+) +?(.+)','ig');
		          if(regexp.exec(cmd)){
		              if(sendmsg(RegExp.$1,RegExp.$2)){
		              	return ;
		              }
		          }
				  console.log('Do Not Understand.\n');
				  break;
		};
		rl.prompt();
	})
	.on('close',function(){
		console.log('bye!');
		process.exit(0);
	});
	console.log('Type ? for help\n>');
	rl.setPrompt('>');
}
