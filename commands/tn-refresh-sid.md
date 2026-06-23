---
name: tn-refresh-sid
description: Переавторизоваться в Tradernet MCP и обновить SID в .cursor/tn-session.env.
---

# /tn-refresh-sid — обновить SID Tradernet MCP

Запусти скилл `tn-mcp-refresh-sid` и следуй его runbook'у:

1. `auth_by_login` с `login` / `password` из env (`TN_LOGIN` / `TN_PASSWORD`)
   и `remember_me: 1`.
2. Записать полученный SID в `.cursor/tn-session.env`.
3. `source` env + Reload Window / перезапуск Cursor.
4. Проверить `get_sid_info`.

Не печатать пароль и SID в чат. Подробности и обработка ошибок — в скилле
`tn-mcp-refresh-sid`.
