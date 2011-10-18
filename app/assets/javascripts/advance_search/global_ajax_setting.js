$(function() {

	$.ajaxSetup({
		'beforeSend': function(xhr) {
			xhr.setRequestHeader("Accept", "text/javascript");
		}
	});

});

