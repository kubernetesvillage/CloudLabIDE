# CloudLabIDE

This repository contains CloudFormation template to quickly set up VSCode (code-server) instances in the us-west-2 region and Cloud9 (deprecated) instances in the us-east-1 region. Both setups are pre-configured with necessary permissions and are ready to be used for cloud security-related workshops or development.

> **Authored by:** Anjali Singh Shukla & Divyanshu Shukla

> **Note:** As AWS Cloud9 is deprecated, this script has been created to facilitate labs and learning environments efficiently.


---

## Quick-Launch Links for Cloud9 (us-east-1) and VSCode (us-west-2)

> [Credit: AWS Eksworkshop](https://www.eksworkshop.com/docs/introduction/setup/your-account/)

> 
Use the AWS CloudFormation quick-create links below to launch the desired environment in your preferred AWS region.

| Region         | Cloud9 (Not Recommended)                         | VSCode            |
|----------------|-------------------------------------|---------------------------------------|
| **us-east-1**  | [Launch](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?stackName=peachycloudsecuritycloud9-workshop&templateURL=https://kubernetesvillage-vscode.s3.us-west-2.amazonaws.com/cloud9.yml)  | XX  |
| **us-west-2**  | XX | [Launch](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/quickcreate?stackName=aws-peachycloudsecurity-workshop&templateURL=https://kubernetesvillage-vscode.s3.us-west-2.amazonaws.com/vscodecloud-lab.yaml) |

- <b>Note: Use VSCode link in `us-west-2` for deploying code-server (VSCode IDE).</b>

### Setup Instructions

1. **Choose your Region**: Use the table above to pick your region (e.g., **us-east-1** or **us-west-2**) and launch the CloudFormation stack for Cloud9 (Not Recommended) or VSCode .
   
2. **Monitor the Stack Creation**: The stack will take about 10 minutes to complete.

3. **Accessing the Environment**: Once the stack creation is complete, you can retrieve the Cloud9 or VSCode URL using the following command.
   
   > Replace `Cloud9Url` with `VSCodeUrl` for VSCode instance.
   
   - For cloud9 (Not Recommended)

    ```bash
    aws cloudformation describe-stacks --stack-name securitydojo-eks-workshop --query 'Stacks[0].Outputs[?OutputKey==`Cloud9Url`].OutputValue' --output text --region us-east-1
    ```
   - For VSCodeUrl (Recommended)

    ```bash
     aws cloudformation describe-stacks --stack-name securitydojo-eks-workshop --query 'Stacks[0].Outputs[?OutputKey==`IdeUrl`].OutputValue' --output text --region us-west-2
    ```

4. Access the cloudformation `Outputs`.

    - CloudFrontUrl
        - To access the cloudFront url for the VSCode access
    - SecretsManagerUrl
        - Retrieve the secret to access the VSCode IDE.

![alt text](external-images/image.png)
    
5. Access the `CloudFrontUrl` & follow next steps from [terraform-eks](https://github.com/kubernetesvillage/terraform-eks) to deploy `eks cluster`.

### Cleanup

To avoid unnecessary costs, be sure to delete the CloudFormation stacks and any created AWS resources once you're finished.

- To delete the Cloud9 or VSCode instance, run the following command:

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
