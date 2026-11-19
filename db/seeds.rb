# Прибираємо тестові товари з першого кроку
Product.where(name: [ "Product 1", "Product 2" ]).destroy_all

categories = [
  "Ігрові миші",
  "Клавіатури",
  "Навушники та гарнітури",
  "Геймпади",
  "Ігрові крісла",
  "Килимки для миші"
].index_with { |name| Category.find_or_create_by!(name: name) }

products = [
  { name: "ProStrike X1", category: "Ігрові миші", price: 1299, stock: 15,
    description: "Провідна ігрова миша з оптичним сенсором 16000 DPI та 6 програмованими кнопками." },
  { name: "AeroClick Wireless", category: "Ігрові миші", price: 1899, stock: 8,
    description: "Бездротова легка миша вагою 62 г, до 70 годин роботи від одного заряду." },
  { name: "MechaBlade K87", category: "Клавіатури", price: 2499, stock: 12,
    description: "Механічна клавіатура TKL з перемикачами, що замінюються, та RGB-підсвіткою." },
  { name: "SoundRift 7.1", category: "Навушники та гарнітури", price: 2199, stock: 10,
    description: "Ігрова гарнітура з віртуальним об'ємним звуком 7.1 та знімним мікрофоном." },
  { name: "PadMaster Pro", category: "Геймпади", price: 1499, stock: 20,
    description: "Бездротовий геймпад із вібровіддачею, сумісний із ПК та консолями." },
  { name: "ThroneGT Racing", category: "Ігрові крісла", price: 7999, stock: 4,
    description: "Ергономічне ігрове крісло з регульованою поперековою підтримкою та підлокітниками 4D." },
  { name: "GlideMat XL", category: "Килимки для миші", price: 499, stock: 40,
    description: "Великий килимок 900x400 мм з прошитими краями та гумовою основою." }
]

products.each do |attrs|
  product = Product.find_or_initialize_by(name: attrs[:name])
  product.update!(attrs.except(:category).merge(category: categories.fetch(attrs[:category])))
end
