# Jupyter Server configuration for Paperspace Gradient
# Adds a Launcher entry to start Forge Neo via jupyter-server-proxy.

c = get_config()  # noqa

c.ServerProxy.servers = {
    "forge-neo": {
        "command": ["/usr/local/bin/start-forge.sh"],
        "timeout": 60,
        "launcher_entry": {
            "title": "Stable Diffusion Forge Neo",
            "icon_path": "",
        },
        "port": 7860,
        "absolute_url": False,
        "new_browser_tab": True,
    }
}
