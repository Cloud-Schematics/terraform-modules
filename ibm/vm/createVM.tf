################################################################
# Module to deploy an VM with specified applications installed
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2017.
#
################################################################
variable "hostname" {
  default = "hostname"
}

variable "domain" {
  default = "domain.dev"
}

variable "datacenter" {
  default = "wdc01"
}

variable "os_reference_code" {
  default = "CENTOS_7"
}

variable "cores" {
  default = "1"
}

variable "memory" {
  default = "1024"
}

variable "disk_size" {
  default = "25"
}

variable "private_network_only" {
  default = "false"
}

variable "network_speed" {
  default = "100"
}

variable "tags" {
  default = ""
}

variable "ssh_user" {
  default     = "root"
  description = "default user for VM"
}

variable "ssh_label" {
  default = "public ssh key - Schematics VM"
}

variable "ssh_notes" {
  default = ""
}

variable "public_key" {
  description = "public SSH key to use in keypair"
}

variable "private_key" {}

variable "install_script" {
  default     = "files/default.sh"
  description = "installation script path"
}

variable "script_variables" {
  default     = ""
  description = "variables to pass into script"
}

variable "sample_application_url" {
  default     = ""
  description = "sample application URL"
}

variable "custom_commands" {
  default     = "sleep 1"
  description = "custom commands to run"
}

resource "ibm_compute_ssh_key" "ssh_key" {
  label      = "${var.ssh_label}"
  notes      = "${var.ssh_notes}"
  public_key = "${var.public_key}"
}

resource "ibm_compute_vm_instance" "vm" {
  hostname                 = "${var.hostname}"
  os_reference_code        = "${var.os_reference_code}"
  domain                   = "${var.domain}"
  datacenter               = "${var.datacenter}"
  network_speed            = "${var.network_speed}"
  hourly_billing           = true
  private_network_only     = "${var.private_network_only}"
  cores                    = "${var.cores}"
  memory                   = "${var.memory}"
  disks                    = ["${var.disk_size}"]
  dedicated_acct_host_only = true
  local_disk               = false
  ssh_key_ids              = ["${ibm_compute_ssh_key.ssh_key.id}"]
  tags                     = ["${var.tags}"]

  connection {
    user        = "${var.ssh_user}"
    private_key = "${var.private_key}"
  }

  # Create the installation script
  provisioner "file" {
    source      = "${path.module}/${var.install_script}"
    destination = "installation.sh"
  }

  # Execute the script remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x installation.sh",
      "bash installation.sh ${var.sample_application_url} ${var.script_variables}",
      "${var.custom_commands}",
    ]
  }
}

output "public_ip" {
  value = "http://${ibm_compute_vm_instance.vm.ipv4_address}"
}
