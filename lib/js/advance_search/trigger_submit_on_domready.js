$(function() {

	$('#advance_search_table a.add_row_link').live('click', function() {
		$('#advance_search_table').append(AdminDataAdvanceSearch.buildRow(AdminDataJSUtil.random_number()));
		return false;
	});

	$('#advance_search_table a.remove_row').live('click', function(e) {
		$(e.target).closest('tr').remove();
		return false;
	});

	$('select.col1').live('change', function() {
    log('changed');
		var $col1 = $(e.target).closest('select');
		var columnType = AdminDataAdvanceSearch.ts[$col1.val()];
		$col2 = $col1.parent('tr').find('td select.col2');
    log($col2);
		$col2.html('');
		var options = AdminDataAdvanceSearchStructure[columnType]['options'];
		AdminDataAdvanceSearch.buildOptionsFromArray(options, $col2);
		//trigger  change
		$col2.trigger('change');
	});

	$('#advance_search_form').trigger('submit');

});

