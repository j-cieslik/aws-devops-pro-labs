#!/bin/bash
# Daj aplikacji do 20 sekund na start; jeśli /health nie odpowie, wdrożenie na tym serwerze się nie uda.
for i in $(seq 1 20); do
  if curl -sf http://localhost:3000/health > /dev/null; then
    echo "Aplikacja odpowiada"
    exit 0
  fi
  sleep 1
done
echo "Aplikacja nie odpowiada na /health"
exit 1
