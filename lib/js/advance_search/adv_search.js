var AdminDataAdvanceSearch = (function($) {
  return {

    ts: undefined,

    init: function(table_structure){
      this.ts = table_structure;
      var tr_id = AdminDataJSUtil.random_number();
      var first_row = this.buildRow(tr_id);
      $('#advance_search_table').append(first_row)
                                .append(this.addAnotherRowLink());
      
      this.addBehaviorsToAddAnother();  

      this.resetCol2(tr_id);
      this.resetCol3(tr_id);
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

    resetCol3: function(tr_id){
      $('#'+tr_id+'_col3').val('').attr('disabled', true).addClass('disabled');
    },

    changeCol3: function(tr_id){
      var col2_value = $('#'+tr_id+'_adv_drop_down_col2').val();
      var target_element = $('#'+tr_id+'_col3');

      var col1_value = $('#'+tr_id+'_adv_drop_down_col1').val();
      var col1_type = this.ts[col1_value];

      if (!((col2_value == 'is_false') || 
          (col2_value == 'is_true') || 
          (col2_value == 'is_null') || 
          (col2_value == 'is_not_null') 
          )){
          target_element.attr('disabled', false).removeClass('disabled');
          if (col1_type == 'datetime' ||
              col1_type == 'date') {
            target_element.val(AdminDataJSUtil.dateToString(new Date()));
            target_element.addClass('datepicker');
            $('.datepicker').datepicker({dateFormat: 'dd-MM-yy', changeYear: true, changeMonth: true});
          } else {
            $('.datepicker').datepicker('destroy');
            target_element.removeClass('datepicker');
          }
      }
    },

    buildCol3: function(random_num){
      var sel =  $('<input></input>')
                .attr('name','adv_search['+random_num+'_row][col3]')
                .attr('id',random_num+'_col3')
                .addClass('col3')
                .attr('disabled',true);
      return $('<td></td>').append(sel);
    },

    resetCol2: function(tr_id){
      $('#'+tr_id+'_col2').val('').attr('disabled', true).addClass('disabled');
    },

    changeCol2: function(tr_id){
      var col1_value = $('#'+tr_id+'_adv_drop_down_col1').val();
      var col1_type = this.ts[col1_value];
      var target_element = $('#'+tr_id+'_adv_drop_down_col2');
      target_element.html('');
      
      if (col1_type.length > 0){
        var options = AdminDataAdvanceSearchStructure[col1_type]['options'];
        this.buildOptionsFromArray(options, target_element);
      } 
    },

    buildCol2: function(random_num){
      var sel = $('<select></select')
                    .append('<option></option>')
                    .addClass('ram_drop_down ram_drop_down_col2')
                    .attr('name','adv_search['+random_num+'_row][col2]')
                    .attr('id',random_num+'_adv_drop_down_col2');
      return $('<td></td>').append(sel);
    },

    buildCol4: function(random_num){
      var col4_a = $('<a></a>')
                .html('X')
                .attr('id',random_num+'_remove_row')
                .attr('href','#')
                .addClass('remove_row')
                .click(function(){ 
                    $(this).parent().parent().remove();
                });

      return $('<td></td>').append(col4_a);
    },



    buildCol1: function(random_num){
      var select_col1 = $('<select></select>')
                .addClass('ram_drop_down ram_drop_down_col1')
                .attr('name','adv_search['+random_num+'_row][col1]')
                .attr('id',random_num+'_adv_drop_down_col1')
                .append($('<option></option>')); // first drop down option should be empty 

      for (var i in this.ts) {
        $('<option></option>')
              .html(i)
              .attr('value',i)
              .appendTo(select_col1);
      }

      return $('<td></td>').append(select_col1);
    },

    addBehaviorsToColumns: function(row){
      var that = this;
      row.find('.ram_drop_down_col1')
        .change(function(){
          var local_tr_id = $(this).parent().parent().attr("id");
          that.changeCol2(local_tr_id);
          that.resetCol3(local_tr_id);
      });

      row.find('.ram_drop_down_col2')
        .change(function(){
          var tr_id = $(this).parent().parent().attr("id");
          that.changeCol3(tr_id);
      });
    },
    
    addBehaviorsToAddAnother: function(){
      var that = this;
      $('#tr_add_another a')
        .click(function(){
          $('#tr_add_another').before(that.buildRow(AdminDataJSUtil.random_number()));
          return false;
      });
    },

    addAnotherRowLink: function(){
      var that = this;
      var tb = this.ts;
      var td_col1 = $('<td></td>');
      var td_col2 = $('<td></td>');
      var td_col3 = $('<td></td>');
      var a =       $('<a></a>')
                      .attr('href','#') 
                      .html('Add another');
      var td_col4 = $('<td></td>').append(a); 
              
      return $('<tr></tr>')
        .append(td_col1,td_col2,td_col3,td_col4)
        .attr('id','tr_add_another');
    },

    buildRow: function(random_num){
      var td_col1 = this.buildCol1(random_num, this.ts);
      var td_col2 = this.buildCol2(random_num);
      var td_col3 = this.buildCol3(random_num);
      var td_col4 = this.buildCol4(random_num);

      var tr = $('<tr></tr>')
        .append(td_col1,td_col2,td_col3,td_col4)
        .addClass('actionable')
        .attr('id', random_num);
        
      this.addBehaviorsToColumns(tr);

      return tr;
    },
    

    buildOptionsFromArray: function(array, element){
      element.append($('<option></options'));
      for(i in array){
        $('<option></options')
          .append(array[i][0])
          .attr('value',array[i][1])
          .appendTo(element);
      }
      element.attr('disabled',false);
    }

  }; // return
})(jQuery);
