var AdminDataAdvanceSearch = {

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
  },

  buildRow: function(randomNum) {

    return $('<tr />').append(this.buildCol1(randomNum), this.buildCol2(randomNum), this.buildCol3(randomNum), this.buildCol4(randomNum));
  },

  updatePageWithSearchResult: function(responseText) {
    var that = this;
    var $results = $('#results');
    $results.html(responseText);
    $('.pagination a').click(function() {
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

};
