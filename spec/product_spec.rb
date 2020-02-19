require 'spec_helper'
require 'product'

describe Product do
  it 'Should have value for the item_quantity, item_name, item_price' do
    product = Product.new
    product.item_quantity = 1
    product.item_name = 'Books'
    product.item_price = 12.49
    
    expect(product).to have_attributes(item_quantity: 1) 
    expect(product).to have_attributes(item_name: 'Books') 
    expect(product).to have_attributes(item_price: 12.49) 
  end 

  it "Should Create a CSV" do
  	product = Product.new
		csv_created = product.create_csv

    expect(csv_created).to eq csv_created
  end

  
end