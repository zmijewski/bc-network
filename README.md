# About the project

Hello World!

`bc-network` is an implementation of very naive and simple blockchain network. I started building it to learn and understand basic concepts. The current solution uses proof of work algorithm to process transactions.

Some architectural decisions are going to be placed in `docs` folder so you could better understand why I made it this way.

The application is consisting of two systems:
* monitoring (built with loki/fluent-bit/grafana)
* blockchain (discovery node + full nodes)

## How to run it

### 0. Prerequisite

In order to run the application you need to have `docker` and `docker-compose` installed.

I am running this setup on my machines using:
* Docker version 20.10.5, build 55c4c88
* docker-compose version 1.29.0, build 07737305

### 1. Run monitoring and blockchain

Run this command in terminal:
```sh
make run
```
Make command will clean an old and create a fresh setup for your containers.
Open your web browser and enter Grafana http://localhost:3000. Log in with given credentials:
* username: admin
* password: admin

After login in you will be asked to change the password but you may skip it. Go to your
Grafana dashboard in your browser and choose dashboard `Blockchain network`. From there, you should
start seeing Grafana populate with data from the blockchain.

![dashboard image](docs/images/dashboard.png "Dashboard")

To check queue logs enter

```
http://localhost:15672/
```
