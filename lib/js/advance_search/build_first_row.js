$(function() {

  var json = $.parseJSON( $('#admin_data_table_structure_data').html());
	$('#advance_search_table').data('table_structure', json);
	AdminData.advanceSearch.buildFirstRow();

});

