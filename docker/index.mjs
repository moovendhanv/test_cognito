import { CognitoIdentityProviderClient, AdminCreateUserCommand } from "@aws-sdk/client-cognito-identity-provider";
import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import JSONStream from 'JSONStream';
import { Readable } from 'stream';

const NEW_USER_POOL_ID = process.env.NEW_USER_POOL_ID;
const REGION = process.env.REGION;
const S3_BUCKET = process.env.S3_BUCKET;
const S3_KEY = process.env.S3_KEY;

const cognitoClient = new CognitoIdentityProviderClient({ region: REGION });
const s3Client = new S3Client({ region: REGION });

const restoreUsers = async () => {
  try {
    const userData = await getBackupFromS3();
    
    let successCount = 0;
    let errorCount = 0;
    
    for (const user of userData.Users) {
        
      const emailAttr = user.Attributes.find(attr => attr.Name === "email");
      const username = emailAttr ? emailAttr.Value : user.Username;
      const attributes = user.Attributes.filter(attr => !["sub", "cognito:user_status"].includes(attr.Name));
      
      try {
        const command = new AdminCreateUserCommand({
          UserPoolId: NEW_USER_POOL_ID,
          Username: username,
          UserAttributes: attributes,
          TemporaryPassword: "TempPass123!", //TODO: Need to check other way to archive this
          MessageAction: "SUPPRESS",
        });
        
        await cognitoClient.send(command);
        console.log(`User ${username} restored successfully.`);
        successCount++;
      } catch (error) {
        console.error(`Error restoring user ${username}:`, error);
        errorCount++;
      }
    }
    
    console.log(`User restoration completed. Success: ${successCount}, Errors: ${errorCount}`);
  } catch (error) {
    console.error("Failed to restore users:", error);
    throw error;
  }
};

const getBackupFromS3 = async () => {
  try {
    const command = new GetObjectCommand({ Bucket: S3_BUCKET, Key: S3_KEY });
    const response = await s3Client.send(command);
    
    if (!response.Body) {
      throw new Error("No backup data found in S3.");
    }
    
    // Convert the S3 object body to a Node.js Readable stream
    const stream = Readable.from(response.Body);
    
    // Use JSONStream to parse the data
    return new Promise((resolve, reject) => {
      const data = {};
      let userArray = [];
      
      stream
        .pipe(JSONStream.parse('Users.*'))
        .on('data', (user) => {
          userArray.push(user);
        })
        .on('error', (error) => {
          console.error("Error parsing JSON stream:", error);
          reject(error);
        })
        .on('end', () => {
          data.Users = userArray;
          resolve(data);
        });
    });
  } catch (error) {
    console.error("Error retrieving backup from S3:", error);
    throw error;
  }
};

export const handler = async (event) => {
  try {
    await restoreUsers();
    return { statusCode: 200, body: "Restore completed successfully." };
  } catch (error) {
    console.error("Lambda execution error:", error);
    return { statusCode: 500, body: "Internal Server Error" };
  }
};

await handler({})