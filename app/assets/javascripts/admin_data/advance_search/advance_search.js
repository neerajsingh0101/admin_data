var AdminData = AdminData || {};

AdminData.advanceSearch = {

	buildFirstRow: function() {

		var img = $('<img />', {
			src: '/admin_data/public/images/add.png'
		});

		$('#advance_search_table').append(this.buildRow())
                                .find('tr td:last a')
                                .attr('id','add_row_link_1')
                                .removeClass('remove_row')
                                .addClass('add_row_link')
                                .html('')
                                .append(img);
	},

	buildCol1: function() {
		var i, col = $('<select />', { className: 'col1' }).append($('<option />')),
		tableStructure = $('#advance_search_table').data('table_structure');

		for (i in tableStructure) {
			$('<option />', {
				text: i,
				value: i
			}).appendTo(col);
		}
		return $('<td />').append(col);
	},

	buildCol2: function() {
		var select = $('<select />', { className: 'col2', disabled: 'disabled' });
		return $('<td />').append(select);
	},

	buildCol3: function() {
		var select = $('<input />', { className: 'col3' });
		return $('<td />').append($('<input />', { className: 'col3', disabled: 'disabled' }));
	},

	buildCol4: function() {
		var img = $('<img />', {
			src: '/admin_data/public/images/no.png'
		});

		return $('<td />').append($('<a />', {
			text: '',
			href: '#',
			className: 'remove_row'
		}).append(img));
	},

	buildRow: function() {

		var $tr = $('<tr />'),
		currentRowNumber = $(document).data('currentRowNumber'),
		that = this,
		build_array = ['buildCol1', 'buildCol2', 'buildCol3', 'buildCol4'];

		if (currentRowNumber === undefined) {
			currentRowNumber = 1;
			$(document).data('currentRowNumber', currentRowNumber);
		} else {
			currentRowNumber = parseInt(currentRowNumber, 10) + 1;
			$(document).data('currentRowNumber', currentRowNumber);
		}

		$.each(build_array, function(index, value) {
			$tr.append(that[value]());
		});

		$tr.find('select.col1').attr({ name: 'adv_search[' + currentRowNumber + '_row][col1]' });
		$tr.find('select.col2').attr({ name: 'adv_search[' + currentRowNumber + '_row][col2]' });
		$tr.find('input.col3').attr({ name: 'adv_search[' + currentRowNumber + '_row][col3]' });

    $tr.find('.remove_row').attr('id', 'remove_row_'+currentRowNumber);

		return $tr;
	}

};
