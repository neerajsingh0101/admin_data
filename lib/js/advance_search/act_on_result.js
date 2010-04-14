var AdminData = AdminData || {};

AdminData.actOnResult = {

	action: function(action_type) {
		var formData = $('#advance_search_form').data('admin_data_form_array'),
		parameterizedData;

		formData.push({
			'name': 'admin_data_advance_search_action_type',
			'value': action_type
		});

		parameterizedData = $.param(formData);

		$.ajax({
			url: $('#advance_search_form').attr('action'),
			type: 'post',
			dataType: 'json',
			data: parameterizedData,
			success: function(json) {
				AdminData.actOnResult.successCallback(json);
			}
		});
	},

	successCallback: function(json) {
		$('#results').text(json.success);
	}

};

$('#advance_search_delete_all').live('click', function() {
	if (AdminData.jsUtil.confirm('Are you sure?')) {
		AdminData.actOnResult.action('delete');
	}
	return false;
});

$('#advance_search_destroy_all').live('click', function() {
	if (AdminData.jsUtil.confirm('Are you sure?')) {
		AdminData.actOnResult.action('destroy');
	}
	return false;
});

