#!/usr/bin/env bash
STACK_NAME=$(xmllint ServerlessAngularTemplate.csproj --xpath "string(/Project/PropertyGroup/StackName)")
SPA_ROOT=$(xmllint ServerlessAngularTemplate.csproj --xpath "string(/Project/PropertyGroup/SpaRoot)")
S3_BUCKET_NAME=$(xmllint ServerlessAngularTemplate.csproj --xpath "string(/Project/PropertyGroup/S3BucketName)")
DEFAULT_AWS_REGION=$(xmllint ServerlessAngularTemplate.csproj --xpath "string(/Project/PropertyGroup/DefaultAWSRegion)")
INDEX_PAGE=$(xmllint ServerlessAngularTemplate.csproj --xpath "string(/Project/PropertyGroup/IndexPage)")
echo $STACK_NAME
echo ${SPA_ROOT%?}
API_URL=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Outputs[?OutputKey == `ApiURL`].OutputValue' --output text)
cd ${SPA_ROOT%?} && \
sed -e "s|apiUrl: ''|apiUrl: '${API_URL}'|g" ./src/environments/environment.prod.ts > ./src/environments/environment.prod.ts.tmp && \
mv ./src/environments/environment.prod.ts.tmp ./src/environments/environment.prod.ts && \
npm run build -- --prod
aws s3 mb s3://$S3_BUCKET_NAME --region $DEFAULT_AWS_REGION || true
aws s3 website s3://$S3_BUCKET_NAME --index $INDEX_PAGE --error $INDEX_PAGE
aws s3 rm s3://$S3_BUCKET_NAME --recursive
aws s3 cp ./dist s3://$S3_BUCKET_NAME --acl public-read --recursive
S3_BUCKET_LOCATION=$(aws s3api get-bucket-location --bucket $S3_BUCKET_NAME --query LocationConstraint --output text)
if [ ! $S3_BUCKET_LOCATION = "None" ]; then
    echo "View your project here: http://$S3_BUCKET_NAME.s3-website.$S3_BUCKET_LOCATION.amazonaws.com"
else
    echo "View your project here: http://$S3_BUCKET_NAME.s3-website.us-east-1.amazonaws.com"
fi