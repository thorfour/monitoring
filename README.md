# monitoring
Terraform packages to deploy monitoring software in the cloud


## Monitoring Packages

Before running any of the make packages below, you must first run `MONITOR_PW=<your_password> make password`

### [Prometheus](https://prometheus.io)

`make prometheus`

This will create a node on DigitalOcean that contains a prometheus instance with [grafana](https://grafana.com/) using it as a datasource.
It will also place it behind an [nginx](https://nginx.com/) proxy that can only be accessed by the password you provided in the above step.

Terraform will printout an ip address after it's finished, navigate to that address in a web browser to access your grafana instance.
