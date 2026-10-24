# Lekcja 7: przelacza deployment group p1-dg na blue/green.
# Robimy to przez CLI, bo CloudFormation nie obsluguje blue/green dla EC2.
$ErrorActionPreference = "Stop"
$p = @("--profile", "devops-lab", "--region", "eu-central-1")

aws deploy update-deployment-group @p `
    --application-name p1-app `
    --current-deployment-group-name p1-dg `
    --auto-scaling-groups p1-asg `
    --deployment-config-name CodeDeployDefault.AllAtOnce `
    --deployment-style "deploymentType=BLUE_GREEN,deploymentOption=WITH_TRAFFIC_CONTROL" `
    --blue-green-deployment-configuration "greenFleetProvisioningOption={action=COPY_AUTO_SCALING_GROUP},deploymentReadyOption={actionOnTimeout=CONTINUE_DEPLOYMENT},terminateBlueInstancesOnDeploymentSuccess={action=TERMINATE,terminationWaitTimeInMinutes=10}"

aws deploy get-deployment-group @p --application-name p1-app --deployment-group-name p1-dg `
    --query "deploymentGroupInfo.[deploymentStyle.deploymentType,deploymentConfigName]" --output text
