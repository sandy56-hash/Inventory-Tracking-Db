+---------------+       +-------------------+       +---------------------+
|   suppliers   |       | product_categories|       |      products       |
+---------------+       +-------------------+       +---------------------+
| PK supplier_id|------>| PK category_id    |<------| PK product_id       |
|    name       |       |    name           |       |    sku              |
|    contact    |       |    description    |       |    name             |
|    email      |       | FK parent_category|       | FK category_id      |
|    phone      |       +-------------------+       | FK supplier_id      |
|    address    |                                   |    price            |
+---------------+                                   |    cost             |
                                                    |    quantity         |
+---------------+       +-------------------+       +---------------------+
|   warehouses  |       | inventory_locations|      | product_inventory   |
+---------------+       +-------------------+       +---------------------+
| PK warehouse_id|----->| PK location_id    |<------| CPK product_id      |
|    code        |      | FK warehouse_id   |       | CPK location_id     |
|    name        |      |    code           |       |    quantity         |
|    location    |      |    capacity       |       +---------------------+
|    capacity    |      +-------------------+
+---------------+                                   +---------------------+
                                                    | inventory_movements |
+---------------+       +-------------------+       +---------------------+
|   customers   |       |  purchase_orders  |       | PK movement_id      |
+---------------+       +-------------------+       | FK product_id       |
| PK customer_id|       | PK po_id          |       | FK from_location_id |
|    name       |       | FK supplier_id    |<------| FK to_location_id   |
|    contact    |       |    order_date     |       |    quantity         |
|    email      |       |    status         |       |    type             |
|    phone      |       +-------------------+       +---------------------+
+---------------+                                   +---------------------+
                                                    | purchase_order_items|
+---------------+       +-------------------+       +---------------------+
|     users     |       |   sales_orders    |       | CPK po_id           |
+---------------+       +-------------------+       | CPK product_id      |
| PK user_id    |       | PK so_id          |       |    quantity         |
|    username   |       | FK customer_id    |<------|    price            |
|    password   |       |    order_date     |       +---------------------+
|    role       |       |    status         |
+---------------+       +-------------------+
                                                    +---------------------+
                                                    |  sales_order_items  |
                                                    +---------------------+
                                                    | CPK so_id           |
                                                    | CPK product_id      |
                                                    |    quantity         |
                                                    |    price            |
                                                    +---------------------+
