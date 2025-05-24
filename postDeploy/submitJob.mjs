import { Batch } from 'aws-sdk';
import * as cfnResponse from 'cfn-response-promise';

export const handler = async (event, context) => {
  const batch = new Batch();

  if (event.RequestType === 'Delete') {
    return cfnResponse.send(event, context, cfnResponse.SUCCESS);
  }

  try {
    const { JobQueue: jobQueue, JobDefinition: jobDefinition, JobName: jobName } = event.ResourceProperties;

    await batch.submitJob({
      jobName,
      jobQueue,
      jobDefinition
    }).promise();

    return cfnResponse.send(event, context, cfnResponse.SUCCESS);
  } catch (error) {
    console.error('Batch Job submit failed:', error);
    return cfnResponse.send(event, context, cfnResponse.FAILED);
  }
};
