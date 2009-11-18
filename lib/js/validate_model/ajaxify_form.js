jQuery(document).ready(function($) {
  return function($) {
    function handleSuccess(json, statusText) {
      $('#spinner').hide();

      if (!(json.error === undefined)) {
        $('#validation_result').html('').hide();
        $('#error').html(json.error).show();
      } else if (json.still_processing === 'yes') {
        var keep_checking = function(){
          var url = 'http://localhost:3000/admin_data/validate_model_validate?still_processing=yes';
          url = url + '&tid=' + $('#tid').text();
          var fn = function(json){
            if (json.still_processing === 'no'){
              clearInterval(refreshID);
              $('#submit').attr('value','Start validation');
              $('#validation_result').html('').hide();
              $('#validation_result').html('Validation result').show();
              $('#validate_model_rhs_data').html(json.data);
            } else {
              var processing_klass = json.currently_processing_klass;
              var s = 'processing ' + processing_klass + ' ... ';
              $('#validation_result').html(s);
              $('#validate_model_rhs_data').html(json.data);
            }
          };

          $.getJSON(url,fn);
        };
        var refreshID = setInterval(keep_checking,10000);
      } else {
        $('#validation_result').html('Validation result').show();
        $('#validate_model_rhs_data').html(json.data);
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
