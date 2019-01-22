variable "do_token" {}

variable "ssh_key_path" {
    default = "~/.ssh/id_rsa"
}

variable "prom_image" {
    default = "ubuntu-18-04-x64"
}

variable "prom_size" {
    default = "s-1vcpu-1gb"
}

variable "scrape_address" {}
variable "job_name" {
    default = "default"
}
