# Custom Atlantis Container

This repository contains a custom Atlantis container image that extends the base Atlantis image with additional tools commonly used in infrastructure-as-code workflows.

## Overview

This custom container includes:
- **Base Image**: Atlantis v0.35.0
- **Terragrunt**: v0.83.2 for managing Terraform configurations
- **OpenTofu**: Latest version as a Terraform alternative
- **Checkov**: v3.2.451 for security and compliance scanning

**Note:** Terraform was removed, as it might well be in your org.

## Container Features

### Additional Tools Included
- **Terragrunt**: Provides a thin wrapper for Terraform that enables keeping your Terraform code DRY
- **OpenTofu**: Open-source Terraform alternative (replaces the default Terraform binary)
- **Checkov**: Static code analysis tool for infrastructure-as-code

### Workflow Configuration

The container is designed to work with the following example Atlantis workflow configuration:

```yaml
repos:
- id: /.*/
  workflow: terragrunt
  allow_custom_workflows: true
  apply_requirements: [approved, mergeable]
policies:
  owners:
    users:
      - my_user
  policy_sets:
    - name: example-conf-tests
      path: /home/atlantis/conftest_policies
      source: local
workflows:
  terragrunt:
    plan:
      steps:
      - run: terragrunt plan
      - run: terraform show -json .terragrunt/terraform.plan > tf.json
      - run: checkov -f tf.json
    policy_check:
      steps:
      - policy_check:
          extra_args: ["-p /home/atlantis/conftest_policies/", "--all-namespaces"]
    apply:
      steps:
      - run: terragrunt apply
```

## Building the Container

To build the custom Atlantis container:

```bash
docker build -t your-registry/atlantis-custom:latest .
```

## Deploying the Container

### Using Docker

```bash
docker run -it --rm \
  -p 4141:4141 \
  -e ATLANTIS_GITHUB_TOKEN=your-github-token \
  -e ATLANTIS_GITHUB_WEBHOOK_SECRET=your-webhook-secret \
  -e ATLANTIS_REPO_ALLOWLIST=github.com/your-org/* \
  your-registry/atlantis-custom:latest server
```

### Using Kubernetes

Refer to the [official helm chart](https://github.com/runatlantis/helm-charts), and consider using tooling like [helmfile](https://github.com/helmfile/helmfile).

**Note:** Your favorite way to deploy containers will work just fine.  K8s is not a requirement.

## Workflow Details

### Plan Phase
1. **Terragrunt Plan**: Executes `terragrunt plan` to generate the Terraform plan
2. **Export Plan**: Converts the plan to JSON format for analysis
3. **Security Scan**: Runs Checkov against the plan to identify security and compliance issues

### Policy Check Phase
- Uses Conftest policies stored in `/home/atlantis/conftest_policies/`
- Validates infrastructure configurations against organizational policies

### Apply Phase
- Executes `terragrunt apply` to deploy the planned infrastructure changes

## Configuration Requirements

To use this container effectively, ensure:

1. **Policy Files**: Mount your Conftest policy files to `/home/atlantis/conftest_policies/`
2. **Atlantis Configuration**: Mount your `atlantis.yaml` to `/home/atlantis/atlantis.yaml`
3. **Environment Variables**: Set required Atlantis environment variables for your VCS provider

## Customization

To customize this container for your specific needs:

1. **Modify Dockerfile**: Update tool versions or add additional tools
2. **Update Workflow**: Modify the workflow steps in your `atlantis.yaml`
3. **Add Policies**: Include your organization's Conftest policies

## Security Considerations

- This container runs with the `atlantis` user (non-root) for security
- Ensure proper secret management for VCS tokens and webhook secrets
- Review and customize the included tools' versions for your security requirements
- Consider using image scanning tools to validate the built container

## Contributing

This is an example implementation showing how to create a custom Atlantis container. Feel free to fork and modify according to your organization's requirements.

## License

This project is licensed under the GNU General Public License v2.0 - see the [LICENSE](LICENSE) file for details.

Please ensure compliance with the licenses of all included tools and dependencies when using this container.
