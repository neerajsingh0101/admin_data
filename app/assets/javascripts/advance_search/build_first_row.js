$(function() {

  var json = $.parseJSON( $('#primary_column_type_info').html());
	$('#advance_search_table').data('table_structure', json);
	AdminData.advanceSearch.buildFirstRow();

});

