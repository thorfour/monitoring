# monitoring
Terraform packages to deploy monitoring software in the cloud


## Monitoring Packages

### [Prometheus](https://prometheus.io)

`make prometheus`

This will create a node on DigitalOcean that containes a prometheus instance with grafana using it as a datasource.
It will also place it behind a proxy and can only be accessed by the password you provide
