# Video Indexer Automation with Terraform 0.13 and Shell provider

> WARNING: This is an initial hack to test the viability. It is not maintained. For production uses a fork should be taken and further testing is highly recommended.

This quick hack uses the terraform `shell`, `azurerm` and `azuread` providers to create:

- Media services instance
- Azure AD App and Secret
- Create a paid Video Index account connected to the Media service instance.

> Note: The Video indexer account is created via a powershell script and the `shell` provider as it isn't support in `azurerm`. To learn more about the [shell provider head to the documentation here](https://registry.terraform.io/providers/scottwinkler/shell/latest/docs)

## Quick start

1. Clone the project
1. Ensure your logged into the [`azurecli`](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) and running in the devcontainer. If you already have `azurecli` installed on your machine and logged in the devcontainer will use these details and there is no need to login again in the devcontainer.
1. Rename the `example.vars.tfvars` to `vars.auto.tfvars`
1. Set values in `vars.auto.tfvars` as required
1. run `pwsh -c 'Invoke-psake ./make.ps1 tf-deploy'`

## VSCode Editing with Tooling (Autocomplete, intellisense etc)

1. Open VSCode `code .` in the repo folder
1. `CTRL+SHIFT+P` -> `Reopen in container`
1. Open a terminal and run `Invoke-psake ./make.ps1 tf-checks` (This executes [`terraform init` which is a requirement for the autocompletion to work in VSCode](https://github.com/hashicorp/vscode-terraform/#getting-started))
1. `CTRL+SHIFT+P` -> `Terraform: Enable language server`

You should now have autocompletion and tooling for editing the terraform in VSCode

