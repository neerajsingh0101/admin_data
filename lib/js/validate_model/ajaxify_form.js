jQuery(document).ready(function($) {
	return function($) {
		function handleSuccess(json, statusText) {
      $('#submit').attr('value','Start validation');
			$('#spinner').hide();

			if (json.error === undefined) {
        $('#validation_result').html('Validation result').show();
         $('#validate_model_rhs_data').html(json.data);
			} else {
         $('#validation_result').html('').hide();
	       $('#error').html(json.error).show();
			}
		}

		function preSubmit(formData, jqForm, options) {
      $('#validate_model_rhs_data').html('');
      $('#validation_result').html('processing ....').show();
			$('#error').hide();
			$('#spinner').show();
      $('#submit').attr('value','processing ...');
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

