module "vpc" {
    source = "../vpc/"
    unity_instance = "${var.unity_instance}"
    availability_zone_1 = "${var.availability_zone_1}"
    availability_zone_2 = "${var.availability_zone_2}"
    resource_prefix = "${var.resource_prefix}"

    /* Module outputs:
    unity_vpc = module.vpc.unity_vpc
    subnet_id1 = module.vpc.public_subnet1
    subnet_id2 = module.vpc.public_subnet2 */
}

module "iam" {
    source = "./iam"
    resource_prefix = "${var.resource_prefix}"
}

module "log-group" {
    source = "./log-group"
    resource_prefix = "${var.resource_prefix}"

    depends_on = [
        module.iam
    ]
}

module "s3" {
    source = "./s3"
    resource_prefix = "${var.resource_prefix}"

    depends_on = [
        module.log-group
    ]
}

module "load_balancer" {
    source = "./load_balancer"
    resource_prefix = "${var.resource_prefix}"
    lb_logs_bucket_name = "${var.lb_logs_bucket_name}"
    lb_logs_bucket_prefix = "${var.lb_logs_bucket_prefix}"
    availability_zone_1 = "${var.availability_zone_1}"
    availability_zone_2 = "${var.availability_zone_2}"
    unity_vpc = module.vpc.unity_vpc
    subnet_id1 = module.vpc.public_subnet1
    subnet_id2 = module.vpc.public_subnet2

    depends_on = [
        module.s3,
        module.vpc
    ]
}

module "core" {
    source = "./core"
    resource_prefix = "${var.resource_prefix}"
    api_id = "${var.api_id}"
    api_parent_id = "${var.api_parent_id}"

    depends_on = [
        module.load_balancer
    ]
}

module "database" {
    source = "./database"
    unity_vpc = module.vpc.unity_vpc
    subnet_id1 = module.vpc.public_subnet1
    subnet_id2 = module.vpc.public_subnet2
    resource_prefix = "${var.resource_prefix}"
    db_snapshot = "${var.db_snapshot}"
    availability_zone_1 = "${var.availability_zone_1}"

    depends_on = [
        module.core
    ]
}

module "es-log-groups" {
    source = "./es-log-groups"
    resource_prefix = "${var.resource_prefix}"

    depends_on = [
        module.database
    ]
}

module "elasticsearch" {
    source = "./elasticsearch"
    resource_prefix = "${var.resource_prefix}"
    unity_vpc = module.vpc.unity_vpc
    private_subnet_id1 = module.vpc.private_subnet1

    depends_on = [
        module.es-log-groups
    ]
}
