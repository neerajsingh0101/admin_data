var AdminData = AdminData || {};

AdminData.bindings = {
	col2_change: function(e) {
		var arrayList = ['is_false', 'is_true', 'is_null', 'is_not_null'],
		$col2 = $(e.target).closest('select'),
		value = $col2.val(),
		tableStructure = $('#advance_search_table').data('table_structure'),
		columnType = tableStructure[$col2.val()],
		col1ColumnType;

		$col3 = $col2.parents('tr').find('td input.col3');
		$col1 = $col2.parents('tr').find('td select.col1');
		col1ColumnType = tableStructure[$col1.val()];

		if (value.length === 0 || ($.inArray(value, arrayList) > - 1)) {
			 $col3.val('')
            .attr('disabled', true)
            .addClass('disabled');

		} else {
			$col3.attr('disabled', false)
           .removeClass('disabled');

			if (col1ColumnType === 'datetime' || col1ColumnType === 'date') {
				$col3.val(AdminData.jsUtil.dateToString(new Date())).addClass('datepicker');
				
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
	},

	pagination_click: function(e) {
		var href = $(e.target).closest('a').attr('href');

		// usage of #results twice seems redundant
		$('#results').load(href, function(responseText) {
			$('#results').html(responseText);
		});

		AdminData.jsUtil.colorizeRows();
	},

	col1_change: function(e) {
		var $col1 = $(e.target).closest('select'),
		tableStructure = $('#advance_search_table').data('table_structure'),
		columnType = tableStructure[$col1.val()],
		options = AdminData.mappings[columnType]['options'];

		$col2 = $col1.parents('tr').find('td select.col2');
		$col2.html('');
		AdminData.jsUtil.buildOptionsFromArray(options, $col2);
		$col2.trigger('change');
	}
};

$('.pagination a').live('click', function(e) {
	AdminData.bindings.pagination_click(e);
	return false;
});

$('#advance_search_table a.add_row_link').live('click', function() {
	$('#advance_search_table').append(AdminData.advanceSearch.buildRow());
	return false;
});

$('#advance_search_table a.remove_row').live('click', function(e) {
	$(e.target).closest('tr').remove();
	return false;
});

$('#advance_search_table select.col1').live('change', function(e) {
	AdminData.bindings.col1_change(e);
});

$('#advance_search_table select.col2').live('change', function(e) {
	AdminData.bindings.col2_change(e);
});

