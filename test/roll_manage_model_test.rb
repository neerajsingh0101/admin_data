require 'rubygems'
require 'test/unit'
require 'active_support'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../vendor/plugins/roll_admin_model/lib/roll_admin_model_date_validation'))

class RollManageModelTest < Test::Unit::TestCase

  def test_date_validation
    
    assert ::RollAdminModelDateValidation.validate('13-feb-2009')
    assert ::RollAdminModelDateValidation.validate('13-FEB-2009')
    assert ::RollAdminModelDateValidation.validate('13-feb -2009')    # extra white space should not hurt
    assert ::RollAdminModelDateValidation.validate('13-FEBfoo-2009')  # only the first three characters of the month should be checked
    
    
    assert !::RollAdminModelDateValidation.validate('13-foo-2009')    # month name is wrong
    assert !::RollAdminModelDateValidation.validate('13 foo 2009')    # there must be two occurences of -
    assert !::RollAdminModelDateValidation.validate('32-jan-2009')    # day is wrong
    assert !::RollAdminModelDateValidation.validate('32-jan- -2009')  # there should be only two occurences of -
    assert !::RollAdminModelDateValidation.validate('32-jan-09')      # year must be greater than 1900 
  end

  def test_date_validation_with_operator
    assert ::RollAdminModelDateValidation.validate_with_operator('> 13-feb-2009')    
    assert ::RollAdminModelDateValidation.validate_with_operator('>= 13-feb-2009')    
    assert ::RollAdminModelDateValidation.validate_with_operator('< 13-feb-2009')    
    assert ::RollAdminModelDateValidation.validate_with_operator('<= 13-feb-2009')    
    
    assert !::RollAdminModelDateValidation.validate_with_operator('<=13-feb-2009')  # no white space
    assert !::RollAdminModelDateValidation.validate_with_operator('| 13-feb-2009')   # invalid operator     
  end
  
end
