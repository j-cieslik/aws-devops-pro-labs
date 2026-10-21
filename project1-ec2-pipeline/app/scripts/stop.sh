#!/bin/bash
# Zatrzymaj aplikację, jeśli działa (przy pierwszym wdrożeniu jej jeszcze nie ma).
systemctl stop myapp 2>/dev/null || true
