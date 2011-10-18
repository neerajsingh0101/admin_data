$(function(){

	var form = $('#advance_search_form');

	if (form.length === 0) return;

	$('#view_table tr.thead').live('click', function(e){
		var value = $(e.target).closest('.sortable').attr('data-sortby');
		$('#advance_search_sortby').val(value);
		form.submit();
		return false;
	});

});
