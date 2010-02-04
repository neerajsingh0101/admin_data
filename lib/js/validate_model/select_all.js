jQuery(document).ready(function($) {
	return function($) {

		$('input#validate_model_select_all').click(function() {
			if ($(this).attr('checked')) {
				$("input[type=checkbox]").attr("checked", true);
			} else {
				$("input[type=checkbox]").attr("checked", false);
			}
		});

	};
} (jQuery));


