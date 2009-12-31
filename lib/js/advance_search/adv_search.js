var AdminDataAdvanceSearch = (function($) {
  return {

    // ts stands for table structure
    ts: undefined,

    init: function(table_structure){
      this.ts = table_structure;
      var tr_id = AdminDataJSUtil.random_number();
      var first_row = this.buildRow(tr_id);
      $('#advance_search_table').append(first_row)
                                .append(this.addAnotherRowLink())
                                .filter('tr:first td:last a').hide();  //hide the first delete row link
    },

    redrawCol3: function(tr_id){
      var col2_value = $('#'+tr_id+'_adv_drop_down_col2').val();
      var $col3 = $('#'+tr_id+'_col3');

      var col1_value = $('#'+tr_id+'_adv_drop_down_col1').val();
      var col1_type = this.ts[col1_value];

      if ((col2_value.length === 0) || (col2_value == 'is_false') || (col2_value == 'is_true') || (col2_value == 'is_null') || (col2_value == 'is_not_null') ){
            $col3
              .val('')
              .attr('disabled', true)
              .addClass('disabled');
      } else {
            $col3
              .attr('disabled', false)
              .removeClass('disabled');
            if (col1_type == 'datetime' ||
                col1_type == 'date') {
              $col3.val(AdminDataJSUtil.dateToString(new Date()))
                            .addClass('datepicker');
              $('.datepicker').datepicker({dateFormat: 'dd-MM-yy', changeYear: true, changeMonth: true});
            } else {
              $('.datepicker').datepicker('destroy');
              $col3.removeClass('datepicker').focus(); // do not create focus for date pickers
            }

      }
    },

    buildCol3: function(random_num){
      return  $('<td></td>')
                .append('<input></input>')
                  .find(':input')
                  .attr({ 'name': 'adv_search['+random_num+'_row][col3]',
                          'id': random_num+'_col3',
                          'disabled': true })
                  .addClass('col3')
                  .end();
               
    },

    redrawCol2: function(tr_id){
      var col1_value = $('#'+tr_id+'_adv_drop_down_col1').val();
      var col1_type = this.ts[col1_value];
      var $col2 = $('#'+tr_id+'_adv_drop_down_col2');
      $col2.html('');
      var options = AdminDataAdvanceSearchStructure[col1_type]['options'];
      this.buildOptionsFromArray(options, $col2);
      this.redrawCol3(tr_id);
    },

    buildCol2: function(random_num){
      var that = this;
      return $('<td></td>')
                .append('<select></select>')
                  .find('select')
                  .append('<option></option')
                  .addClass('ram_drop_down ram_drop_down_col2')
                  .attr('name','adv_search['+random_num+'_row][col2]')
                  .attr('id',random_num+'_adv_drop_down_col2')
                  .attr('disabled', true)
                  .addClass('disabled')
                  .change(function(){
                    var tr_id = $(this).parent().parent().attr("id");
                    that.redrawCol3(tr_id);
                  })
                  .end();
    },

    buildCol4: function(random_num){

      return $('<td></td>')
                .append('<a></a>')
                  .find('a')
                  .html('X')
                  .attr('id',random_num+'_remove_row')
                  .attr('href','#')
                  .addClass('remove_row')
                  .click(function(){ 
                    $(this).parent().parent().remove();
                  })
                  .end();
    },

    buildCol1: function(random_num){
                 var that = this;
      var select_col1 = $('<select></select>')
                .addClass('ram_drop_down ram_drop_down_col1')
                .attr('name','adv_search['+random_num+'_row][col1]')
                .attr('id',random_num+'_adv_drop_down_col1')
                .append($('<option></option>')); // first drop down option should be empty 

      for (var i in this.ts) {
        $('<option></option>')
              .text(i)
              .attr('value',i)
              .appendTo(select_col1);
      }

      select_col1.change(function(){
          var local_tr_id = $(this).parent().parent().attr("id");
          that.redrawCol2(local_tr_id);
      });

      return $('<td></td>').append(select_col1);
    },

    addAnotherRowLink: function(){
      return $('<tr></tr>')
                .append('<td></td>')
                .append('<td></td>')
                .append('<td></td>')
                .append('<td></td>')
                  .find('td:last')
                  .append('<a></a>')
                    .find('a')
                    .attr('href','#')
                    .html('Add another')
                    .click(function(){
                      $('#tr_add_another').before(AdminDataAdvanceSearch.buildRow(AdminDataJSUtil.random_number()));
                      return false;
                      })
                    .end()
                  .end()
                .attr('id','tr_add_another');
    },

    buildRow: function(random_num){

      return $('<tr></tr>')
                .append(this.buildCol1(random_num))
                .append(this.buildCol2(random_num))
                .append(this.buildCol3(random_num))
                .append(this.buildCol4(random_num))
                .attr('id', random_num);
    },

    updatePageWithSearchResult: function(responseText){
      var that = this;
      $('#results').html(responseText); 
      $('.pagination a').click(function(event){
        $('#results').load(this.href, that.updatePageWithSearchResult);
        return false;
      });
      AdminDataJSUtil.colorizeRows();
    },

    buildOptionsFromArray: function(array, element){
      element.append($('<option></options'));
      for(i in array){
        $('<option></options')
          .text(array[i][0])
          .attr('value',array[i][1])
          .appendTo(element);
      }
      element.attr('disabled',false);
    }

  }; // return
})(jQuery);
