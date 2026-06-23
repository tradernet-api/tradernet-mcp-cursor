---
name: tn-mcp-refresh-sid
description: Обновляет сессию SID для Tradernet MCP через auth_by_login и записывает её в .cursor/tn-session.env. Применять при ошибке 401 Invalid credentials на SID-инструментах (get_sid_info и др.), при истёкшей сессии или просьбе «обнови SID / переавторизуйся в TN».
---

# tn-mcp-refresh-sid — обновление SID Tradernet MCP

Сессионные инструменты (`get_sid_info`, сессионные операции) требуют валидный
`X-TN-SID`. SID живёт ~14 дней и протухает — тогда приходит
`401 Invalid credentials`. Этот скилл — runbook переавторизации.

## Когда применять

- `401 Invalid credentials` на SID-инструменте.
- Пользователь просит «обнови SID», «переавторизуйся в TN», «session expired».
- Перед серией сессионных вызовов, если SID давно не обновлялся.

## Чего НЕ делать

- Не печатать пароль/логин в чат или через `echo`.
- Не вписывать SID в `mcp.json` — только в `.cursor/tn-session.env`.
- HMAC-инструменты (`portfolio_get`, `quotes_get`) SID не требуют — для них
  переавторизация не нужна, проверь канал (см. правило `tn-mcp-auth`).

## Шаги

1. Убедись, что заданы `TN_LOGIN` / `TN_PASSWORD` в окружении пользователя
   (`~/.config/tn-mcp/credentials.env`). Если нет — попроси пользователя их
   настроить, не запрашивай пароль в открытом виде.

2. Вызови инструмент `auth_by_login` с аргументами (значения берутся из env
   пользователя, не хардкодить):

   ```json
   { "login": "<TN_LOGIN>", "password": "<TN_PASSWORD>", "remember_me": 1 }
   ```

3. Из ответа возьми `SID` и перезапиши `.cursor/tn-session.env` (одна строка):

   ```bash
   printf 'export TN_SID="%s"\n' "<SID>" > .cursor/tn-session.env
   ```

4. (Опционально) обнови метаданные `.cursor/tn-session.json`:

   ```json
   {
     "sid": "<SID>",
     "userId": <id>,
     "logged": true,
     "logged_at": "<ISO-8601>",
     "remember_me": true
   }
   ```

5. Подхвати окружение и перезагрузи MCP-клиент (Cursor читает `${env:TN_SID}`
   только при старте):

   ```bash
   source ~/.config/tn-mcp/credentials.env
   source .cursor/tn-session.env
   ```

   Затем **Reload Window** в Cursor, либо перезапуск:
   - macOS: `open -a Cursor .`
   - Linux / Windows: `cursor .`

6. Проверка: вызови `get_sid_info` — должен вернуть данные сессии без `401`.

## Если снова 401

- Повтори шаги 2–6 (SID мог не подхватиться без Reload Window).
- На публичном endpoint при `code: 30` в `auth_by_login` — попробуй внутренний
  endpoint, если он доступен пользователю.
- Проверь, что `TN_LOGIN` / `TN_PASSWORD` актуальны (смена пароля инвалидирует
  старые сессии).
