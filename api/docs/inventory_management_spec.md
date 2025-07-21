# Inventory Management Spec

## Overview

This spec describes the requirements and acceptance criteria for the inventory management feature in the Pattern Maker app.

## Acceptance Criteria

1. **Add to Inventory from Catalog**

   - Users must be able to add items to their inventory from:
     - The catalog list page (bulk or single add)
     - The individual product (bead) detail page

2. **Custom Inventory Fields & Notes**

   - Users can add custom fields and notes to each inventory item.
   - Custom fields are stored as a JSON object in the database.
   - Each custom field is represented as a JSON object with:

     - `fieldName` (string): The key for the field (e.g., "purchase_date")
     - `fieldType` (string): The type of field (e.g., "text", "number", "date", "select")
     - `label` (string): The user-facing label (e.g., "Purchase Date")
     - `value` (any): The value for this field (type depends on `fieldType`)

   - Example JSON for custom fields:
     ```json
     [
       {
         "fieldName": "purchase_date",
         "fieldType": "date",
         "label": "Purchase Date",
         "value": "2024-07-15"
       },
       {
         "fieldName": "location",
         "fieldType": "text",
         "label": "Storage Location",
         "value": "Drawer 2"
       },
       {
         "fieldName": "quantity",
         "fieldType": "number",
         "label": "Quantity",
         "value": 50
       }
     ]
     ```

## Out of Scope

- Inventory sharing between users
- Inventory analytics or reporting
- Barcode/QR code scanning

## Open Questions

- Should users be able to edit/delete custom fields after creation?
- Should there be any validation on field types/values?
- Should there be a limit to the number of custom fields?

---

_Last updated: 2024-07-15_
