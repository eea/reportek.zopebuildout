[Unit]
Description=${parts.configuration['data-registry']} data registry
After=network.target

[Service]
Type=forking
ExecStart=${parts.buildout['bin-directory']}/portalctl start
ExecStop=${parts.buildout['bin-directory']}/portalctl stop
ExecReload=${parts.buildout['bin-directory']}/portalctl restart

[Install]
WantedBy=multi-user.target
