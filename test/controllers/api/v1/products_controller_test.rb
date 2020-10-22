require 'test_helper'

class Api::V1::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
    @user = users(:one)
  end

  test 'should show products' do
    get api_v1_products_url, as: :json
    assert_response :success
    json_response = JSON.parse(self.response.body, symbolize_names: true)
    assert_equal @product.title, json_response[:data][2][:attributes][:title]
    assert_equal @product.user.id.to_s, json_response[:data][2][:relationships][:user][:data][:id]
    # assert_equal @product.user.email, json_response[:included]
  end

  test 'should show product' do
    get api_v1_product_url(@product), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @product.title, json_response['data']['attributes']['title']
  end

  test 'should create product' do
    assert_difference('Product.count') do
      post api_v1_products_url,
           params: {
             product: {
               title: @product.title,
               price: @product.price,
               published: @product.published
             }
           },
           headers: {
             Authorization: JsonWebToken.encode(user_id: @product.user_id)
           }, as: :json
    end
    assert_response :created
  end

  test 'should forbid create product' do
    assert_no_difference('Product.count') do
      post api_v1_products_url,
           params: {
             product: {
               title: @product.title,
               price: @product.price,
               published: @product.published
             }
           },
           as: :json
    end
    assert_response :forbidden
  end

  test 'should update product' do
    patch api_v1_product_url(@product), params: {
      title: 'mi titulo',
      price: 35
    },
    headers: {
      Authorization: JsonWebToken.encode(user_id: @product.user_id)
    }, as: :json
    assert_response :success
  end

  test 'should forbid update product when not logged in' do
    patch api_v1_product_url(@product), params: {
      title: 'mi titulo',
      price: 35
    }, as: :json
    assert_response :forbidden
  end

  test 'should destroy a product' do
    assert_difference('Product.count', -1) do
      delete api_v1_product_url(@product), headers: {
        Authorization: JsonWebToken.encode(user_id: @product.user_id)
      }, as: :json
    end
    assert_response :no_content
  end

  test 'should forbid the destruction if no user is provided' do
    assert_no_difference('Product.count') do
      delete api_v1_product_url(@product), as: :json
    end
    assert_response :forbidden
  end

  test 'should filter products by price and sort them' do
    assert_equal [products(:two), products(:one)], Product.above_or_equal_to_price(200).sort
  end

  test 'should filter products by price lower and sort them' do
    assert_equal [products(:another_tv)], Product.below_or_equal_to_price(200).sort
  end

  test 'should sort product by most recent' do
    products(:two).touch
    assert_equal [products(:another_tv), products(:one), products(:two)], Product.recent.to_a
  end

  test 'search should not find videogame and 100 as min price' do
    search_hash ={ keyword: 'videogame', min_price: 100 }
    assert Product.search(search_hash).empty?
  end

  test 'should find cheap TV' do
    search_hash = { keyword: 'tv', min_price: 50, max_price: 150 }
    assert_equal [products(:another_tv)], Product.search(search_hash)
  end

  test 'should get all products when no parameters' do
    assert_equal Product.all.to_a, Product.search({})
  end

  test 'search should filter by product ids' do
    search_hash= { product_ids: [products(:one).id] }
    assert_equal [products(:one)], Product.search(search_hash)
  end
end
