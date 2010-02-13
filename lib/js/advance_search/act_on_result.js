var advance_search_action_func = function(value) {
	var formData = $('#advance_search_form').data('admin_data_form_array');
	formData.push({
		'name': 'admin_data_advance_search_action_type',
		'value': value
	});
	var parameterizedData = $.param(formData);
	$.ajax({
		url: $('#advance_search_form').attr('action'),
		type: 'post',
		dataType: 'json',
		data: parameterizedData,
		success: function(json) {
			$('#results').text(json.success);
		}
	});
};

$('#advance_search_delete_all').live('click', function() {
	if (confirm('Are you sure?')) {
		advance_search_action_func('delete');
	}
	return false;
});

$('#advance_search_destroy_all').live('click', function() {
	if (confirm('Are you sure?')) {
		advance_search_action_func('destroy');
	}
	return false;
});

