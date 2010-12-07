var AdminData = AdminData || {};

AdminData.ajaxifyAdvanceSearch = {
	successCallback: function(responseText) {
		$('#results').html(responseText);
	},

	beforeSubmitCallback: function(formArray, jqForm) {
		$('#results').html('<span class="searching_message">searching...</span>');
		$('#advance_search_form').data('admin_data_form_array', formArray);
	}
};

$(function() {

	var options = {
		success: function(responseText) {
			AdminData.ajaxifyAdvanceSearch.successCallback(responseText);
		},
		beforeSubmit: function(formArray, jqForm) {
			AdminData.ajaxifyAdvanceSearch.beforeSubmitCallback(formArray, jqForm);
		}
	};

	$('#advance_search_form').ajaxForm(options);

});

