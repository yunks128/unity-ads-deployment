resource "aws_cloudformation_stack" "dockstore_app" {
  name = "awsAppDockstoreStack"

  disable_rollback = true

  parameters = {
    ResourcePrefix = "${var.resource_prefix}"
    VpcId = data.aws_vpc.unity_vpc.id
    SubnetId = tolist(data.aws_subnets.unity_private_subnets.ids)[0]
    AvailabilityZone = "${var.availability_zone}"
    AutoUpdate = "${var.auto_update}"
    LoadBalancerStack = "awsLBDockstoreStack"
    CoreStack = "awsCoreDockstoreStack"
    S3Stack = "awsS3DockstoreStack"
    RdsStack = "awsDbDockstoreStack"
    ElasticsearchStack = "awsEsDockstoreStack"
    ComposeSetupVersion = "${var.compose_setup_version}"
    DockstoreDeployVersion = "${var.dockstore_deploy_version}"
    UiVersion = "${var.uiversion}"
    GalaxyPluginVersion = "${var.galaxy_plugin_version}" 
    ENIPrivateIP = "${var.eni_private_ip}"

    #These inputs are AWS Session Manager Parameter Store paths
    AuthorizerType =  "/DeploymentConfig/${var.resource_prefix}/AuthorizerType"
    BdCatalystSevenBridgesImportUrl = "/DeploymentConfig/${var.resource_prefix}/BdCatalystSevenBridgesImportUrl"
    BdCatalystTerraImportUrl = "/DeploymentConfig/${var.resource_prefix}/BdCatalystTerraImportUrl"
    BitbucketClientId = "/DeploymentConfig/${var.resource_prefix}/BitbucketClientId"
    BitbucketClientSecret = "/DeploymentConfig/${var.resource_prefix}/BitbucketClientSecret"
    DiscourseCategoryId = "/DeploymentConfig/${var.resource_prefix}/DiscourseCategoryId"
    DiscourseKey = "/DeploymentConfig/${var.resource_prefix}/DiscourseKey"
    DiscourseUrl = "/DeploymentConfig/${var.resource_prefix}/DiscourseUrl"
    DocumentationUrl = "/DeploymentConfig/${var.resource_prefix}/DocumentationUrl"
    ExternalGoogleClientPrefix = "/DeploymentConfig/${var.resource_prefix}/ExternalGoogleClientPrefix"
    DomainName = "/DeploymentConfig/${var.resource_prefix}/DomainName"
    FeaturedContentUrl: "/DeploymentConfig/${var.resource_prefix}/FeaturedContentURL"
    FeaturedNewsUrl = "/DeploymentConfig/${var.resource_prefix}/FeaturedNewsURL"
    GitHubAppId = "/DeploymentConfig/${var.resource_prefix}/GitHubAppId"
    GitHubAppName = "/DeploymentConfig/${var.resource_prefix}/GitHubAppName"
    GitHubClientId = "/DeploymentConfig/${var.resource_prefix}/GitHubClientId"
    GitHubClientSecret = "/DeploymentConfig/${var.resource_prefix}/GitHubClientSecret"
    DBDockstoreUserPassword = "/DeploymentConfig/${var.resource_prefix}/DBDockstorePassword"
    DBPostgresPassword = "/DeploymentConfig/${var.resource_prefix}/DBPostgresPassword"
    GitLabClientId = "/DeploymentConfig/${var.resource_prefix}/GitLabClientId"
    GitLabClientSecret = "/DeploymentConfig/${var.resource_prefix}/GitLabClientSecret"
    GoogleClientId = "/DeploymentConfig/${var.resource_prefix}/GoogleClientId"
    GoogleClientSecret = "/DeploymentConfig/${var.resource_prefix}/GoogleClientSecret"
    OrcidClientId = "/DeploymentConfig/${var.resource_prefix}/OrcidClientId"
    OrcidClientSecret = "/DeploymentConfig/${var.resource_prefix}/OrcidClientSecret"
    OrcidUrl = "/DeploymentConfig/${var.resource_prefix}/OrcidUrl"
    OrcidScope = "/DeploymentConfig/${var.resource_prefix}/OrcidScope"
    QuayClientId = "/DeploymentConfig/${var.resource_prefix}/QuayClientId"
    QuayClientSecret = "/DeploymentConfig/${var.resource_prefix}/QuayClientSecret"
    SamPath = "/DeploymentConfig/${var.resource_prefix}/SamPath"
    SlackMediumPrioritySNSTopicName = "/DeploymentConfig/${var.resource_prefix}/SlackMediumPrioritySNSTopicName"
    TagManagerId = "/DeploymentConfig/${var.resource_prefix}/TagManagerId"
    TerraImportUrl = "/DeploymentConfig/${var.resource_prefix}/TerraImportUrl"
    ToolTesterBucketName = "/DeploymentConfig/${var.resource_prefix}/ToolTesterBucketName"
    ZenodoClientId = "/DeploymentConfig/${var.resource_prefix}/ZenodoClientId"
    ZenodoClientSecret = "/DeploymentConfig/${var.resource_prefix}/ZenodoClientSecret"
    ZenodoUrl = "/DeploymentConfig/${var.resource_prefix}/ZenodoUrl"
  }

  template_body = file("./dockstore-app.yml")
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]
}

