namespace :seed do
  desc "Зберігає товари з локальної бази у db/seed_data (YAML + фото)"
  task export: :environment do
    dir = Rails.root.join("db", "seed_data")
    FileUtils.mkdir_p(dir.join("images"))

    data = Product.includes(:category, image_attachment: :blob).order(:id).map do |product|
      entry = {
        "category" => product.category.name,
        "name" => product.name,
        "description" => product.description,
        "price" => product.price.to_s("F"),
        "stock" => product.stock
      }

      if product.image.attached?
        filename = "#{product.id}#{product.image.filename.extension_with_delimiter}"
        File.binwrite(dir.join("images", filename), product.image.download)
        entry["image"] = filename
      end

      entry
    end

    File.write(dir.join("products.yml"), data.to_yaml)
    puts "Експортовано товарів: #{data.size}"
  end
end
