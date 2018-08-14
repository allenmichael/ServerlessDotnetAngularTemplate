# .NET Serverless API and Angular Front End
This project is a template for local development on an API and an Angular application that work in tandem. After working locally, you can also use this same template to deploy a serverless API and to host an Angular application both on AWS with just a few simple CLI commands.
* The API is served through [ASP.NET Core WebAPI](https://docs.microsoft.com/en-us/aspnet/core/web-api/?view=aspnetcore-2.1) and uses hardcoded weather values. The API uses all the familiar aspects of WebAPI locally, and the API switches to use the [AWS AspNetCoreServer package](https://github.com/aws/aws-lambda-dotnet/tree/master/Libraries/src/Amazon.Lambda.AspNetCoreServer) when running in an [AWS Lambda function](https://aws.amazon.com/lambda/) behind [API Gateway](https://aws.amazon.com/api-gateway/).
* The [Angular application](https://angular.io/) has [Angular Material](https://material.angular.io/) already configured and included.
# Requirements
This project needs the following installed:
* [.NET Core CLI](https://docs.microsoft.com/en-us/dotnet/core/tools/?tabs=netcore2x) or [Visual Studio](https://visualstudio.microsoft.com/)
* [AWS CLI](https://aws.amazon.com/cli/) or [AWS Tools for PowerShell](https://aws.amazon.com/powershell/)
* [Node.js and NPM](https://nodejs.org/en/)
* [Angular CLI](https://cli.angular.io/)
# Project Startup
The project can be started with the single command: `dotnet run`. The `.csproj` file has been modified to automatically start the Angular developer server included in the Angular CLI (`ng serve`). The build tools will print out to the command line the `localhost` URLs for both the API and the Angular application after the project starts. The Angular developer server automatically watches for changes in the Angular project and will restart the server to reflect those changes. Any changes to the WebAPI server, however, will require a manual restart of the local server by stopping and reissuing `dotnet run`.

The Angular project is configured to use `http://localhost:5000` as the base URL for making API calls when running locally. You can edit this setting in `ClientApp > src > environments > environment.ts`.
# Build
In addition to being a template for working locally and serverlessly without any code changes, there are additional build tool scripts and enhancements meant to demonstrate various ways to automate deployment in a .NET environment with AWS.

When deploying this solution, we need to deploy the API before the front end, at least for the first deployment.
## Deploy with Visual Studio
For this deployment method, you'll need the [AWS Toolkit for Visual Studio](https://aws.amazon.com/visualstudio/) and the [AWS Tools for PowerShell](https://aws.amazon.com/powershell/) installed.
### Back End API
1. When you're ready to deploy, right click on the project and select `Publish to AWS Lambda`.
![Publish to AWS Lambda](https://s3-us-west-2.amazonaws.com/amsxbg-ddb-code-generator/Serverless/VS-Publish-Serverless-App.png)
2. You can select to create a new [S3 Bucket](https://aws.amazon.com/s3/) to store the compiled C# code, or you can use an existing Bucket.
![Create New S3 Bucket](https://s3-us-west-2.amazonaws.com/amsxbg-ddb-code-generator/Serverless/VS-Publish-Create-Bucket.png)
3. Give the [CloudFormation](https://aws.amazon.com/cloudformation/) stack a descriptive name. The stack name you enter needs to match the `StackName` variable provided in the `.csproj` file. By default, `serverless-angular-api` is used in the `.csproj` file provided.
![Stack Name](https://s3-us-west-2.amazonaws.com/amsxbg-ddb-code-generator/Serverless/VS-Publish-Stack-Name.png)
4. When CloudFormation finishes provisioning resources, you can view the new stack in the AWS Toolkit for Visual Studio.
![Stack Complete](https://s3-us-west-2.amazonaws.com/amsxbg-ddb-code-generator/Serverless/VS-Publish-Create-Complete.png)
### Front End App
For this deployment method, you'll need the [Node.js and NPM](https://nodejs.org/en/), the [Angular CLI](https://cli.angular.io/), and the [AWS Tools for PowerShell](https://aws.amazon.com/powershell/) installed.
1. There is an included PowerShell script for deploying the front end application. Right click on the script and select `Open with PowerShell ISE`.
![Open ISE](https://s3-us-west-2.amazonaws.com/amsxbg-ddb-code-generator/Serverless/PS-ISE-Open.png)
![ISE Opened](https://s3-us-west-2.amazonaws.com/amsxbg-ddb-code-generator/Serverless/PS-ISE.png)
2. You may need to change the `ExecutionPolicy` to execute the script. Use the following command: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force`
![Execution Policy](https://s3-us-west-2.amazonaws.com/amsxbg-ddb-code-generator/Serverless/PS-Execution-Policy.png)
3. Click the `Play` button in `PowerShell ISE` and the script will execute. After a successful execution, the command line will print the URL for your deployed Angular application. The URL should match the following pattern: http://%s3_bucket_name%.s3-website.%aws_region%.amazonaws.com.
![PS Finished](https://s3-us-west-2.amazonaws.com/amsxbg-ddb-code-generator/Serverless/PS-Finished.png)
## Deploy with `dotnet` CLI Tool
### Back End API
1. Create an [S3 Bucket](https://aws.amazon.com/s3/) to hold your code.
    * AWS Console: [Create an S3 Bucket](https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html)
    * AWS CLI: `aws s3 mb s3://%bucket_name%`
    * AWS Tools for PowerShell: `New-S3Bucket -BucketName %bucket_name%`
2. In the root of the project, run `dotnet lambda deploy-serverless -sb %bucket_name% -sn %stack_name% --region %aws_region%`. Make sure the stack name you use matches with what's defined in the `.csproj` file. By default, `serverless-angular-api` is used as the stack name in the `.csproj` file provided.
### Front End App
1. Run `dotnet msbuild /t:DeployNgToAWS`.
2. If you're on a Unix-based system, there's also a `deploy_ng_to_aws.sh` script file you can run.
3. After a successful execution, the command line will print the URL for your deployed Angular application. The URL should match the following pattern: http://%s3_bucket_name%.s3-website.%aws_region%.amazonaws.com.
## Front End Details
Each of the various methods for building and deploying the Angular application in the `ClientApp` folder involves the following steps:
1. Builds all front end assets with `npm build -- --prod` which uses `ng build --prod`.
2. Creates a new [S3 Bucket](https://aws.amazon.com/s3/) to host your front end assets.
3. Enables the S3 Bucket to host a static website.
4. Removes any existing files from the S3 Bucket.
5. Copies all files from the `ClientApp > dist` build folder to the S3 Bucket.
6. Locates and prints the public URL to your static website.
### MSBuild Details
When inspecting the `.csproj` file, you'll notice several custom build steps for the [MSBuild engine](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild). MSBuild is the underlying tool used when calling `dotnet build` or running `Build` within Visual Studio. The additional MSBuild steps in the `.csproj` file go through all the requirements for building and deploying the Angular application in the `ClientApp` folder to the public Internet. The MSBuild requires the `AWS CLI` to be installed on whatever system you run it on.

To start the front end custom MSBuild steps, target the `DeployNgToAWS` step. For example, when using the `dotnet` tool, use the command `dotnet msbuild /t:DeployNgToAWS`. This method is well paired with build and deployment pipeline tools like [CodeBuild](https://aws.amazon.com/codebuild/) and [CodePipeline](https://aws.amazon.com/codepipeline/).