jQuery(document).ready(function(){

	function dateToString(date) {
	    var month = (date.getMonth() + 1).toString();
	    var dom = date.getDate().toString();
	    // if (month.length == 1) month = "0" + month;
	    if (dom.length == 1) dom = "0" + dom;
		var months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];					
	    return dom + "-" + months[month-1] + "-" + date.getFullYear() ;
	  };
	
	
	var table_structure_data_non_json = $('#ram_table_structure_data').html();
	var table_structure_data_json = eval(table_structure_data_non_json);
	var table_structure = table_structure_data_json[0];
	
	
	function random_number(maxVal){  
		var minVal = 1;  
		var randVal = minVal+(Math.random()*(maxVal-minVal));  
		return Math.round(randVal);
	}
	

    var column_options = {
        boolean: {
            options: [	
						["is null", 		"is_null"], 
						["is not null", 	"is_not_null"], 
						["is true", 		"is_true"], 
						["is false", 		"is_false"]
					]
        },
        string: {
            options: [	
						["is null", 		"is_null"], 
						["is not null", 	"is_not_null"], 
						["contains", 		"contains"], 
						["is exactly", 		"is_exactly"], 
						["doesn't contain", "does_not_contain"]
					]
        },
        text: {
            options: [	
						["is null", 		"is_null"], 
						["is not null", 	"is_not_null"], 
						["Contains", 		"contains"], 
						["Doesn't Contain", "does_not_contain"]
					]
        },
        datetime: {
            options: [	
						["is null", 		"is_null"], 
						["is not null", 	"is_not_null"],
						['on',				"is_on"], 
						['on or before',	"is_on_or_before_date"], 
						['on or after', 	"is_on_or_after_date"]
					]
        },
        integer: {
            options: [	['is equal to', 	"is_equal_to"], 
						['is less than', 	"less_than"], 
						['is greater than', "greater_than"]]
        }
    };

		
	function build_row(random_num){
		var select_col1 = $('<select></select>')
							.addClass('ram_drop_down')
							.addClass('ram_drop_down_col1')
							.attr('name','adv_search['+random_num+'_row][col1]')
							.attr('id',random_num+'_ram_drop_down_col1');

		// add an empty row
		select_col1.append($('<option></option>'));

		for (var i in table_structure) {
			var tmp = $('<option></option>')
						.html(i)
						.attr('value',i);
			select_col1.append(tmp);
		}

		var td_col1 = $('<td></td>').append(select_col1);
		



		

		var select_col2 = $('<select></select')
									.append('<option></option>')
									.addClass('ram_drop_down ram_drop_down_col2')
									.attr('name','adv_search['+random_num+'_row][col2]')
									.attr('id',random_num+'_ram_drop_down_col2');
		var td_col2 = $('<td></td>').append(select_col2);

		var content_for_col3 = $('<input></input>')
							.attr('name','adv_search['+random_num+'_row][col3]')
							.attr('id',random_num+'_ram_input_field_col3')
							.addClass('ram_input_field_col3')
							.attr('disabled',true);
		var td_col3 = $('<td></td>').append(content_for_col3);												
							
		var content_for_col4 = $('<a></a>')
							.html('X')
							.attr('id',random_num+'_remove_row')
							.attr('href','#')
							.addClass('remove_row')
							.click(function(event){
								$(this).parent().parent().remove();
							});
		var td_col4 = $('<td></td>').append(content_for_col4);					
							

		return $('<tr></tr>').append(td_col1,td_col2,td_col3,td_col4).attr('id',random_num);
	};
	
	
	function build_add_another_row(){
		var td_col1= $('<td></td>');
		var td_col2 = $('<td></td>');
		var td_col3 = $('<td></td>');
		var a_link = $('<a></a>')
						.attr('href','#')	
						.html('Add another')
						.click(function(event){
							$('#tr_add_another').before(build_row(random_number(1000000)));
							add_behaviors_to_row_elements();
							return false;
						});
						
		var td_col4 = $('<td></td>').append(a_link);
		return $('<tr></tr>').append(td_col1,td_col2,td_col3,td_col4).attr('id','tr_add_another');
	};
	
	function add_behaviors_to_row_elements(){
		$('.ram_drop_down_col1')
			.change(function(){
				var that = $(this);
				var local_tr_id = that.parent().parent().attr("id");
				var value = $(this).val();
				adjust_col2(local_tr_id);
				adjust_col3(local_tr_id);
				disable_col3(local_tr_id);
			});

		$('.ram_drop_down_col2')
			.change(function(){
				var that = $(this);
				var local_tr_id = that.parent().parent().attr("id");
				var value = $(this).val();
				adjust_col3(local_tr_id);
			});
	};
	
	
	
	function adjust_col2(tr_id){
		var tmp = $('#'+tr_id+'_ram_drop_down_col1').val();
		var col1_value = table_structure[tmp];
		var target_element = $('#'+tr_id+'_ram_drop_down_col2');
		target_element.html('');
		
		if (col1_value.length > 0){
			var options = column_options[col1_value]['options'];
			var tmp = options.length;
			build_options_from_array(options,target_element)
			
		} else {
			target_element.attr('disabled',true);
		}
	 };
	

	function adjust_col3(tr_id){
		var col2_value = $('#'+tr_id+'_ram_drop_down_col2').val();
		var target_element = $('#'+tr_id+'_ram_input_field_col3');
		target_element.val('');
		
		if (col2_value.length > 0){
			if (
				(col2_value == 'is_false') || 
				(col2_value == 'is_true') || 
				(col2_value == 'is_null') || 
				(col2_value == 'is_not_null') 
				){
				target_element.attr('disabled',true);									
				target_element.addClass('disabled');									
			} else {
				target_element.attr('disabled',false);

				var tmp = $('#'+tr_id+'_ram_drop_down_col1').val();
				var col1_value = table_structure[tmp];
				if (col1_value == 'datetime'){
					target_element.val(dateToString(new Date()));
				} else {
					target_element.val('');
				}
																		
			}
		} else {
			target_element.attr('disabled',true);				
			target_element.addClass('disabled');												
		}
	 };
	
	
	function disable_col3(tr_id){
		var target_element = $('#'+tr_id+'_ram_input_field_col3');
		target_element.val('');
		target_element.attr('disabled',true);
	 };
	
	
	function build_options_from_array(array,element){
		element.append($('<option></options'));
		for(i in array){
			var tmp = $('<option></options').append(array[i][0]).attr('value',array[i][1]);
			element.append(tmp);
		}
		element.attr('disabled',false);
	};


	var first_row = build_row(random_number(1000000));
	$('#advance_search_table').append(first_row).append(build_add_another_row());
	
	add_behaviors_to_row_elements();	
	$('.ram_drop_down_col2').attr('disabled',true);


	// the element in which we will observe all clicks and capture
  	// ones originating from pagination links
  	var container = $(document.body);

	var ajaxify_digg_link2 = function(responseText){
	  	$('#results').html(responseText);	
		$('.digg_pagination a').click(function(event){
			$('#results').load(this.href,ajaxify_digg_link2);
			return false;
		});
		
        $('.colorize tr:odd').addClass('odd'); 
        $('.colorize tr:even').addClass('even'); 

		
	}

	 var options = {
	      success: function(responseText) {
			ajaxify_digg_link2(responseText);
	      },
		  beforeSubmit: function() {
			$('#results').html('processing ...');
		  }
	  };
	$('#advance_search_form').ajaxForm(options);

	$.ajaxSetup({ 
	  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} 
	})  
	
});

