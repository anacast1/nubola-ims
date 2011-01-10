require File.dirname(__FILE__) + '/../test_helper'

class GroupSettingTest < Test::Unit::TestCase
  fixtures :group_settings

  # Replace this with your real tests.
  def test_truth
    assert_kind_of GroupSetting, group_settings(:first)
  end
end
