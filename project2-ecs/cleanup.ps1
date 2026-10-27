# Removes everything created in project 2 (most of it was created by hand in the console).
# Keeps the shared GitHub connection (p1-connection) and ecsTaskExecutionRole.
$ErrorActionPreference = "Continue"
$p = @("--profile", "devops-lab", "--region", "eu-central-1")

function Remove-Role($name) {
    $exists = aws iam get-role --role-name $name @p 2>$null; if ($LASTEXITCODE -ne 0) { return }
    Write-Host "Deleting IAM role $name"
    foreach ($arn in (aws iam list-attached-role-policies --role-name $name @p --query "AttachedPolicies[].PolicyArn" --output text) -split "\s+" | Where-Object { $_ }) {
        aws iam detach-role-policy --role-name $name --policy-arn $arn @p
        if ($arn -notmatch ":aws:policy/") { aws iam delete-policy --policy-arn $arn @p 2>$null }
    }
    foreach ($pol in (aws iam list-role-policies --role-name $name @p --query "PolicyNames" --output text) -split "\s+" | Where-Object { $_ }) {
        aws iam delete-role-policy --role-name $name --policy-name $pol @p
    }
    aws iam delete-role --role-name $name @p
}

# 1. Pipeline, its artifact bucket and role
foreach ($id in (aws codepipeline list-pipeline-executions --pipeline-name p2-pipeline @p --query "pipelineExecutionSummaries[?status=='InProgress'].pipelineExecutionId" --output text 2>$null) -split "\s+" | Where-Object { $_ -and $_ -ne "None" }) {
    aws codepipeline stop-pipeline-execution --pipeline-name p2-pipeline --pipeline-execution-id $id --abandon @p | Out-Null
}
aws codepipeline delete-pipeline --name p2-pipeline @p
foreach ($b in (aws s3api list-buckets @p --query "Buckets[?starts_with(Name,'codepipeline-eu-central-1-')].Name" --output text) -split "\s+" | Where-Object { $_ }) {
    Write-Host "Deleting bucket $b"; aws s3 rb "s3://$b" --force @p | Out-Null
}
Remove-Role "AWSCodePipelineServiceRole-eu-central-1-p2-pipeline"

# 2. CodeBuild project and role
aws codebuild delete-project --name p2-build @p | Out-Null
Remove-Role "codebuild-p2-build-service-role"

# 3. CodeDeploy application (deletes the deployment group too)
aws deploy delete-application --application-name p2-codedeploy @p

# 4. ECS service
aws ecs update-service --cluster p2-cluster --service p2-service-bg --desired-count 0 @p | Out-Null
aws ecs delete-service --cluster p2-cluster --service p2-service-bg --force @p | Out-Null
while ((aws ecs describe-services --cluster p2-cluster --services p2-service-bg @p --query "services[0].status" --output text) -eq "DRAINING") { Start-Sleep 10 }

# 5. Blue/green support stack and the console-created load balancer stack
foreach ($s in @("p2-bg-support") + ((aws cloudformation list-stacks @p --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[?starts_with(StackName,'ECS-Console-V2-Service-p2')].StackName" --output text) -split "\s+" | Where-Object { $_ })) {
    Write-Host "Deleting stack $s"; aws cloudformation delete-stack --stack-name $s @p; aws cloudformation wait stack-delete-complete --stack-name $s @p
}

# 6. Leftover load balancer pieces and security group (if the console stack did not own them)
$alb = aws elbv2 describe-load-balancers --names p2-alb @p --query "LoadBalancers[0].LoadBalancerArn" --output text 2>$null
if ($LASTEXITCODE -eq 0 -and $alb -and $alb -ne "None") { aws elbv2 delete-load-balancer --load-balancer-arn $alb @p; Start-Sleep 30 }
foreach ($tg in @("p2-tg", "p2-tg-green")) {
    $arn = aws elbv2 describe-target-groups --names $tg @p --query "TargetGroups[0].TargetGroupArn" --output text 2>$null
    if ($LASTEXITCODE -eq 0 -and $arn -and $arn -ne "None") { aws elbv2 delete-target-group --target-group-arn $arn @p }
}
$sg = aws ec2 describe-security-groups --filters Name=group-name,Values=p2-sg @p --query "SecurityGroups[0].GroupId" --output text
if ($sg -and $sg -ne "None") {
    for ($i = 0; $i -lt 12; $i++) { aws ec2 delete-security-group --group-id $sg @p 2>$null; if ($LASTEXITCODE -eq 0) { Write-Host "Deleted $sg"; break }; Start-Sleep 20 }
}

# 7. Task definitions and cluster
foreach ($td in (aws ecs list-task-definitions --family-prefix p2-app @p --query "taskDefinitionArns" --output text) -split "\s+" | Where-Object { $_ }) {
    aws ecs deregister-task-definition --task-definition $td @p | Out-Null
}
$inactive = (aws ecs list-task-definitions --family-prefix p2-app --status INACTIVE @p --query "taskDefinitionArns" --output text) -split "\s+" | Where-Object { $_ }
if ($inactive) { aws ecs delete-task-definitions --task-definitions $inactive @p | Out-Null }
aws ecs delete-cluster --cluster p2-cluster @p | Out-Null

# 8. Image repository and log groups
aws ecr delete-repository --repository-name p2-app --force @p | Out-Null
foreach ($lg in @("/ecs/p2-app", "/aws/codebuild/p2-build", "/aws/lambda/CodeDeployHook_p2-test")) { aws logs delete-log-group --log-group-name $lg @p 2>$null }

Write-Host "Done. Kept: p1-connection, ecsTaskExecutionRole."
