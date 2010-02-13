$('#advance_search_table a.add_row_link').live('click', function() {
	$('#advance_search_table').append(AdminDataAdvanceSearch.buildRow(AdminDataJSUtil.random_number()));
	return false;
});

$('#advance_search_table a.remove_row').live('click', function(e) {
	$(e.target).closest('tr').remove();
	return false;
});

$('#advance_search_table select.col1').live('change', function(e) {
	var $col1 = $(e.target).closest('select');
	var columnType = AdminDataAdvanceSearch.ts[$col1.val()];
	$col2 = $col1.parents('tr').find('td select.col2');
	$col2.html('');
	var options = AdminDataAdvanceSearchStructure[columnType]['options'];
	AdminDataAdvanceSearch.buildOptionsFromArray(options, $col2);
	$col2.trigger('change');
});

$('#advance_search_table select.col2').live('change', function(e) {
	var $col2 = $(e.target).closest('select');
	var value = $col2.val();
	var columnType = AdminDataAdvanceSearch.ts[$col2.val()];
	$col3 = $col2.parents('tr').find('td input.col3');
	$col1 = $col2.parents('tr').find('td select.col1');
	var col1ColumnType = AdminDataAdvanceSearch.ts[$col1.val()];

	var arrayList = ['is_false', 'is_true', 'is_null', 'is_not_null'];
	if (value.length === 0 || ($.inArray(value, arrayList) > -1)) {
		$col3.val('').attr('disabled', true).addClass('disabled');
	} else {
		$col3.attr('disabled', false).removeClass('disabled');
		if (col1ColumnType === 'datetime' || col1ColumnType === 'date') {
			$col3.val(AdminDataJSUtil.dateToString(new Date())).addClass('datepicker');
			$('.datepicker').datepicker({
				dateFormat: 'dd-MM-yy',
				changeYear: true,
				changeMonth: true
			});
		} else {
			$('.datepicker').datepicker('destroy');
			$col3.removeClass('datepicker').focus(); // do not create focus for date pickers
		}
	}

});

