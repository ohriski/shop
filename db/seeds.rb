# Способи доставки
[
  { name: "Нова пошта (відділення)", price: 60, requires_address: true },
  { name: "Кур'єр", price: 100, requires_address: true },
  { name: "Самовивіз", price: 0, requires_address: false }
].each do |attrs|
  DeliveryMethod.find_or_create_by!(name: attrs[:name]) { |d| d.assign_attributes(attrs) }
end

# Адміністратор: дані зі змінних середовища, у репозиторій не потрапляють
if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
  User.find_or_create_by!(email_address: ENV["ADMIN_EMAIL"]) do |user|
    user.password = ENV["ADMIN_PASSWORD"]
    user.admin = true
  end
end

# Демо-каталог з db/seed_data (створюється командою rails seed:export)
catalog_file = Rails.root.join("db", "seed_data", "products.yml")

if catalog_file.exist?
  YAML.safe_load_file(catalog_file).each do |attrs|
    next if Product.exists?(name: attrs["name"])

    product = Product.new(
      category: Category.find_or_create_by!(name: attrs["category"]),
      name: attrs["name"],
      description: attrs["description"],
      price: attrs["price"],
      stock: attrs["stock"]
    )

    if attrs["image"]
      image_path = Rails.root.join("db", "seed_data", "images", attrs["image"])
      if image_path.exist?
        product.image.attach(io: StringIO.new(File.binread(image_path)), filename: attrs["image"])
      end
    end

    product.save!
  end
end
