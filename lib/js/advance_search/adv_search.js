var AdminDataAdvanceSearch = (function($) {
	return {

		// ts stands for table structure
		ts: undefined,

		init: function(table_structure){
			this.ts = table_structure;
			var tr_id = AdminDataJSUtil.random_number();
			var first_row = this.buildRow(tr_id);
			$('#advance_search_table').
        append(first_row).
        find('tr td:last a').text('+').removeClass('remove_row').addClass('add_row_link');
		},

		buildCol1: function(random_num) {
			var col = $('<select />', {className: 'col1', name: 'adv_search[' + random_num + '_row][col1]'}).
                  append($('<option />')); 

			for (var i in this.ts) {
				$('<option />').text(i).attr('value', i).appendTo(col);
			}
			return $('<td />').append(col);
		},

		buildCol2: function(random_num) {
			return $('<td />').
                append('<select />').
                  find('select').
                  append('<option />').
                  addClass('col2 disabled').
                  attr({
				            name: 'adv_search[' + random_num + '_row][col2]',
				            id: random_num + '_adv_drop_down_col2',
				            disabled: true
			            }).
                end();
      
      //.change(function() {
				//var tr_id = $(this).parent().parent().attr("id");
				//that.redrawCol3(tr_id);
			//})
		},

		buildCol3: function(random_num) {
			return $('<td />').
                append('<input />').
                find(':input').
                  attr({
				          name: 'adv_search[' + random_num + '_row][col3]',
				          id: random_num + '_col3',
				          disabled: true }).
                  addClass('col3').
                end();
		},

		buildCol4: function(random_num) {
			return $('<td />').
                append('<a />').
                find('a').
                text('x').
                attr({
				          id: random_num + '_remove_row',
				          href: '#' }).
                addClass('remove_row').
                end();
      //.click(function() {
				//$(this).parent().parent().remove();
			//})
		},

		redrawCol3: function(tr_id) {
			var col2_value = $('#' + tr_id + '_adv_drop_down_col2').val();
			var $col3 = $('#' + tr_id + '_col3');

			var col1_value = $('#' + tr_id + '_adv_drop_down_col1').val();
			var col1_type = this.ts[col1_value];

			if ((col2_value.length === 0) || (col2_value == 'is_false') || (col2_value == 'is_true') || (col2_value == 'is_null') || (col2_value == 'is_not_null')) {
				$col3.val('').attr('disabled', true).addClass('disabled');
			} else {
				$col3.attr('disabled', false).removeClass('disabled');
				if (col1_type == 'datetime' || col1_type == 'date') {
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
		},


		redrawCol2: function(tr_id) {
			var col1_value = $('#' + tr_id + '_adv_drop_down_col1').val();
			var col1_type = this.ts[col1_value];
			var $col2 = $('#' + tr_id + '_adv_drop_down_col2');
			$col2.html('');
			var options = AdminDataAdvanceSearchStructure[col1_type]['options'];
			this.buildOptionsFromArray(options, $col2);
			this.redrawCol3(tr_id);
		},



		buildRow: function(random_num) {

			return $('<tr />').
                append(this.buildCol1(random_num)).
                append(this.buildCol2(random_num)).
                append(this.buildCol3(random_num)).
                append(this.buildCol4(random_num)).
                attr('id', random_num);
		},

		updatePageWithSearchResult: function(responseText) {
			var that = this;
			var $results = $('#results');
			$results.html(responseText);
			$('.pagination a').click(function(event) {
				$results.load(this.href, that.updatePageWithSearchResult);
				return false;
			});
			AdminDataJSUtil.colorizeRows();
		},

		buildOptionsFromArray: function(array, element) {
			element.append($('<option />'));
			for (i in array) {
				$('<option />').text(array[i][0]).attr('value', array[i][1]).appendTo(element);
			}
			element.attr('disabled', false);
		}

	}; // return
})(jQuery);


