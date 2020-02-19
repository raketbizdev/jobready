load 'gem_required.rb'
class Product
	attr_accessor :item_quantity, :item_name, :item_price, :tax_type

	def item(item_quantity, item_name, item_price)
		@item_quantity 		= item_quantity
		@item_name 				= item_name
		@item_price 			= item_price
	end

	def create_csv
		CSV.open("../csv/product_item.csv", 'w') do |file|
			file << ['item_quantity', 'item_name', 'item_price', 'tax_rate']
		end
		
	end

	def tax_added_price
			@tax_bracket = {
				basic_tax: 0.10, 
				import_duty_tax: 0.05,
				tax_exempt: 0.00,
				imported_product_with_no_tax_exempt: 0.15
			}
	end

	def tax_bracket(tax_type)
			@tax_type = tax_type
		if @tax_type == 'basic_tax'
			@value_added_price = (tax_added_price[:basic_tax] * @item_price).round(2)
			@new_price = ((@item_price + @value_added_price) * @item_quantity).round(2)
			return @new_price
		elsif @tax_type == 'import_duty_tax'
			@value_added_price = (tax_added_price[:import_duty_tax] * @item_price).round(2)
			@new_price = ((@item_price + @value_added_price) * @item_quantity).round(2)
			return @new_price
		elsif @tax_type == 'imported_product_with_no_tax_exempt'
			@value_added_price = (tax_added_price[:imported_product_with_no_tax_exempt] * @item_price).to_f
			@new_price = ((@item_price + @value_added_price) * @item_quantity).round(2)
			return @new_price
		elsif @tax_type == 'tax_exempt'
			@value_added_price = (tax_added_price[:tax_exempt] * @item_price).to_f
			@new_price = ((@item_price + @value_added_price) * @item_quantity).round(2)
			return @new_price
		else
			puts "Error: Select Tax Bracket"
		end
	end

	def price_with_tax
		tax_bracket(@tax_type)
	end

	def added_item
		CSV.open('../csv/product_item.csv', 'a', headers: true) do |file|
			file << [@item_quantity, @item_name, price_with_tax, @value_added_price]
		end
	end
	
	def sales_tax
		puts "--- Type  #{'basic_tax'.red} for basic tax: #{tax_added_price[:basic_tax]}"
		puts "--- Type  #{'import_duty_tax'.red} for imported product: #{tax_added_price[:import_duty_tax]}"
		puts "--- Type  #{'tax_exempt'.red} for tax exempt product #{tax_added_price[:tax_exempt]}"
		puts "--- Type  #{'imported_product_with_no_tax_exempt'.red} for imported product with no tax exempt #{tax_added_price[:imported_product_with_no_tax_exempt]}"
	end

	def terminal_output
		@table = Terminal::Table.new do |t|
			t.title = "Products"
			headings = ['item_quantity', 'item_name', 'item_price']
			t.headings = headings
			
			CSV.foreach('../csv/product_item.csv', headers: true) do |row|
				t.add_row [row[0], row[1], row[2]]
			end
			t.add_row :separator
			t.add_row ['Sales Taxes', { value: get_sale_tax, colspan: 2 }]
			t.add_row ['Total', { value: get_total, :colspan => 2 }]
		end
		
		puts @table
	end

	def get_sale_tax
		
		@tax_sale = []
		CSV.foreach('../csv/product_item.csv', headers: true) do |row|
			
			@tax_sale << row[3]
		end
		
		@get_sales_tax = ((@tax_sale.map(&:to_f)).sum).round(2)
	end

	def get_total
		@total = []
		CSV.foreach('../csv/product_item.csv', headers: true) do |row|
			@total << row[2]
			
		end
		@price_total = ((@total.map(&:to_f)).sum).round(2)
	
	end

end


product = Product.new
product.create_csv
puts "How many Item you want to add?".red
max_item = gets.to_i
max = max_item
max.times do
	puts "Add Items Name".red
	item_name = gets.chomp
	product.item_name = item_name
	puts "Add Items Quantity".red
	item_quantity = gets.to_i
	product.item_quantity = item_quantity
	puts "Add Items Price".red
	item_price = gets.to_f
	product.item_price = item_price
	puts "Select Tax bracket above".red
	product.sales_tax
	tax_choice = gets.chomp
	case tax_choice
		when 'basic_tax'
			product.tax_bracket('basic_tax')
			product.price_with_tax
		when 'import_duty_tax'
			product.tax_bracket('import_duty_tax')
			product.price_with_tax
		when 'imported_product_with_no_tax_exempt'
			product.tax_bracket('imported_product_with_no_tax_exempt')
			product.price_with_tax
		when 'tax_exempt'
			product.tax_bracket('tax_exempt')
			product.price_with_tax
	end

	product.added_item
end

puts product.terminal_output
