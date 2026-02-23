# CloudLabIDE

This repository contains CloudFormation templates to quickly set up VSCode (code-server) instances in us-east-1 and us-west-2 regions. Templates are pre-configured with necessary permissions and are ready to be used for cloud security-related workshops or development.

> **Authored by:** Anjali Singh Shukla & Divyanshu Shukla



---

## Quick-Launch Links

> [Credit: AWS Eksworkshop](https://www.eksworkshop.com/docs/introduction/setup/your-account/)

Use the AWS CloudFormation quick-create links below to launch the desired environment in your preferred AWS region.

| Region         | OS Type        | VSCode            |
|----------------|----------------|---------------------------------------|
| **us-east-1**  | Amazon Linux   | [Launch](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?stackName=aws-peachycloudsecurity-workshop&templateURL=https://raw.githubusercontent.com/kubernetesvillage/CloudLabIDE/main/cloudformation-template/vscode-al2023-us-east-1.yml)  |
| **us-east-1**  | Ubuntu 22.04   | [Launch](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?stackName=aws-peachycloudsecurity-workshop&templateURL=https://raw.githubusercontent.com/kubernetesvillage/CloudLabIDE/main/cloudformation-template/vscode-ubuntu2204-us-east-1.yml) |
| **us-west-2**  | Amazon Linux   | [Launch](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/quickcreate?stackName=aws-peachycloudsecurity-workshop&templateURL=https://raw.githubusercontent.com/kubernetesvillage/CloudLabIDE/main/cloudformation-template/vscode-al2023-us-west-2.yml) |
| **us-west-2**  | Ubuntu 22.04   | [Launch](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/quickcreate?stackName=aws-peachycloudsecurity-workshop&templateURL=https://raw.githubusercontent.com/kubernetesvillage/CloudLabIDE/main/cloudformation-template/vscode-ubuntu2204-us-west-2.yml) |

### Setup Instructions

1. **Choose your Region and OS**: Use the table above to pick your region and OS type, then launch the CloudFormation stack.

2. **Monitor the Stack Creation**: The stack will take about 10 minutes to complete.

3. **Access the CloudFormation Outputs**: Once the stack creation is complete, retrieve the outputs.

    - CloudFrontUrl
        - To access the cloudFront url for the VSCode access
    - SecretsManagerUrl
        - Retrieve the secret to access the VSCode IDE.

![alt text](external-images/image.png)
    
5. Access the `CloudFrontUrl` & follow next steps from [terraform-eks](https://github.com/kubernetesvillage/terraform-eks) to deploy `eks cluster`.

### Cleanup

To avoid unnecessary costs, be sure to delete the CloudFormation stacks and any created AWS resources once you're finished.

- To delete the VSCode instance, run the following command:

    ```bash
    aws cloudformation delete-stack --stack-name securitydojo-eks-workshop
    ```

- Follow the cleanup instructions for the EKS resources, either through `eksctl` or Terraform.



## Disclaimer

- The views expressed are solely those of the speaker and do not reflect the opinions of the employer. Use at your own risk.
- The password is temporary and regenerates each time the script runs.
- Do not push this code while the VS Code server is running.
- The author is not responsible for any charges or security issues that may arise. This is shared under the MIT 0 license. 

## License

- This project is licensed under the GPL-3.0 license. See the [LICENSE](LICENSE) file for details.
- This repository uses code from the [AWS EKS Workshop](https://github.com/aws-samples/eks-workshop-v2/), licensed under the Apache-2.0.

## Credits


- The CloudFormation templates have been adapted for use in the **peachycloudsecurity** EKS workshop.
- [AWS-Samples](https://github.com/aws-samples/eks-workshop-v2/) under the [Apache-2.0 license](https://github.com/aws-samples/eks-workshop-v2/?tab=Apache-2.0-1-ov-file#readme)
- Thanks to [coder team](https://github.com/coder/deploy-code-server)
- Thanks to [AWS eks-workshop-v2](https://github.com/aws-samples/eks-workshop-v2/blob/main/lab/scripts/installer.sh)


This project is maintained by the Kubernetes Village team. Contributions are welcome!

For more information, visit our [GitHub page](https://github.com/kubernetesvillage).


## Follow us:

- [Kubernetes Village](https://www.linkedin.com/company/kubernetesvillage/)
- [Anjali Shukla](https://linktr.ee/theshukladuo)
- [Divyanshu Shukla](https://linktr.ee/theshukladuo)
