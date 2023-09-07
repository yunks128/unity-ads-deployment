module "iam" {
    source = "./iam"
    unity_instance = "${var.unity_instance}"
    resource_prefix = "${var.resource_prefix}"
    api_id = "${var.api_id}"
    api_parent_id = "${var.api_parent_id}"
    availability_zone_1 = "${var.availability_zone_1}"
    availability_zone_2 = "${var.availability_zone_2}"
}

module "log-group" {
    source = "./log-group"
    unity_instance = "${var.unity_instance}"
    resource_prefix = "${var.resource_prefix}"
    api_id = "${var.api_id}"
    api_parent_id = "${var.api_parent_id}"
    availability_zone_1 = "${var.availability_zone_1}"
    availability_zone_2 = "${var.availability_zone_2}"

    depends_on = [
        module.iam
    ]
}

module "s3" {
    source = "./s3"
    unity_instance = "${var.unity_instance}"
    resource_prefix = "${var.resource_prefix}"
    availability_zone_1 = "${var.availability_zone_1}"
    availability_zone_2 = "${var.availability_zone_2}"
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
    lb_logs_bucket_name = "${var.lb_logs_bucket_name}"
    lb_logs_bucket_prefix = "${var.lb_logs_bucket_prefix}"
    availability_zone_1 = "${var.availability_zone_1}"
    availability_zone_2 = "${var.availability_zone_2}"

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
    availability_zone_1 = "${var.availability_zone_1}"
    availability_zone_2 = "${var.availability_zone_2}"

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
    db_snapshot = "${var.db_snapshot}"
    availability_zone_1 = "${var.availability_zone_1}"
    availability_zone_2 = "${var.availability_zone_2}"

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
    availability_zone_1 = "${var.availability_zone_1}"
    availability_zone_2 = "${var.availability_zone_2}"

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
    availability_zone_1 = "${var.availability_zone_1}"
    availability_zone_2 = "${var.availability_zone_2}"

    depends_on = [
        module.es-log-groups
    ]
}
