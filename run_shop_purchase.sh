#!/bin/bash

# --- Konfiguriere Werte ---
PRODUCT_NAME="Cooles Produkt"
PRODUCT_PRICE=19.99
PRODUCT_ID=1        # Die ID wird beim ersten Produkt meistens 1 sein (siehe Annahme unten)
QUANTITY=2
PAYMENT_METHOD="credit_card"

# --- 1. Produkt im Product-Service anlegen ---
echo "Lege Produkt an..."
CREATE_PRODUCT_RESPONSE=$(curl -s -X POST http://localhost:8004/products \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$PRODUCT_NAME\", \"price\": $PRODUCT_PRICE}")

echo "Response Product-Service:"
echo "$CREATE_PRODUCT_RESPONSE" | jq

# Extrahiere product_id aus der Antwort (fallback auf 1)
NEW_PRODUCT_ID=$(echo "$CREATE_PRODUCT_RESPONSE" | jq -r '.id // 1')
echo "Benutze product_id: $NEW_PRODUCT_ID"

# --- 2. Kaufprozess im Shop-Service auslösen ---
echo "Starte Kaufprozess im Shop-Service..."
PURCHASE_RESPONSE=$(curl -s -X POST http://localhost:8004/shop/purchase \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": $NEW_PRODUCT_ID, \"quantity\": $QUANTITY, \"payment_method\": \"$PAYMENT_METHOD\"}")

echo "Response Shop-Service:"
echo "$PURCHASE_RESPONSE" | jq

