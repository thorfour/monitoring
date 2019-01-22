provider "digitalocean" {
    token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "default" {
    name = "default"
    public_key = "${file("${var.ssh_key_path}.pub")}"
}

data "template_file" "prom_config" {
    template = "${file("prom.yml")}"

    vars {
        scrape = "${var.scrape_address}"
        job_name = "${var.job_name}"
    }
}

# prometheus
resource "digitalocean_droplet" "prometheus" {
    image = "${var.prom_image}"
    name = "prometheus"
    region = "nyc3"
    size = "${var.prom_size}"
    monitoring = true
    ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]
    tags = ["terraform", "prometheus"]

    provisioner "file" {
        content = "${data.template_file.prom_config.rendered}"
        destination = "/etc/prom.yml"

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("${var.ssh_key_path}")}"
        }
    }

    provisioner "file" {
        source = "datasource.yaml"
        destination = "/opt/datasource.yaml"

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("${var.ssh_key_path}")}"
        }
    }

    provisioner "file" {
        source = "passwords"
        destination = "/etc/passwords"

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("${var.ssh_key_path}")}"
        }
    }

    provisioner "file" {
        source = "nginx.conf"
        destination = "/etc/nginx.conf"

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("${var.ssh_key_path}")}"
        }
    }

    provisioner "file" {
        source = "docker-compose.yml"
        destination = "/etc/docker-compose.yml"

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("${var.ssh_key_path}")}"
        }
    }

    provisioner "remote-exec" {
        script = "docker.sh"

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("${var.ssh_key_path}")}"
        }
    }

    provisioner "remote-exec" {
        inline = [
            "cd /etc/",
            "docker-compose up -d"
        ]

        connection {
            type = "ssh"
            user = "root"
            private_key = "${file("${var.ssh_key_path}")}"
        }
    }
}

# Firewall all resources
resource "digitalocean_firewall" "promtheus" {
    name = "prometheus-auth-proxy-only"

    tags = ["prometheus"]

    inbound_rule = [
    {
        protocol = "tcp"
        port_range = "22"
        source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
        protocol = "tcp"
        port_range = "80"
        source_addresses = ["0.0.0.0/0", "::/0"]
    },
    ]

    outbound_rule = [
    {
        protocol = "tcp"
        port_range = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
        protocol = "udp"
        port_range = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
        protocol = "icmp"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    ]
}


output "monitor_ip" {
    value = "${digitalocean_droplet.prometheus.ipv4_address}"
}
