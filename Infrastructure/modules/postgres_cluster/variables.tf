variable "project_id" {
    description = "The ID of the project in which resources will be provisioned."
    type        = string
}

variable "region" {
    type        = string
    description = "Region for GKE cluster"
}

variable "zones" {
    type        = list
    description = "Zones (in the above region) for GKE cluster"
}

variable "num_instances" {
    type        = number
    description = "Number of instances in instance group"
}


variable "min_cpu_instances"{ type=number }
variable "max_cpu_instances"{ type=number }
variable "min_memory_instances"{ type=number }
variable "max_memory_instances"{ type=number }