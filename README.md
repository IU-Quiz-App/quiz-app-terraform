# Local setup
This section describes what is necessary to set up the terraform environment.

### Download terraform
```brew install terraform```

### Download AWS CLI
```brew install awscli```

### Create AWS Access Key
Go to the AWS Console and IAM (Identity and Access Management), select "Users" and select your user.

Open the tab "Security Credentials" and go to the section "Access keys". Click ceate access key, choose the option "Command Line Interfare (CLI)", confirm the appearing suggestion at the bottom, set a description and then click "Create access key". Download the information as you won't be able to retrieve it after you reloaded the page. If you loose the access key you have to create a new one.

### Configure AWS CLI
Go to your shell (e.g. iterm) and type

```aws configure --profile PROFILE_NAME```

Choose for PROFILE_NAME name a better name like IU-QUIZ-DEV. Put in the Access Key and Secret Access Key that you retrieved in the previous step. Choose eu-central-1 as default region name. For standard output format you can either just press enter or choose json.

### Testing Setup
Type the following command in your console

```aws s3 ls --profile IU-QUIZ-DEV```

This should prompt out the s3 buckets of the dev account.

With this mechanism you can easily use different AWS accounts by choosing different profiles. You can repeat the steps with another account (create access key there), choose another profile name like IU-QUIZ-PROD and then you just have to change the command to 

```aws s3 ls --profile IU-QUIZ-PROD```

to get the s3 buckets of the prod account.

If you don't want to type the profile at every request you can also set it as an environment variable:

```export AWS_PROFILE=IU-QUIZ-DEV```

You can also add this command to your .zshrc or .bashrc depending on what you use for your shell so the profile is set as default for every shell. But you can always override it by typing the export command with a new profile name in your shell. If you want to find out which one is the current profile in your shell use the command:

```env | grep AWS_PROFILE```

# Use Terraform
This section describes how to use terraform

### Initialize terraform project
At first you have to initialize your terraform project. Open your shell and go to stages -> dev.

Type here:

```terraform init```

This initializes the project.

### Check for changes
To see what would be changed if you deploy now use terraform plan. 

```terraform plan```

This shows you an output on which resources would be created, which one would be changed and which one would be destroyed. It is hardly recommended to check the output of terraform plan before you deploy something, especially when resources are destroyed!

Depending on your AWS setup you maybe have to add --profile PROFILE_NAME to the end of the terraform plan command.

### Deploy the infrastructure
To deploy the infrastructure use the command

```terraform apply```

This command will first do a terraform plan and show you what resources would be created, changed and destroyed. Afterwards you have to type ```yes``` to continue and deploy or any other characters to cancel the deployment. When you type yes you can see the process of the resources in AWS being adjusted to your defined setup. After the process is finished you get an output of all changes to the infrastructure.

Depending on your AWS setup you maybe have to add --profile PROFILE_NAME to the end of the terraform plan command.

The terraform state will be uploaded/updated in a s3 bucket of the AWS account.