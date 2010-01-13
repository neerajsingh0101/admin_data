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
			beforeSubmit: function(formArray, jqForm) {
				$('#results').html('<span class="searching_message">searching ...</span>');
        $('#advance_search_form').data('admin_data_form_array',formArray);
			}
		};

		$('#advance_search_form').ajaxForm(options);

    $('#advance_search_delete_all').live('click', function(){

        var formData = $('#advance_search_form').data('admin_data_form_array');
        log(formData);
        formData.push({'name':'admin_data_advance_search_action_type','value':'delete'});
        log(formData);
        var parameterizedData= $.param(formData);
        log(parameterizedData);
        
        $.ajax({
          url: $('#advance_search_form').attr('action'),
          type: 'post',
          dataType: 'json',
          data: parameterizedData,
          success: function(){}
          });
        
        return false;
        
        });

	};
} (jQuery));

