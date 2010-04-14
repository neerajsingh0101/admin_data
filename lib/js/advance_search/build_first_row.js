$(function() {

	//TODO use $.parseJSON also use live method of jQuery 1.4.1
	var table_structure_data_non_json = $('#admin_data_table_structure_data').html(),
	table_structure_data_json = eval(table_structure_data_non_json);

	$('#advance_search_table').data('table_structure', table_structure_data_json[0]);

	AdminData.advanceSearch.buildFirstRow();

});

