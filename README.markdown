# admin_data

## Introduction

This is a plugin to manage your database records using browser. 

## Live Demo

[http://www.neeraj.name/admin_data](http://www.neeraj.name/admin_data)

Note that in the demo you will be accessing only 'read only' features. You will
not be able to update/delete/create any record. 

## Totally Non Intrusive

* No change is required anywhere in your application.

* All the features are provided without creating any new named_scope. No 
lingering named_scope in your app.  

* Nothing is stored in session or in cookies.

## Features

* Browse table records.

* For each individual record a snapshot of all association records is shown. 
Associations that are supported are has_many, belongs_to and has_one. If an 
associated record is not present then there will be no link.

* Supports name spaced models like Vehicle::Car and Vehicle::Engine.

* Next to association a count of number of associated records is shown. 

* Al the associated records are links so one can navigate from record to record.

* Quick search across all records in a table. Quick searches across all records 
and all columns which are either 'string' type or 'text' type.

* Advance search for each field of each of the tables. [click here](http://www.neeraj.name/admin_data/advance_search?klass=Article) 
to see the options that are supported. Different options appear for diffent 
data types. 

* Sort the result on any column in ascending or descending order for both quick 
and advance search.

* Browse migration records from schema_migrations table even though there is no 
corresponding model for this table.

* Configure number of records to be shown in the list. Default value is 50.

* For both viewing the page and updating a record, security check is enforced. 
More on this in next section.

* Add a new record (update security check enforced)

* Edit an existing record (update security check enforced)

* Delete an existing record (update security check enforced and no callbacks)

* Destroy an existing record (update security check enforced and callbacks will 
be invoked)

* Diagnostic test lists all the columns which are foreign keys but index is not 
defined on them.

* Plugin does not assume that all the tables have primary key as 'id'. It 
respects the primary_key set in the model.

* While editing a record, form allows all the fields to be edited. The form can
be restricted to allow editing of only one field. Look at the tips and trick 
section at the bottom of README for more information.

* Allows applications to override the AdminData UI so admin_data pages match 
look and feel of the rest of your application.  Look at the tips and trick 
section at the bottom of README for more information.

## Requirements

* Rails project must be using Rails 2.2 or higher.

* will_paginate gem.

## Installation instruction if you are using Rails 2.3

<pre>
   <code>
ruby script/plugin install git://github.com/neerajdotname/admin_data.git
  </code>
</pre>  
	
If you are using Rails 2.2 then find the instruction at the bottom of this page.

## How to use it

	http://localhost:3000/admin_data

## Security check

This plugin allows you to configure security check for both view and update 
access. Default security check is to allow both view and update access in 
development mode and restrict both view and update access in any other 
environment. Given below is the default security.

<pre>
AdminDataConfig.set = {
  :will_paginate_per_page => 50,
  :view_security_check => lambda {|controller| return true if Rails.env.development? },
  :update_security_check => lambda {|controller| return true if Rails.env.development? }
}
</pre>

Given below is one way to ensure authentication in other environments. 
Put the following lines of code in an initializer at 
<tt>~/config/initializers/admin_data_settings.rb</tt> .

<pre>
AdminDataConfig.set = {
  :view_security_check => lambda {|controller| controller.send('logged_in?') },
  :update_security_check => lambda {|controller| controller.send('admin_logged_in?') }
}
</pre>

In the above case <tt>application_controller.rb</tt> must have two method 
<tt>logged_in?</tt> and <tt>admin_logged_in?</tt> .

## Tested with

I have tested this plugin with MySQL, PostgreSQL and Oracle. 

Run all the tests by going to the plugin directory and executing <tt>rake</tt> . 
There are nearly 200 tests and all of them should pass.


## Feedback and bug report

Email me: neerajdotname [at] gmail (dot) com

Report any bug at [http://github.com/neerajdotname/admin_data/issues](http://github.com/neerajdotname/admin_data/issues)

## Author Blog

[www.neeraj.name](http://www.neeraj.name)

## source code

[http://github.com/neerajdotname/admin_data](http://github.com/neerajdotname/admin_data)

## Metrics Summary

[http://devver.net/caliper/project?repo=git://github.com/neerajdotname/admin_data.git](http://devver.net/caliper/project?repo=git://github.com/neerajdotname/admin_data.git)

## Contributors

* [Alexey Borzenkov](http://github.com/snaury)

* [Alex Rothenberg](http://github.com/alexrothenberg)

## License

MIT

Copyright (c) 2009 neerajdotname


# Tips and Tricks

## How do I handle to_param case

I have a model called City which is defined like this.

<pre>
class City < ActiveRecord::Base
  def to_param
    self.permanent_name
  end
end
</pre>

This plugin will generate show method for city like this <tt>/admin_data/city/miami</tt> . 
The controller will execute the query assuming that id is 'miami' and the record 
will not be found. 

We propose two ways of handling such cases. 

### Solution 1: override City klass methods

In this case two methods of the klass are overriden. Note that this is how
rails scaffold generates code and this is the recommended way.

<pre>
class City < ActiveRecord::Base
  
  def to_param
    self.permanent_name
  end
  
  private

  def City.find_one(id, options)
    return super if id.is_a? Numeric
    find_by_permanent_name(id)
  end

  def City.find_some(ids, options)
    return super if ids.all? {|id| id.is_a? Numeric }
    find_all_by_permanent_name(ids)
  end

end
</pre>

### Solution 2: pass additional option to AdminDataConfig

In this case user can pass additional option called <tt>find_conditions</tt> to 
AdminDataConfig. This option will tell the plugin how to build the select
condition for that klass. 

<pre>
AdminDataConfig.set = {
  :view_security_check => lambda {|controller| controller.send('logged_in?') },
  :update_security_check => lambda {|controller| controller.send('admin_logged_in?') }
  :find_conditions => Proc.new do |params| 
    { City.name.underscore => {:conditions => { :permanent_name => params[:id]}}}
  end
}
</pre>

## How to run tests for this plugin

Just execute the following command. That's it.

<pre>
rake
</pre>

## How to restrict editing of an record to only one element

If you are editing the record of a model called 'record' then the
url might look like this

<pre>
http://localhost:3000/admin_data/article/881/edit
</pre>

If you want to restrict the user to allow editing of only one field called title
then pass aditional parameter like this.

<pre>
http://localhost:3000/admin_data/article/881/edit?attr=title
</pre>

Note that this is only preventive measure. If the user gets rid of 'attr' attribute
then user will be able to edit any allowed field. Also on the controller side
no check is done to make sure that only one attribute is being edited. Once again
this is a good tool if you accidentally do not want to edit some other field.

## Installation instruction if you are using Rails 2.2

If you are using Rails 2.2 then you need to checkout older version of this 
plugin like this

<pre>
	<code>
	git clone git://github.com/neerajdotname/admin_data.git
   	cd admin_data
   	git co -b for_rails_2.2 origin/for_rails_2.2
   	cd ..
   	cp -rv admin_data my_app/vendor/plugins 
   </code>
</pre>


After the plugin has been copied to your vendor/plugins directory then you need 
to make certain changes to the config/routes.rb .

After installing the plugin you need to put following lines of code in 
config/routes.rb  at the very top
<pre>
AdminData::Routing.connect_with map. 
</pre>

After the lines have been added it might look like this

<pre>
ActionController::Routing::Routes.draw do |map|
  AdminData::Routing.connect_with map
  # ... more routing information
end
</pre>

## Customizing the look and feel for admin_data pages

For many cases the default look and feel of admin_data pages will work for you
but there are several options for you when it doesn't

### To use your application's layout for admin_data pages

If you want admin_data pages to feel like a part of your application, 
for instance including your header and footer then you can
add the following setting in your
<tt>config/initializers/admin_data_settings.rb</tt>.

<pre>
AdminDataConfig.set = {
  :use_admin_data_layout  => false
}
</pre>

To get the admin data styles and advanced search functionality make sure to add the following 
include_tag commands to your layout files

<pre>
  <%= stylesheet_link_tag "http://ajax.googleapis.com/ajax/libs/jqueryui/1.7/themes/ui-lightness/ui.all.css" %> 
  <%= AdminData::Util.stylesheet_link_tag('base','themes/drastic-dark/style','ui.selectmenu','app') %>

  <%= javascript_include_tag('http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js') %>
  <%= javascript_include_tag('http://ajax.googleapis.com/ajax/libs/jqueryui/1.7.2/jquery-ui.min.js') %>
  <%= AdminData::Util.javascript_include_tag('log', 'ui.selectmenu', 'app') %>
  <%= AdminData::Util.javascript_include_tag('adv_search', 'jquery.form') %>
</pre>

### To change the way individual pages are rendered

If you have certain styles you want to use or have the pages render very differently than what 
admin_data provides then you can localize the erb files into your application and start editing 
your copies.

<pre>
  rake admin_data:localize_views
</pre>

This will copy the views into your application's <tt>app/views/admin_data</tt> directory.  You own these
copies and can do anything you like with them.

Warning: When you upgrade the plugin it may break your erbs requiring you to re-edit them.

### To customize edit fields for individual columns

Perhaps your application has some non-standard Rails conventions that you'd like the admin_data edit forms
to know about.  For example maybe all attributes in your models whose name ends with '_flag' should have a 
dropdown with 'Yes' and 'No' (yes this is a real scenario that came from a legacy database that did not like 
boolean columns). 

You can override the <tt>admin_data_form_field</tt> helper method used by the edit views by adding something
like what's below to <tt>app/helpers/admin_data_helper.rb</tt>.

<pre>
  # Methods added to this helper will override those defined in the admin_data plugin.
  module AdminDataHelper
    def admin_data_form_field(klass, model, col, f)
      if col.name.match(/_flag$/) 
        # columns names ending with '_flag'
        f.select(col.name.to_sym, ['Yes', 'No'], {:include_blank => true}) 
      else
        # fall through to default admin_data handling
        super
      end
    end
  end
</pre>
