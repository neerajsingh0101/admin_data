var AdminData = AdminData || {};

AdminData.advanceSearch = {

  buildFirstRow: function(){
    $('#advance_search_table')
      .append(this.buildRow())
      .find('tr td:last a')
        .text('+')
        .removeClass('remove_row')
        .addClass('add_row_link');
  },

  buildCol1: function() {
    var i, 
        col = $('<select />', {className: 'col1' }).append($('<option />')),
        tableStructure = $('#advance_search_table').data('table_structure');

    for (i in tableStructure) {
      $('<option />', {text: i, value: i}).appendTo(col);
    }
    return $('<td />').append(col);
  },

  buildCol2: function() {
    return $('<td />')
              .append('<select />')
              .find('select')
                .append('<option />')
                .addClass('col2 disabled')
                .attr({ disabled: true }).
              end();
  },

  buildCol3: function() {
    return $('<td />').append($('<input />',{disabled: true, className: 'col3'}));
  },

  buildCol4: function() {
    return $('<td />').append($('<a />', {text: 'x', href: '#', className: 'remove_row'}));
  },

  buildRow: function() {
    var $tr = $('<tr />'),
        that = this,
        randomNumber = AdminData.jsUtil.randomNumber(),
        build_array = ['buildCol1', 'buildCol2', 'buildCol3', 'buildCol4'];
    
    $.each(build_array, function(index, value) {
      $tr.append(that[value]());
    });

    $tr.find('select.col1').attr({ name: 'adv_search[' + randomNumber + '_row][col1]'});
    $tr.find('select.col2').attr({ name: 'adv_search[' + randomNumber + '_row][col2]'});
    $tr.find('input.col3').attr({ name: 'adv_search[' + randomNumber + '_row][col3]'});

    return $tr;
  }

};
