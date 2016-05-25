var main = (function() {
	return {
		userName: undefined,
    sockjs : new SockJS('/connect'),
		getState: function() {
			return this.sockjs.readyState;
		},
		send: function(msg) {
			this.sockjs.send(msg);
		},
		log: function(m) {
	      $('#output').append($("<code>").text(m));
	      $('#output').append($("<br>"));
	      $('#output').scrollTop($('#output').scrollTop()+10000);
	  },
		init: function() {  
	    this.sockjs.onopen = function() {
	        main.log(' [ * ] Connected (using: ' + this.protocol + ')');
					main.userName = 'User-' + Math.floor((Math.random() * 100) + 1);
	    };
	    this.sockjs.onclose = function(e) {
	        main.log(' [ * ] Disconnected ('+e.status + ' ' + e.reason+ ')');
	    };
	    this.sockjs.onmessage = function(e) {
	        main.log(' [ '+ main.userName +' ] received: ' + JSON.stringify(e.data));
	    };
		}		
	}
})();
main.init();