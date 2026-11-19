class AddCategoryToProducts < ActiveRecord::Migration[8.1]
  def up
    # 1. Додаємо стовпець, поки що дозволяючи порожні значення
    add_reference :products, :category, foreign_key: true

    # 2. Якщо вже є товари, створюємо для них категорію-заглушку
    if select_value("SELECT COUNT(*) FROM products").to_i > 0
      execute <<~SQL
        INSERT INTO categories (name, created_at, updated_at)
        VALUES ('Без категорії', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      SQL
      execute <<~SQL
        UPDATE products
        SET category_id = (SELECT id FROM categories WHERE name = 'Без категорії')
      SQL
    end

    # 3. Тепер, коли всі товари мають категорію, забороняємо порожні значення
    change_column_null :products, :category_id, false
  end

  def down
    remove_reference :products, :category, foreign_key: true
  end
end
