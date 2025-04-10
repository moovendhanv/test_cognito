# Define custom exception types
export BUCKET_NOT_EXIST=100
IsS3BucketExists=true

# Try to list the objects in the S3 bucket
try {
    aws s3api list-objects --bucket $PipelineArtifactBucket --no-cli-pager || throw $BUCKET_NOT_EXIST
} catch || {
    case $exception_code in
        $BUCKET_NOT_EXIST)
            echo "Bucket does not exist"
            IsS3BucketExists=false
        ;;
        *)
            echo "Unknown error: $exit_code"
            throw $exit_code
        ;;
    esac
}

# Deploy the CloudFormation stack with SAM
sam deploy -t cloudformation.yaml \
           --stack-name $PipelineStackName \
           --region=$Region \
           --no-fail-on-empty-changeset \
           --capabilities=CAPABILITY_NAMED_IAM CAPABILITY_IAM \
           --parameter-overrides \
               Tags=${Tags} \
               Stage=${Stage} \
               Region=${Region} \
               Prefix=${Prefix} \
               RepoName=${RepoName} \
               GitBranch=${GitBranch} \
               Environment=${Environment} \
               XrayEnabled=${XrayEnabled} \
               GitHubOwner=${GitHubOwner} \
               ResourceStackName=${ResourceStackName} \
               GitHubRepositoryName=${GitHubRepositoryName} \
               CodeStarConnectionArn=${CodeStarConnectionArn} \
               PipelineArtifactBucket=${PipelineArtifactBucket} \
               S3Bucket=${S3Bucket} \
               S3Key=${S3Key} \
               UserPoolId=${UserPoolId} \
               IsS3BucketExists=${IsS3BucketExists}
