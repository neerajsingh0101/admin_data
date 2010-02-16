var AdminData = AdminData || {};

AdminData.advanceSearch = {

  buildFirstRow: function(){
    $('#advance_search_table').
      append(this.buildRow()).find('tr td:last a').text('+').removeClass('remove_row').addClass('add_row_link');
  },

  buildCol1: function() {
    var col = $('<select />', {className: 'col1' }).append($('<option />')); 
    var tableStructure = $('#advance_search_table').data('table_structure');
    for (var i in tableStructure) {
      $('<option />').text(i).attr('value', i).appendTo(col);
    }
    return $('<td />').append(col);
  },

  buildCol2: function() {
    return $('<td />').
              append('<select />').
                find('select').
                append('<option />').
                addClass('col2 disabled').
                attr({ disabled: true }).
              end();
  },

  buildCol3: function() {
    return $('<td />').append($('<input />',{disabled: true, className: 'col3'}));
  },

  buildCol4: function() {
    return $('<td />').append($('<a />', {text: 'x', href: '#', className: 'remove_row'}));
  },

  buildRow: function() {
    var $tr = $('<tr />').append(this.buildCol1(), this.buildCol2(), this.buildCol3(), this.buildCol4());
    var randomNumber = AdminData.jsUtil.randomNumber();
    $tr.find('select.col1').attr({ name: 'adv_search[' + randomNumber + '_row][col1]'});
    $tr.find('select.col2').attr({ name: 'adv_search[' + randomNumber + '_row][col2]'});
    $tr.find('input.col3').attr({ name: 'adv_search[' + randomNumber + '_row][col3]'});
    return $tr;
  }

};
