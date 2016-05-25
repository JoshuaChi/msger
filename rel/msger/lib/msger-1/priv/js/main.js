var main = (function() {
	return {
		userName: undefined,
    sockjs : undefined,
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
		
		join: function(name) {
			this.sockjs = new SockJS(
				'/connect', 
				null, 
				{
					sessionId : function() {
						return name;
					}
				}
			);
	    
			this.sockjs.onopen = function() {
	        main.log(' [ * ] Connected (using: ' + this.transport + ')');
	    };
	    this.sockjs.onclose = function(e) {
	        main.log(' [ * ] Disconnected ('+e.status + ' ' + e.reason+ ')');
	    };
	    this.sockjs.onmessage = function(e) {
				  var obj = $.parseJSON(e.data);
	        main.log(' [ '+ obj.user + "/" +obj.resource +' ] saying: ' + JSON.stringify(obj.data));
	    };
			
		}		
	}
})();