const List<String> tablesCreationCommands = [
  '''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        email TEXT,
        password TEXT,
        phone TEXT,
        address TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
  ''',
  '''
      CREATE TABLE user_session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        access_token TEXT,
        expiry_date DATETIME,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        status TEXT DEFAULT 'active',
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
      )
  ''',
  '''
      CREATE TABLE showroom (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        showroom_id INTEGER,
        name TEXT,
        region TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
  ''',
  '''
      CREATE TABLE warehouse (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT,
        name TEXT,
        region TEXT,
        is_display BOOLEAN DEFAULT 0,
        is_store BOOLEAN DEFAULT 0,
        is_virtual BOOLEAN DEFAULT 0,
        is_sellable BOOLEAN DEFAULT 0,
        is_hq_store BOOLEAN DEFAULT 0,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
  ''',
  '''
      CREATE TABLE cart_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_code TEXT,
        quantity INTEGER,
        price REAL,
        initial_discount REAL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
  ''',
  '''
      CREATE TABLE cart_product_request (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cart_products_id INTEGER,
        tax_group TEXT DEFAULT NULL,
        warehouse_code TEXT DEFAULT NULL,
        pickup_location TEXT DEFAULT NULL,
        discount REAL DEFAULT 0,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (cart_products_id) REFERENCES cart_products(id) ON DELETE CASCADE
      )
  ''',
  '''
    CREATE TABLE cart_product_serial_number (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cart_products_id INTEGER,
      serial_number TEXT,
      status TEXT DEFAULT 'active',
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (cart_products_id) REFERENCES cart_products(id) ON DELETE CASCADE
    )
  ''',
  '''
      CREATE TABLE business_partners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        code TEXT,
        requires_customer_id BOOLEAN DEFAULT 0,
        requires_full_payment BOOLEAN DEFAULT 0,
        auto_print_receipt BOOLEAN DEFAULT 0,
        requires_partial_payment BOOLEAN DEFAULT 0,
        eligile_for_loyalty BOOLEAN DEFAULT 0,
        is_glovo BOOLEAN DEFAULT 0,
        status TEXT DEFAULT 'active',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
  ''',
  '''
      CREATE TABLE invoice_delivery_scan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT,
        status TEXT DEFAULT 'active',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
  ''',
  '''
      CREATE TABLE invoice_delivery_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_delivery_id INTEGER,
        item_code TEXT,
        serial_number TEXT,
        status TEXT DEFAULT 'active',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (invoice_delivery_id) REFERENCES invoice_delivery_scan(id) ON DELETE CASCADE
      )
  ''',
  '''
      CREATE TABLE purchase_order_receipt (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        po_number TEXT,
        status TEXT DEFAULT 'active',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
  ''',
  '''
      CREATE TABLE purchase_order_receipt_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_order_receipt_id INTEGER,
        item_code TEXT,
        scanned_quantity INTEGER DEFAULT 0,
        status TEXT DEFAULT 'active',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (purchase_order_receipt_id) REFERENCES purchase_order_receipt(id) ON DELETE CASCADE
      )
  ''',
  '''
      CREATE TABLE purchase_order_receipt_serial_numbers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_order_receipt_product_id INTEGER,
        serial_number TEXT,
        is_synced BOOLEAN DEFAULT 0,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (purchase_order_receipt_product_id) REFERENCES purchase_order_receipt_products(id) ON DELETE CASCADE
      )
  ''',
  '''
      CREATE TABLE sales_order_delivery_scan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sales_order_number TEXT,
        status TEXT DEFAULT 'active',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
  ''',
  '''
      CREATE TABLE sales_order_delivery_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sales_order_delivery_id INTEGER,
        item_code TEXT,
        serial_number TEXT,
        status TEXT DEFAULT 'active',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sales_order_delivery_id) REFERENCES sales_order_delivery_scan(id) ON DELETE CASCADE
      )
  ''',
  '''
      CREATE TABLE goods_issue_scan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goods_issue_number TEXT,
        status TEXT DEFAULT 'active',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
  ''',
  '''
      CREATE TABLE goods_issue_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goods_issue_id INTEGER,
        item_code TEXT,
        model_number TEXT,
        scanned_quantity INTEGER DEFAULT 0,
        status TEXT DEFAULT 'active',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (goods_issue_id) REFERENCES goods_issue_scan(id) ON DELETE CASCADE
      )
  ''',
  '''
      CREATE TABLE goods_issue_product_serial_numbers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goods_issue_product_id INTEGER,
        serial_number TEXT,
        is_synced BOOLEAN DEFAULT 0,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (goods_issue_product_id) REFERENCES goods_issue_products(id) ON DELETE CASCADE
      )
  ''',
  '''
      CREATE TABLE stock_transfer_scan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stock_transfer_number TEXT,
        status TEXT DEFAULT 'active',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
  ''',
  '''
      CREATE TABLE stock_transfer_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stock_transfer_id INTEGER,
        item_code TEXT,
        serial_number TEXT DEFAULT NULL,
        status TEXT DEFAULT 'active',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (stock_transfer_id) REFERENCES stock_transfer_scan(id) ON DELETE CASCADE
      )
  ''',
  '''
    CREATE TABLE physical_stock_take (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      status TEXT DEFAULT 'active',
      stock_count_number TEXT,
      stock_count_type TEXT,
      showroom_name TEXT,
      warehouse_name TEXT,
      warehouse_code TEXT,
      physical_stock_count_type_name TEXT,
      created_by INTEGER,
      created_by_name TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ''',
  '''
    CREATE TABLE physical_stock_take_products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      physical_stock_count_id INTEGER,
      barcode TEXT,
      item_code TEXT,
      item_name TEXT,
      item_group TEXT,
      item_brand TEXT,
      item_picture_name TEXT,
      model_number TEXT,
      scanned_quantity INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (physical_stock_count_id) REFERENCES physical_stock_take(id) ON DELETE CASCADE
    )
  ''',
  '''
    CREATE TABLE physical_stock_take_serial_numbers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      physical_stock_count_product_id INTEGER,
      serial_number TEXT,
      is_synced BOOLEAN DEFAULT 0,
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (physical_stock_count_product_id) REFERENCES physical_stock_take_products(id) ON DELETE CASCADE
    )
  ''',
];
