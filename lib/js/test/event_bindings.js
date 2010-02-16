module('event_bindings');

test('live click on a.add_row_link', function() {
	expect(3);

	$('#advance_search_table').html('');
	equals(0, $('#advance_search_table tr').length, 'there should be no row in the table');

	AdminData.advanceSearch.buildFirstRow();
	equals(1, $('#advance_search_table tr').length, 'there should be only first row in the table');

	$('#advance_search_table a.add_row_link').trigger('click');
	equals(2, $('#advance_search_table tr').length, 'additional row should be added to the table');
});

test('live click on a.remove_row link', function() {
	expect(5);

	$('#advance_search_table').html('');
	equals(0, $('#advance_search_table tr').length, 'there should be no row in the table');

	AdminData.advanceSearch.buildFirstRow();
	equals(1, $('#advance_search_table tr').length, 'there should be only first row in the table');

	$('#advance_search_table').append(AdminData.advanceSearch.buildRow());
	equals(2, $('#advance_search_table tr').length, 'there should be two rows in the table');

	var $a = $('#advance_search_table a.remove_row');
	equals(1, $a.length, 'there should be one anchor element with class remove_row');

	$('#advance_search_table a.remove_row').trigger('click');
	equals(1, $('#advance_search_table tr').length, 'there should be only one row in the table');
});

test('live select.col1 change', function() {
	expect(10);

	$('#advance_search_table').html('');
	equals(0, $('#advance_search_table tr').length, 'there should be no row in the table');

	AdminData.advanceSearch.buildFirstRow();
	equals(1, $('#advance_search_table tr').length, 'there should be only first row in the table');

	ok($('#advance_search_table select.col2').is(':disabled'), 'second column should be disabled');

	$('#advance_search_table select.col1').val('first_name');
	$('#advance_search_table select.col1').trigger('change');

	ok(!$('#advance_search_table select.col2').is(':disabled'), 'second column should be enabled');

	var s = $('#advance_search_table select.col2 option').eq(0).text();
	equals('', s, 'empty value should be the first option');

	s = $('#advance_search_table select.col2 option').eq(1).text();
	equals('is null', s, 'is null should be the second option');

	s = $('#advance_search_table select.col2 option').eq(2).text();
	equals('is not null', s, 'is null should be the third option');

	s = $('#advance_search_table select.col2 option').eq(3).text();
	equals('contains', s, 'contains should be the fourth option');

	s = $('#advance_search_table select.col2 option').eq(4).text();
	equals('is exactly', s, 'contains should be the fifth option');

	s = $('#advance_search_table select.col2 option').eq(5).text();
	equals("doesn't contain", s, 'does not contain should be the sixth option');
});

test('live select.col2 change', function() {
	expect(2);

	$('#advance_search_table').html('');
	AdminData.advanceSearch.buildFirstRow();
	ok($('#advance_search_table input.col3').is(':disabled'), 'third column should be disabled');

	$('#advance_search_table select.col1').val('first_name');
	$('#advance_search_table select.col1').trigger('change');
	$('#advance_search_table select.col2').val('contains');
	$('#advance_search_table select.col2').trigger('change');

	ok($('#advance_search_table input.col3').is(':enabled'), 'third column should be enabled');
});


test('live select.col2 change for is_null input', function() {
	expect(2);

	$('#advance_search_table').html('');
	AdminData.advanceSearch.buildFirstRow();
	ok($('#advance_search_table input.col3').is(':disabled'), 'third column should be disabled');

	$('#advance_search_table select.col1').val('first_name');
	$('#advance_search_table select.col1').trigger('change');
	$('#advance_search_table select.col2').val('is_null');
	$('#advance_search_table select.col2').trigger('change');

	ok($('#advance_search_table input.col3').is(':disabled'), 'third column should be disabled');
});

