#!/usr/bin/env bash
Stage="dev"
GitBranch="main"
Environment="dev"
RepoName="cognito_restore"
XrayEnabled="true"
Prefix="blueshirt-app"
GitHubOwner="Blueshirt-work"
ResourceStackName="blueshirt-app-nodebb-resources"
GitHubRepositoryName="blueshirt-app-nodebb"
Tags="Project=Blueshirt Vendor=MeyiCloud SubProject=App"
PipelineArtifactBucket="blueshirt-app-${Environment}-backend-pipeline-artifactsbucket"
CodeStarConnectionArn="arn:aws:codestar-connections:ap-southeast-1:698032826194:connection/0e2ebc7a-a6ba-412c-9237-9b502252421c"
PipelineStackName=${GitHubRepositoryName}-${Environment}-pipeline
S3UploadsBucket="blueshirt-app-dev-backend-upload-files"
S3UploadHost="s3.amazonaws.com"
S3UploadsPath="s3://blueshirt-app-dev-backend-upload-files/nodebb/"
StachName="nodebb-ecs-test"
AwsDefaultRegion="ap-southeast-1"

# Use sam deploy with correct formatting
sam deploy \
    -t devops/infra.yaml \
    --region "${AwsDefaultRegion}" \
    --stack-name "${StachName}" \
    --no-fail-on-empty-changeset \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM \
    --parameter-overrides \
    ParameterKey=PipelineStackName,ParameterValue="${PipelineStackName}" \
    ParameterKey=S3UploadsBucket,ParameterValue="${S3UploadsBucket}" \
    ParameterKey=S3UploadsPath,ParameterValue="${S3UploadsPath}" \
    ParameterKey=Environment,ParameterValue="${Environment}" \
    ParameterKey=GitHubOwner,ParameterValue="${GitHubOwner}" \
    ParameterKey=ResourceStackName,ParameterValue="${ResourceStackName}" \
    ParameterKey=GitHubRepositoryName,ParameterValue="${GitHubRepositoryName}" \
    ParameterKey=PipelineArtifactBucket,ParameterValue="${PipelineArtifactBucket}" \
    ParameterKey=CodeStarConnectionArn,ParameterValue="${CodeStarConnectionArn}" \
    ParameterKey=Tags,ParameterValue="${Tags}" \
    Parameterkey=NodebbContainerImageURI,ParameterValue="${NODEBB_ECR_REPOSITORY_URI}"