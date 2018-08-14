# .NET Serverless API and Angular Front End
This project is a template local development on an API and an Angular application that work together. After working locally, you can use this same template to deploy a serverless API and to host an Angular application both on AWS with just a few simple CLI commands.
* The API is served through [ASP.NET Core WebAPI](https://docs.microsoft.com/en-us/aspnet/core/web-api/?view=aspnetcore-2.1) and uses hardcoded weather values. The API uses all the familiar aspects of WebAPI locally, and the API switches to use the [AWS AspNetCoreServer package](https://github.com/aws/aws-lambda-dotnet/tree/master/Libraries/src/Amazon.Lambda.AspNetCoreServer) when running in an [AWS Lambda function](https://aws.amazon.com/lambda/) behind [API Gateway](https://aws.amazon.com/api-gateway/).
* The [Angular application](https://angular.io/) has [Angular Material](https://material.angular.io/) already configured and included.
# Requirements
This project needs the following installed:
* [.NET Core CLI](https://docs.microsoft.com/en-us/dotnet/core/tools/?tabs=netcore2x) or [Visual Studio](https://visualstudio.microsoft.com/)
* [AWS CLI](https://aws.amazon.com/cli/) or [AWS Tools for PowerShell](https://aws.amazon.com/powershell/)
* [Node.js and NPM](https://nodejs.org/en/)
* [Angular CLI](https://cli.angular.io/)
# Project Startup
The project can be started with the single command: `dotnet run`. The `.csproj` file has been modified to automatically start the Angular developer server included in the Angular CLI (`ng serve`). The build tools will print out to the command line the `localhost` URLs for the API and the Angular application both after the project starts. The Angular developer server automatically watches for changes in the Angular project and will restart the server to reflect those changes. Any changes to the WebAPI server, however, will require a manual restart of the local server by stopping and reissuing `dotnet run`.

The Angular project is configured to use `http://localhost:5000` as the base URL for making API calls when running locally. You can edit this setting in `ClientApp > src > environments > environment.ts`.
# Build
In addition to being a template for working locally and serverlessly without any code changes, there are additional build tool scripts and enhancements meant to demonstrate various ways to automate deployment in a .NET environment with AWS.

When deploying this solution, we need to deploy the API first.
## Front End
Each of the various methods for building and deploying the Angular application in the `ClientApp` folder involves the following steps:
1. 
### MSBuild
When inspecting the `.csproj` file, you'll notice several custom build steps for the [MSBuild engine](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild). MSBuild is the underlying tool used when calling `dotnet build` or running `Build` within Visual Studio. The additional MSBuild steps in the `.csproj` file go through all the requirements for building and deploying the Angular application in the `ClientApp` folder to the public Internet. The MSBuild requires the `AWS CLI` to be installed on whatever system you run it on.