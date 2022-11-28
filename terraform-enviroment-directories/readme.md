A lot of the community seem to use local environment directories more than workspaces.

```sh
# For staging
terraform -chdir=./staging init -backend-config=../backend-staging.tf

# For production
terraform -chdir=./production init -backend-config=../backend-production.tf

```
