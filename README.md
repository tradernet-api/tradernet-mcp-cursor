# Tradernet MCP — Cursor plugin

Подключает Cursor к API Tradernet через [Model Context Protocol](https://modelcontextprotocol.io/)
по Streamable HTTP. После установки агент получает ~61 инструмент: котировки,
портфель, заявки, тарифы, отчёты и др.

> Все операции выполняются в **реальном аккаунте Tradernet** — с реальными
> данными, заявками и деньгами. Используйте отдельный тест-аккаунт.

## Что внутри

| Компонент | Файл | Назначение |
|-----------|------|------------|
| MCP-сервер | `mcp.json` | сервер `TN` → `https://tradernet.com/mcp/tn` (заголовки через `${env:...}`) |
| Rules | `rules/*.mdc` | безопасность секретов, HMAC vs SID, формат данных и осторожность с write/trade |
| Skill | `skills/tn-mcp-refresh-sid/` | runbook обновления SID после `auth_by_login` |
| Commands | `commands/` | `/tn-connect` (дымовая проверка), `/tn-refresh-sid` |
| Hook | `hooks/hooks.json` + `scripts/guard-write-tools.sh` | подтверждение перед write/trade-инструментами |

## Требования

1. Аккаунт Tradernet с доступом к API.
2. Пара API-ключей — [tradernet.com/tradernet-api/auth-api](https://tradernet.com/tradernet-api/auth-api)
   (`apiSecret` показывается один раз).
3. Cursor с поддержкой Streamable HTTP MCP.

## Секреты (только в env, не в плагине)

Плагин содержит лишь плейсхолдеры `${env:...}`. Ключи задаёт пользователь.

`~/.config/tn-mcp/credentials.env` (chmod 600):

```bash
export TN_API_KEY="your-apiKey"
export TN_API_SECRET="your-apiSecret"
export TN_LOGIN="user@example.com"     # опционально, для auth_by_login
export TN_PASSWORD="your-password"     # опционально
```

Подключение в `~/.zshrc`:

```bash
[ -f ~/.config/tn-mcp/credentials.env ] && source ~/.config/tn-mcp/credentials.env
```

`TN_SID` (опционально) — в `.cursor/tn-session.env`, обновляется скиллом
`tn-mcp-refresh-sid`. Cursor читает `${env:...}` при старте, поэтому после смены
переменных нужен `source` + перезапуск/Reload Window.

## Установка

### Локально (для теста и внутренних команд)

```bash
ln -s /absolute/path/to/tradernet-mcp ~/.cursor/plugins/local/tradernet-mcp
chmod +x ~/.cursor/plugins/local/tradernet-mcp/scripts/guard-write-tools.sh
```

Затем Reload Window (или перезапуск Cursor). Проверь, что в Settings → MCP
появился сервер `TN`, а в Rules — правила `tn-mcp-*`.

### Marketplace

Плагин распространяется как git-репозиторий и проходит ручную проверку Cursor.
Submit: [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish).
Для публичного Marketplace репозиторий должен быть open-source.

## Быстрый старт после установки

1. Задай секреты (см. выше) и перезапусти Cursor из терминала после `source`.
2. Выполни `/tn-connect` — дымовая проверка канала.
3. При необходимости SID — `/tn-refresh-sid`.

## Безопасность

- Секреты никогда не попадают в плагин, конфиг или чат — только env.
- Hook `beforeMCPExecution` (`failClosed: true`) требует подтверждения перед
  `orders_put`, `orders_delete`, `orders_set_stop_loss`, `tariff_select`,
  изменением списков/алертов и `auth_by_login`.
- Read-инструменты (котировки, портфель, отчёты) проходят без задержки.

## Лицензия

MIT.
