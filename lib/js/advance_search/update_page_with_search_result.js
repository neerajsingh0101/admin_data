
    updatePageWithSearchResult: function(responseText){
      var that = this;
      $('#results').html(responseText); 
      $('.pagination a').click(function(event){
        $('#results').load(this.href, that.updatePageWithSearchResult);
        return false;
      });
      AdminDataJSUtil.colorizeRows();
    },
