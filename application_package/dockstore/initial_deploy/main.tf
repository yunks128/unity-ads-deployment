
module "iam" {
    source = "./iam"
    unity_instance = "${var.unity_instance}"
    resource_prefix = "${var.resource_prefix}"
    api_id = "${var.api_id}"
    api_parent_id = "${var.api_parent_id}"
}

module "log-group" {
    source = "./log-group"
    unity_instance = "${var.unity_instance}"
    resource_prefix = "${var.resource_prefix}"
    api_id = "${var.api_id}"
    api_parent_id = "${var.api_parent_id}"

    depends_on = [
        module.iam
    ]
}

module "s3" {
    source = "./s3"
    unity_instance = "${var.unity_instance}"
    resource_prefix = "${var.resource_prefix}"
    api_id = "${var.api_id}"
    api_parent_id = "${var.api_parent_id}"

    depends_on = [
        module.log-group
    ]
}


module "load_balancer" {
    source = "./load_balancer"
    unity_instance = "${var.unity_instance}"
    resource_prefix = "${var.resource_prefix}"
    api_id = "${var.api_id}"
    api_parent_id = "${var.api_parent_id}"

    depends_on = [
        module.s3
    ]
}


module "core" {
    source = "./core"
    unity_instance = "${var.unity_instance}"
    resource_prefix = "${var.resource_prefix}"
    api_id = "${var.api_id}"
    api_parent_id = "${var.api_parent_id}"

    depends_on = [
        module.load_balancer
    ]
}

module "database" {
    source = "./database"
    unity_instance = "${var.unity_instance}"
    resource_prefix = "${var.resource_prefix}"
    api_id = "${var.api_id}"
    api_parent_id = "${var.api_parent_id}"

    depends_on = [
        module.core
    ]
}

module "es-log-groups" {
    source = "./es-log-groups"
    unity_instance = "${var.unity_instance}"
    resource_prefix = "${var.resource_prefix}"
    api_id = "${var.api_id}"
    api_parent_id = "${var.api_parent_id}"

    depends_on = [
        module.database
    ]
}

module "elasticsearch" {
    source = "./elasticsearch"
    unity_instance = "${var.unity_instance}"
    resource_prefix = "${var.resource_prefix}"
    api_id = "${var.api_id}"
    api_parent_id = "${var.api_parent_id}"
    
    depends_on = [
        module.es-log-groups
    ]
}



