var Notifier = {

	start: function() {
		setTimeout(Notifier.check, 10000);
	},

	check: function (){
		var xmlrpc=null;
		try{
   			var xmlrpc = imprt("xmlrpc");
		}catch(e){
    			alert(e);
			throw "importing of xmlrpc module failed.";
		}

		var s = new xmlrpc.ServiceProxy("http://192.168.1.3/oap/notifier", ["check"]);
		
		var sessionid = Notifier.readCookie('OApSSO')
		if (sessionid)
		{
			try{
				var r = eval("s."+"check('session id', sessionid)");
			}catch(e){
        			
    			}
			if(r!=""){
				document.getElementById('pop').innerHTML = r;
				Notifier.show();
			}
		}

		setTimeout(Notifier.check, 10000);
	},

	show: function (){
		Effect.Appear(document.getElementById('pop'));
		setTimeout(Notifier.hide, 4000);
	},
	hide: function (){
		Effect.Fade(document.getElementById('pop'))
	},
	readCookie: function(name){
		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++)
		{
			var c = ca[i];
			while (c.charAt(0)==' ') c = c.substring(1,c.length);
			if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
		}
		return null;
	}
}
