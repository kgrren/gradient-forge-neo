c = get_config()

c.ServerProxy.servers = {
    'forge': {
        'command': [
            '/bin/bash', '-c',
            # Forge Neoの起動コマンド (uv使用, ポート7860, プロキシ設定)
            # 仮想環境がなければ作成し、あれば使うロジックは ipynb 側ではなくここで吸収しても良いが
            # 今回は「環境のみ提供」なので、単純にリッスンポートへの転送を定義する
            'echo "Forge Neo should be started from Notebook"'
        ],
        'port': 7860,
        'timeout': 120,
        'absolute_url': False,
        'launcher_entry': {
            'enabled': True,
            'title': 'Forge Neo (Port 7860)',
            # アイコンのパスを指定可能 (任意)
        }
    }
}

# 起動時のセキュリティトークンを無効化（PaperspaceではURL認証があるため）
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.disable_check_xsrf = True
