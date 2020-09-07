function Write-Header($text) { 
    Write-Host ">> `n>>>>>>> $text `n>>" -ForegroundColor Magenta
}

task default -depends "tf-checks", "pwsh-checks", "docs-checks"

### Check powershell scripts for errors
task "pwsh-checks" {
    Write-Header  ">> Powershell Script Analyzer"
    $saResults = Invoke-ScriptAnalyzer -Path . -Recurse -Settings PSGallery 
    if ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
    }
}

## 
## Terraform Tasks
##

### Fix formatting issues with Terraform
task "tf-format" {
    terraform fmt -recursive
}

### Check terraform for issues 
task "tf-checks" {
    Write-Header  ">> Terraform verion"
    exec { terraform -version }

    Write-Header  ">> Terraform Format (if this fails use 'terraform fmt' command to resolve"
    exec { terraform fmt -recursive -diff -check }

    Write-Header  ">> tflint"
    exec { tflint }

    Write-Header  ">> Terraform init"
    exec { terraform init }

    Write-Header  ">> Terraform validate"
    exec { terraform validate }
}

task "tf-deploy" -depends "tf-checks" {
    exec { terraform apply }
}


### Check spellings in markdown
task "docs-checks" {
    Write-Header "Checking spellings in markdown"
    # If this task fails for a technical term of acryonm add it to `.spelling` file in the porject root.
    exec { mdspell --en-gb --report **/*.md }

    Write-Header "Checking links for dead links"
    exec { /bin/bash -c "find . -name \*.md -exec markdown-link-check -v {} \;" }
}