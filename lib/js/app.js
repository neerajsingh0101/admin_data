jQuery(document).ready(function($) {
	return function($) {

		$('#quick_search_input').focus();

		$('.drop_down_value_klass').change(function() {
			window.location = $(this).val();
		});

	};
}(jQuery));
