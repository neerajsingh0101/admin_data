module('build_first_row');

test('table structure', function() {
	expect(1);

	var tableStructure = $('#advance_search_table').data('table_structure');
  ok(tableStructure, 'tableStructure should not be blank');

});

