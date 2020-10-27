require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  setup do
    @product = products(:one)
  end

  test 'should have a valid positive price' do
    @product.price = -1
    assert_not @product.valid?
  end

  test 'should validate the numericality of price' do
    @product.price = "one"
    assert_not @product.valid?
  end

  test 'should validate the presence of the price' do
    @product.price = nil
    assert_not @product.valid?
  end

  test 'should validate the presence of the title' do
    @product.title = nil
    assert_not @product.valid?
  end

  test 'should validate the presence of the user_id' do
    @product.user_id = nil
    assert_not @product.valid?
  end

    test 'should filter products by name' do
      assert_equal 2, Product.filter_by_title('tv').count
    end

    test 'should filter products by name and sort them' do
      assert_equal [products(:another_tv), products(:one)], Product.filter_by_title('tv').sort
    end
end
