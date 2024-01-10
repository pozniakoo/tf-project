The infrastructure is segmented into Development and Production environments, relying on two branches within a repository. 
The development branch is employed for testing purposes. Following the completion of tests, branches are merged, 
subsequently triggering Production Pipeline and deploying the final version on Production EC2 instance.
If you intend to run this code on your own, please remember to fill in your own variables for CodeStar connection and S3 bucket.

Stack:
- CodePipeline
- CodeDeploy
- IAM
- S3