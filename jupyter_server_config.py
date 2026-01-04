c = get_config()

c.ServerProxy.servers = {
    'forge': {
        'command': ['echo', 'Forge Neo started'],
        'port': 7860,
        # absolute_url を True に変更し、Jupyter側にベースパスを維持させます
        'absolute_url': True, 
        'launcher_entry': {
            'enabled': True,
            'title': 'Forge Neo',
        }
    }
}

# Paperspace/Gradioの通信を許可するための設定を追加
c.ServerApp.allow_origin = '*'
c.ServerApp.tornado_settings = {
    'headers': {
        'Content-Security-Policy': "frame-ancestors 'self' *",
        'Access-Control-Allow-Origin': '*'
    }
}
