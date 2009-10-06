$(function(){
  $('#quick_search_input').focus();    

  $('#drop_down_value_klass').change(function(){
    window.location = $(this).val();  
  });

  $('#drop_down_value_klass').selectmenu({maxHeight: 450});

  $('#sortby').selectmenu();

  $('#view_table tr').hover(
    function(){ $(this).addClass('highlight'); },
    function(){ $(this).removeClass('highlight'); }
  );

});
