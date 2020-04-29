# Pusher

## Формат пушей:

У всех пушей 5 приоритет.

*Silent push (apns-push-type=background):*

```json
{
    "aps":  {
        "content-available":1
    },
    "data": {
       "count":2
   }
}
```

*Alert push (apns-push-type=alert):*

```json
{
    "aps":  {
        "alert": {
            "title":"Pusher",
            "body":"у вас X сообщений"
            },
        "mutable-content": 1
    }
}
```
