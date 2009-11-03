jQuery(document).ready(function($) {
	return function($) {
		var table_structure_data_non_json = $('#admin_data_table_structure_data').html();
		var table_structure_data_json = eval(table_structure_data_non_json);
		var table_structure = table_structure_data_json[0];

		AdminDataAdvanceSearch.init(table_structure);

		$.ajaxSetup({
			'beforeSend': function(xhr) {
				xhr.setRequestHeader("Accept", "text/javascript");
			}
		});

		var options = {
			success: function(responseText) {
				AdminDataAdvanceSearch.updatePageWithSearchResult(responseText);
			},
			beforeSubmit: function() {
				$('#results').html('<span class="searching_message">searching ...</span>');
			}
		};

		$('#advance_search_form').ajaxForm(options);

	};
} (jQuery));

