Project: Serverless Web Application

This project involves building a serverless web application using AWS Lambda, DynamoDB, S3, and CloudFront. Amazon Cognito is implemented for user authentication and authorization, enabling access to the "full version" of the web application.

Template files are utilized for editing HTML and JavaScript files, which will then be deployed on AWS. It is essential for the web application files to exist in a specific directory to enable editing. Otherwise, running Terraform apply twice may be necessary to ensure proper deployment.

I'm using a AWS Sandbox, which provides a Route 53 hosted zone. Hence, the importation of this resource is necessary. If not using AWS Sandbox, you may need to create your own hosted zone.