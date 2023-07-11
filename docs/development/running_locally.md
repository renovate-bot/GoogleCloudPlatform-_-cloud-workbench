


## Start backend service

Configure catalog repositories location:
```bash
vim cloud-run/config/env
```

Start backend service:
```bash
cd cloud-run
dart run lib/server.dart
```

## Front End

If you're debugging in the IDE make sure your debug profile is adding the following arguments

```sh
--dart-define=CLOUD_PROVISION_API_URL=localhost:8080
```

for VSCode your `launch.json` file should look similar to this:

```json
        {
            "name": "cloudprovisionui",
            "cwd": "ui/cloudprovisionui",
            "request": "launch",
            "type": "dart",
            "args": ["--dart-define=CLOUD_PROVISION_API_URL=localhost:8080"]
        },
```

To start the front end from the command line execute the following:

```bash
cd ui/cloudprovisionui

flutter run lib/main.dart \
    -d chrome \
    --web-port=5000 \
    --dart-define=CLOUD_PROVISION_API_URL=localhost:8080
```

For command above, add 'localhost:5000' to Authorized JavaScript origins under OAuth 2.0 Client in Cloud Console [APIs & Services, Credentials](https://console.cloud.google.com/apis/credentials). 

[Home](../README.md)