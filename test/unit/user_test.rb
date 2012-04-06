require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def new_user(attributes = {})
    attributes[:email] ||= 'foo@example.com'
    attributes[:password] ||= 'abc123'
    attributes[:password_confirmation] ||= attributes[:password]
    user = User.new(attributes)
    user.valid? # run validations
    user
  end

  def setup
    User.delete_all
  end

  def test_valid
    assert new_user.valid?
  end

  def test_require_password
    assert_equal ["can't be blank"], new_user(:password => '').errors[:password]
  end

  def test_require_well_formed_email
    assert_equal ["is invalid"], new_user(:email => 'foo@bar@example.com').errors[:email]
  end

  def test_validate_uniqueness_of_email
    new_user(:email => 'bar@example.com').save!
    assert_equal ["has already been taken"], new_user(:email => 'bar@example.com').errors[:email]
  end

  def test_validate_password_length
    assert_equal ["is too short (minimum is 4 characters)"], new_user(:password => 'bad').errors[:password]
  end

  def test_require_matching_password_confirmation
    assert_equal ["doesn't match confirmation", "doesn't match confirmation"], new_user(:password_confirmation => 'nonmatching').errors[:password]
  end

  def test_authenticate_by_email
    User.delete_all
    user = new_user(:email => 'foo@bar.com', :password => 'secret')
    user.save!
    assert_equal user, User.authenticate('foo@bar.com', 'secret')
  end

  def test_authenticate_bad_username
    assert_nil User.authenticate('nonexisting', 'secret')
  end

  def test_authenticate_bad_password
    User.delete_all
    new_user(:email => 'foo@bar.com', :password => 'secret').save!
    assert !User.authenticate('foo@bar.com', 'badpassword')
  end
end
