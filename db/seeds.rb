Product.find_or_create_by!(name: "Product 1") do |p|
  p.description = "Опис першого товару"
  p.price = 199.99
  p.stock = 10
end

Product.find_or_create_by!(name: "Product 2") do |p|
  p.description = "Опис другого товару"
  p.price = 349.50
  p.stock = 5
end
