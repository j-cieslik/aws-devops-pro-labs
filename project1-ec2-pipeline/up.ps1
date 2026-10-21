# Odtwarza cala infrastrukture projektu 1 (w kolejnosci zaleznosci).
# Wymaga zatwierdzonego polaczenia z GitHubem (stack p1-connection).
$ErrorActionPreference = "Stop"
$p = @("--profile", "devops-lab", "--region", "eu-central-1")
$infra = Join-Path $PSScriptRoot "infra"

function Deploy-Stack($name, $file) {
    Write-Host "Wdrazam $name"
    aws cloudformation deploy --template-file (Join-Path $infra $file) --stack-name $name --capabilities CAPABILITY_IAM @p
    if ($LASTEXITCODE -ne 0) { throw "Nie udalo sie wdrozyc $name" }
}

Deploy-Stack "p1-connection" "connection.yaml"
Deploy-Stack "p1-infra" "infra.yaml"
Deploy-Stack "p1-codedeploy" "codedeploy.yaml"
Deploy-Stack "p1-codebuild" "codebuild.yaml"
Deploy-Stack "p1-pipeline" "pipeline.yaml"   # po utworzeniu pipeline sam wdrozy aktualny kod z main

aws cloudformation describe-stacks --stack-name p1-infra @p --query "Stacks[0].Outputs[?OutputKey=='AppUrl'].OutputValue" --output text
