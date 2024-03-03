# Wake-up Reverse Proxy

![Logo](./logo.png)

> "Ever wanted to bring that old feel rural morning call to your server insfrastructure? This libary is for you!"

## What is this?

A simple http reverse proxy with support for custom wake commands.

Allow you to reduce server power usage while still making it available for daily use.

## Use cases:

An example usecase would be having:
- A low power mini-pc / SBC running 24/7 (this could be as simple as a raspberry-pi)
- A power hungry PC or Server (such as older enterprise hardware) which is expensive to run full-time

This simple app allows you to:
- Serve a simple redirect page while the host is off 
- Wake the host
- When the host is on, redirect to the actual webpage

Example:
I currently use this for my old HP Proliant G8 which idles at 70 watts but still packs a (modest) punch and is still great server hardware.
I'd be crazy to run it 24/7 though, even with relatively modest electricity prices, it would easily cost more than it's worth in electricity over a simgle year of runtime.
I have another server running securcity cameras that can easily be used to host this app and wake the server as needed.

## How to use:

Set the environment variables in docker-compose.yaml to suit your usecase.

Most likely, you will have something like:
```
WAKE_CMD: 'wakeonlan {SERVER MAC ADDRESS}'  # This can be anything you want, the default uses the hpilo library based on my personal usecase.
WAKE_CMD_MAX_FREQ: 1  # Limit to 1 CMD/s
DESTINATION_URL: {(local) URL to redirect to on wake}
```

Once you have set the above in your compose file, simply deploy it using*: `docker compose up --build`

*Note: Prebuilt images maybe be available in the future

### helper scripts

Here you can find scripts that help manage server behavior  to go with this app: [link](server_tools/README.md)
