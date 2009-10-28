# admin_data

## Introduction

This is a plugin to manage your database records using browser. 

## Live Demo

[http://demo.neeraj.name/admin_data](http://demo.neeraj.name/admin_data)

Note that in the demo you will be accessing only 'read only' features. You will
not be able to update/delete/create any record. 

## Totally Non Intrusive

* No change is required anywhere in your application.

* All the features are provided without creating any new named_scope. No 
lingering named_scope in your app.  

* Nothing is stored in session or in cookies.

## Features

For a detailed listing of features [visit wiki](http://wiki.github.com/neerajdotname/admin_data) .

* Browse table records.

* For each individual record a snapshot of all association records is shown. 
Associations that are supported are has_many, belongs_to and has_one. If an 
associated record is not present then there will be no link.

* Supports name spaced models like Vehicle::Car and Vehicle::Engine.

* Next to association a count of number of associated records is shown. 

* Al the associated records are links so one can navigate from record to record.

* Quick search across all records in a table. Quick searches across all records 
and all columns which are either 'string' type or 'text' type.

* Advance search for each field of each of the tables. [click here](http://demo.neeraj.name/admin_data/user/advance_search) 
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
ruby script/plugin install git://github.com/neerajdotname/admin_data.git
</pre>  
	
If you are using Rails 2.2 then find the instruction at [wiki](http://wiki.github.com/neerajdotname/admin_data)

## How to use it

<pre>
http://localhost:3000/admin_data
</pre>

## Security check

This plugin allows you to configure security check for both view and update 
access. Default security check is to allow both view and update access in 
development mode and restrict both view and update access in any other 
environment. 

Given below are some example security rules you could use as a starting point
for your application.  

## Customization Options

Plugin allows user to customize the behavior through following options.

<pre>
AdminDataConfig.set = {
  :will_paginate_per_page => 50,
  :find_conditions => lambda {|params| ... }, 
  :use_admin_data_layout  => false,
  :column_settings => {}
}
</pre>

Refer to 'tips and tricks' section at the bottom of this README to read detailed explanation
of the each of the options. Here is a quick summary.

* will_paginate: Change this setting if you want lesser or more number of records in the listing .
* find_conditions: If one of your models has implemented <tt>to_param</tt> method then show method for 
that model might or might not work. This option helps you to get around to that problem.
* use_admin_data_layout: Change this setting if you want custom layout. 
* column_settings: Use this option if you want to the value of a column of a model to rendered in a specific
way .


### Security

Given below is the default security model.

<pre>
AdminDataConfig.set = {
  :view_security_check => lambda {|controller| return true if Rails.env.development? },
  :update_security_check => lambda {|controller| return true if Rails.env.development? }
}
</pre>

You can override these two values by providing your own procs. These procs will have to both
controller and the model so that you can have a really fine grained security model. Please
refer to the security section of 'tips and tricks' at the bottom of this README page for
some example code. 

## How to cutomize options change security options

Just create an initializer file named <tt>admin_data_settings.rb</tt> at <tt>config/initializers </tt>. 
The full path to the file will be <tt>config/initializers/admin_data_settings.rb</tt> .

In that file you can pass options like this.

<pre>
AdminDataConfig.set = {
  :will_paginate_per_page => 100,
  :view_security_check => lambda {|controller| return true if Rails.env.development? },
  :update_security_check => lambda {|controller| return true if Rails.env.development? }
}
</pre>


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

