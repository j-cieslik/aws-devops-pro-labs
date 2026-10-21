# Usuwa kosztowna infrastrukture projektu 1 (w kolejnosci zaleznosci).
# Zostawia polaczenie z GitHubem (p1-connection), zeby nie zatwierdzac go ponownie.
$ErrorActionPreference = "Stop"
$p = @("--profile", "devops-lab", "--region", "eu-central-1")
$account = aws sts get-caller-identity @p --query Account --output text

function Clear-Bucket($name) {
    $exists = aws s3api head-bucket --bucket $name @p 2>$null; if ($LASTEXITCODE -ne 0) { return }
    Write-Host "Oprozniam bucket $name"
    do {
        $v = aws s3api list-object-versions --bucket $name @p --max-items 500 --output json | ConvertFrom-Json
        $objs = @($v.Versions) + @($v.DeleteMarkers) | Where-Object { $_ } | ForEach-Object { @{ Key = $_.Key; VersionId = $_.VersionId } }
        if ($objs.Count -gt 0) {
            $file = New-TemporaryFile
            @{ Objects = $objs; Quiet = $true } | ConvertTo-Json -Depth 4 -Compress | Set-Content -Encoding ascii $file
            aws s3api delete-objects --bucket $name --delete "file://$file" @p | Out-Null
            Remove-Item $file
        }
    } while ($objs.Count -gt 0)
}

function Remove-Stack($name) {
    Write-Host "Usuwam stack $name"
    aws cloudformation delete-stack --stack-name $name @p
    aws cloudformation wait stack-delete-complete --stack-name $name @p
}

Clear-Bucket "p1-pipeline-artifacts-$account"
Remove-Stack "p1-pipeline"
Remove-Stack "p1-codebuild"
Clear-Bucket "p1-revisions-$account"
Remove-Stack "p1-codedeploy"
Remove-Stack "p1-infra"
Write-Host "Gotowe. Zostal tylko p1-connection."
