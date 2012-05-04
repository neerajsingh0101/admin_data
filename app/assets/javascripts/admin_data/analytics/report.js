$(function(){

	$('input[name=report_type]').change(function(){
		window.location = $(this).val();
	});

});
