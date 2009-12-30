jQuery(document).ready(function($) {
	return function($) {
		$('#quick_search_input').focus();

		$('.drop_down_value_klass').change(function() {
			window.location = $(this).val();
		});

		$('.drop_down_value_klass').selectmenu({
			maxHeight: 350,
			style: 'dropdown'
		});

		$('#sortby').selectmenu();
	};
}(jQuery));
