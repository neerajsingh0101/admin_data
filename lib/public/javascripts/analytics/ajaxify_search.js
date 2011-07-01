var AdminData = AdminData || {};

AdminData.ajaxifyAdvanceSearch = {
	successCallback: function(responseText) {
						 eval(responseText);
		$('#submit_search').val('Build Chart');
		drawChart();
	},

	beforeSubmitCallback: function(formArray, jqForm) {
		$('#submit_search').val('Building chart .....');
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

	$('#build_search_analytics_form').ajaxForm(options);

});
