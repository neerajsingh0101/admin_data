jQuery(document).ready(function($) {
	return function($) {
		function handleSuccess(json, statusText) {
			$('#spinner').hide();
			var base_url;

			if (! (json.error === undefined)) {
				$('#submit').attr('value', 'Start validation');
				$('#validation_result').html('').hide();
				$('#error').html(json.error).show();
			} else if (json.still_processing === 'yes') {
				if (! (json.base_url === undefined)) {
					base_url = json.base_url;
				}
				var keep_checking = function() {
					var url = base_url + '/admin_data/diagnostic/validate_model?still_processing=yes';
					url = url + '&tid=' + $('#tid').text();
					var fn = function(json) {
						if (json.still_processing === 'no') {
							clearInterval(refreshID);
							$('#submit').attr('value', 'Start validation');
							$('#validation_result').html('').hide();
							$('#validation_result').html('Validation result').show();
							$('#validate_model_rhs_data').html(json.data);
						} else {
							var processed_info = json.currently_processing_klass;
							var s = processed_info + ' ... ';
							$('#validation_result').html(s);
							$('#validate_model_rhs_data').html(json.data);
						}
					};

					$.getJSON(url, fn);
				};
				var refreshID = setInterval(keep_checking, 4000);
			} else {
				$('#validation_result').html('Validation result').show();
				$('#validate_model_rhs_data').html(json.data);
			}
		}

		function preSubmit(formData, jqForm, options) {
			$('html,body').animate({
				scrollTop: 0
			},
			0);
			$('#validate_model_rhs_data').html('');
			$('#validation_result').html('Processing .... This page will refersh itself periodically.').show();
			$('#error').hide();
			$('#spinner').show();
			$('#submit').attr('value', 'processing ...');
			return true;
		}

		var options = {
			beforeSubmit: preSubmit,
			success: handleSuccess,
			dataType: 'json'
		};

		$('#validate_model_form').ajaxForm(options);

	};
} (jQuery));


