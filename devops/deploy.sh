#!/bin/bash
set -e
set -x

# Load environment variables from the .env file
source ../.env

# Debug - Print important variables
echo "PipelineArtifactBucket=${PipelineArtifactBucket}"
echo "Tags=${Tags}"

# Define custom exception types
BUCKET_NOT_EXIST=100
IsS3BucketExists=true

# Deploy the CloudFormation stack with SAM
sam deploy -t cloudformation.yaml \
    --stack-name "$PipelineStackName" \
    --region "$Region" \
    --no-fail-on-empty-changeset \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM \
    --parameter-overrides \
        ParameterKey=Tags,ParameterValue="${Tags}" \
        ParameterKey=Stage,ParameterValue="${Stage}" \
        ParameterKey=Region,ParameterValue="${Region}" \
        ParameterKey=Prefix,ParameterValue="${Prefix}" \
        ParameterKey=RepoName,ParameterValue="${RepoName}" \
        ParameterKey=GitBranch,ParameterValue="${GitBranch}" \
        ParameterKey=Environment,ParameterValue="${Environment}" \
        ParameterKey=XrayEnabled,ParameterValue="${XrayEnabled}" \
        ParameterKey=GitHubOwner,ParameterValue="${GitHubOwner}" \
        ParameterKey=ResourceStackName,ParameterValue="${ResourceStackName}" \
        ParameterKey=GitHubRepositoryName,ParameterValue="${GitHubRepositoryName}" \
        ParameterKey=CodeStarConnectionArn,ParameterValue="${CodeStarConnectionArn}" \
        ParameterKey=PipelineArtifactBucket,ParameterValue="${PipelineArtifactBucket}" \
        ParameterKey=S3Bucket,ParameterValue="${S3Bucket}" \
        ParameterKey=S3Key,ParameterValue="${S3Key}" \
        ParameterKey=UserPoolId,ParameterValue="${UserPoolId}" \
        ParameterKey=IsS3BucketExists,ParameterValue="${IsS3BucketExists}"
