AdminData = AdminData || {};

AdminData.mappings =  {

      //JSLint complains if a hash has key named boolean. So I am changing the key to booleant  
      booleant: {
        options: [  
          ["is null",     "is_null"], 
          ["is not null", "is_not_null"], 
          ["is true",     "is_true"], 
          ["is false",    "is_false"]
        ]
      },

      string: {
        options: [  
          ["is null",         "is_null"], 
          ["is not null",     "is_not_null"], 
          ["contains",        "contains"], 
          ["is exactly",      "is_exactly"], 
          ["doesn't contain", "does_not_contain"]
        ]
      },

      text: {
        options: [  
          ["is null",         "is_null"], 
          ["is not null",     "is_not_null"], 
          ["Contains",        "contains"], 
          ["Doesn't Contain", "does_not_contain"]
        ]
      },

      datetime: {
        options: [  
          ["is null",       "is_null"], 
          ["is not null",   "is_not_null"],
          ['on',            "is_on"], 
          ['on or before',  "is_on_or_before_date"], 
          ['on or after',   "is_on_or_after_date"]
        ]
      },

      date: {
        options: [  
          ["is null",       "is_null"], 
          ["is not null",   "is_not_null"],
          ['on',            "is_on"], 
          ['on or before',  "is_on_or_before_date"], 
          ['on or after',   "is_on_or_after_date"]
        ]
      },

      time: {
        options: [  
          ["is null",       "is_null"], 
          ["is not null",   "is_not_null"],
          ["is exactly",    "is_exactly"]
        ]
      },

      decimal: {
        options: [  
          ['is equal to',     "is_equal_to"], 
          ['is less than',    "less_than"], 
          ['is greater than', "greater_than"]
        ]
      },

      integer: {
        options: [  
          ['is equal to',     "is_equal_to"], 
          ['is less than',    "less_than"], 
          ['is greater than', "greater_than"]
        ]
      }
};


