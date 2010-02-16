//TODO write test 
$(function() {

	$.ajaxSetup({
		'beforeSend': function(xhr) {
			xhr.setRequestHeader("Accept", "text/javascript");
		}
	});

	var options = {
		success: function(responseText) {
			$('#results').html(responseText);
		},
		beforeSubmit: function(formArray, jqForm) {
			$('#results').html('<span class="searching_message">searching ...</span>');
			$('#advance_search_form').data('admin_data_form_array', formArray);
		}
	};

	$('#advance_search_form').ajaxForm(options);

});

