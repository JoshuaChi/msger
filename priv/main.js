var session = (function() {
	name: undefined,
	log: function(m) {
      $('#output').append($("<code>").text(m));
      $('#output').append($("<br>"));
      $('#output').scrollTop($('#output').scrollTop()+10000);
  },
	onOpen: function() {
		
	},
	onMessage: function() {
		
	},
	onClose: function() {
		
	}
	
})();