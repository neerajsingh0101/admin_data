var AdminData = AdminData || {};

AdminData.actOnResult = function(value) {
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
			AdminData.actOnResult.successCallback(json);
		}
	});
};

AdminData.actOnResult.successCallback = function(json) {
	$('#results').text(json.success);
};

$('#advance_search_delete_all').live('click', function() {
	if (AdminData.jsUtil.confirm('Are you sure?')) {
		AdminData.actOnResult('delete');
	}
	return false;
});

$('#advance_search_destroy_all').live('click', function() {
	if (AdminData.jsUtil.confirm('Are you sure?')) {
		AdminData.actOnResult('destroy');
	}
	return false;
});

