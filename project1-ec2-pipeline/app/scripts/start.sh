#!/bin/bash
set -e
# Zarejestruj aplikację jako usługę systemową (odpowiednik usługi Windows) i ją uruchom.
cat > /etc/systemd/system/myapp.service <<'EOF'
[Unit]
Description=Lab app
After=network.target

[Service]
ExecStart=/usr/bin/node /opt/app/server.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable myapp
systemctl restart myapp
