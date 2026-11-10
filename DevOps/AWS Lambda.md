# AWS Lambda Assignment

## Contents

| # | Task | Service |
|---|------|---------|
| 1 | Add two numbers | Lambda |
| 2 | Print name, PRN, course | Lambda |
| 3 | Insert student | Lambda + DynamoDB |
| 4 | Read student by PRN | Lambda + DynamoDB |
| 5 | Update course name | Lambda + DynamoDB |
| 6 | Delete student by PRN | Lambda + DynamoDB |
| 7 | Scan all students | Lambda + DynamoDB |
| 8 | Check PRN exists before insert | Lambda + DynamoDB |
| 9 | S3 trigger: bucket and file name | Lambda + S3 |
| 10 | S3 trigger: file size | Lambda + S3 |

---

## Common Setup

### Create a Lambda function (repeat for each task)

1. AWS Console → **Lambda** → **Create function**
2. Choose **Author from scratch**
3. Function name: `task1-add-numbers` (use a name per task)
4. Runtime: **Python 3.12**
5. Click **Create function**
6. Paste the code in the **Code** tab → **Deploy**
7. **Test** tab → create a test event with the given JSON → **Test**
8. View output under **Execution results** or in **CloudWatch Logs**

### DynamoDB table (Tasks 3 to 8)

1. DynamoDB → **Tables** → **Create table**
2. Table name: `Students`
3. Partition key: `PRN` (type **String**)
4. Leave other settings as default → **Create table**

### IAM permissions (Tasks 3 to 8)

1. Lambda function → **Configuration** → **Permissions** → click the **Role name**
2. **Add permissions** → **Attach policies**
3. Attach `AmazonDynamoDBFullAccess`

### S3 bucket (Tasks 9 and 10)

1. S3 → **Create bucket** → name it (for example `lambda-trigger-bucket-001`)
2. Create the bucket in the **same region** as the Lambda function

---

## Task 1. Add Two Numbers

**Function name:** `task1-add-numbers`

**Test event:**

```json
{
  "num1": 10,
  "num2": 25
}
```

**Code:**

```python
def lambda_handler(event, context):
    num1 = event["num1"]
    num2 = event["num2"]
    result = num1 + num2
    return {
        "statusCode": 200,
        "sum": result
    }
```

**Expected output:**

```json
{
  "statusCode": 200,
  "sum": 35
}
```

---

## Task 2. Print Name, PRN, Course

**Function name:** `task2-print-student`

**Test event:**

```json
{
  "name": "Shubham Mali",
  "PRN": "2026001",
  "course": "DevOps"
}
```

**Code:**

```python
def lambda_handler(event, context):
    name = event["name"]
    prn = event["PRN"]
    course = event["course"]

    print("Name :", name)
    print("PRN :", prn)
    print("Course :", course)

    return {
        "statusCode": 200,
        "message": "Details printed successfully"
    }
```

**Expected output (Log output):**

```
Name : Shubham Mali
PRN : 2026001
Course : DevOps
```

---

## Task 3. Insert Student into DynamoDB

**Function name:** `task3-insert-student`

**Test event:**

```json
{
  "name": "Shubham Mali",
  "PRN": "2026001",
  "course": "DevOps"
}
```

**Code:**

```python
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("Students")

def lambda_handler(event, context):
    table.put_item(
        Item={
            "PRN": event["PRN"],
            "name": event["name"],
            "course": event["course"]
        }
    )
    return {
        "statusCode": 200,
        "message": "Student inserted successfully"
    }
```

**Verify:** DynamoDB → `Students` → **Explore table items**.

---

## Task 4. Read Student by PRN

**Function name:** `task4-read-student`

**Test event:**

```json
{
  "PRN": "2026001"
}
```

**Code:**

```python
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("Students")

def lambda_handler(event, context):
    response = table.get_item(Key={"PRN": event["PRN"]})

    if "Item" in response:
        print("Student found:", response["Item"])
        return {
            "statusCode": 200,
            "student": response["Item"]
        }

    return {
        "statusCode": 404,
        "message": "Student not found"
    }
```

**Expected output:**

```json
{
  "statusCode": 200,
  "student": {
    "PRN": "2026001",
    "name": "Shubham Mali",
    "course": "DevOps"
  }
}
```

---

## Task 5. Update Student's Course Name

**Function name:** `task5-update-course`

**Test event:**

```json
{
  "PRN": "2026001",
  "course": "Cloud Computing"
}
```

**Code:**

```python
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("Students")

def lambda_handler(event, context):
    try:
        response = table.update_item(
            Key={"PRN": event["PRN"]},
            UpdateExpression="SET #c = :course",
            ExpressionAttributeNames={"#c": "course"},
            ExpressionAttributeValues={":course": event["course"]},
            ConditionExpression="attribute_exists(PRN)",
            ReturnValues="UPDATED_NEW"
        )
        return {
            "statusCode": 200,
            "message": "Course updated successfully",
            "updated": response["Attributes"]
        }
    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            return {
                "statusCode": 404,
                "message": "Student not found"
            }
        raise
```

**Expected output:**

```json
{
  "statusCode": 200,
  "message": "Course updated successfully",
  "updated": {
    "course": "Cloud Computing"
  }
}
```

---

## Task 6. Delete Student by PRN

**Function name:** `task6-delete-student`

**Test event:**

```json
{
  "PRN": "2026001"
}
```

**Code:**

```python
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("Students")

def lambda_handler(event, context):
    table.delete_item(Key={"PRN": event["PRN"]})
    return {
        "statusCode": 200,
        "message": "Student deleted successfully"
    }
```

**Verify:** Run Task 4 with the same PRN; it should return `Student not found`.

---

## Task 7. Scan All Student Records

**Function name:** `task7-scan-students`

**Test event:**

```json
{}
```

**Code:**

```python
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("Students")

def lambda_handler(event, context):
    response = table.scan()
    items = response["Items"]

    while "LastEvaluatedKey" in response:
        response = table.scan(ExclusiveStartKey=response["LastEvaluatedKey"])
        items.extend(response["Items"])

    for item in items:
        print(item)

    return {
        "statusCode": 200,
        "count": len(items),
        "students": items
    }
```

**Expected output:**

```json
{
  "statusCode": 200,
  "count": 2,
  "students": [
    { "PRN": "2026001", "name": "Shubham Mali", "course": "DevOps" },
    { "PRN": "2026002", "name": "Rahul Patil", "course": "Cloud" }
  ]
}
```

---

## Task 8. Check PRN Exists Before Inserting

**Function name:** `task8-check-before-insert`

**Test event:**

```json
{
  "name": "Rahul Patil",
  "PRN": "2026002",
  "course": "Cloud"
}
```

**Code:**

```python
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("Students")

def lambda_handler(event, context):
    response = table.get_item(Key={"PRN": event["PRN"]})

    if "Item" in response:
        print("PRN already exists:", event["PRN"])
        return {
            "statusCode": 409,
            "message": "PRN already exists. Record not inserted."
        }

    table.put_item(
        Item={
            "PRN": event["PRN"],
            "name": event["name"],
            "course": event["course"]
        }
    )
    return {
        "statusCode": 200,
        "message": "Student inserted successfully"
    }
```

**Test:**

| Run | Result |
|-----|--------|
| First run | `Student inserted successfully` |
| Second run (same PRN) | `PRN already exists. Record not inserted.` |

---

## Task 9. S3 Trigger: Print Bucket Name and File Name

**Function name:** `task9-s3-bucket-file`

### Add the S3 trigger

1. Lambda function → **Add trigger**
2. Source: **S3**
3. Bucket: select your bucket
4. Event type: **All object create events**
5. Tick the **recursive invocation** acknowledgement → **Add**

**Code:**

```python
import urllib.parse

def lambda_handler(event, context):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

        print("Bucket name :", bucket)
        print("File name :", key)

    return {
        "statusCode": 200,
        "message": "S3 event processed"
    }
```

**Test:** Upload any file to the bucket.

**Verify:** CloudWatch → **Log groups** → `/aws/lambda/task9-s3-bucket-file`

**Expected log:**

```
Bucket name : lambda-trigger-bucket-001
File name : index.html
```

**Optional test event** (for the Lambda **Test** tab):

```json
{
  "Records": [
    {
      "s3": {
        "bucket": { "name": "lambda-trigger-bucket-001" },
        "object": { "key": "index.html", "size": 2048 }
      }
    }
  ]
}
```

---

## Task 10. S3 Trigger: Print File Size

**Function name:** `task10-s3-file-size`

Add the same **S3 trigger** as Task 9. Use a different bucket, or remove the Task 9 trigger first, because two functions can trigger on the same event type for one bucket only if configured through separate prefixes or an SNS/EventBridge setup.

**Code:**

```python
import urllib.parse

def lambda_handler(event, context):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
        size = record["s3"]["object"]["size"]

        print("File name :", key)
        print("Bucket :", bucket)
        print("File size :", size, "bytes")
        print("File size :", round(size / 1024, 2), "KB")

    return {
        "statusCode": 200,
        "message": "File size printed"
    }
```

**Test:** Upload a file to the bucket.

**Expected log:**

```
File name : index.html
Bucket : lambda-trigger-bucket-001
File size : 2048 bytes
File size : 2.0 KB
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `AccessDeniedException` on DynamoDB | Attach `AmazonDynamoDBFullAccess` to the Lambda role |
| `ResourceNotFoundException` | Table name must be exactly `Students` and in the same region |
| `KeyError` | Test event key names must match the code (`PRN`, `name`, `course`) |
| S3 trigger not firing | Bucket and Lambda must be in the same region; check the trigger is enabled |
| No logs for S3 test | Upload a real file; the Lambda **Test** tab uses only the manual event |
| Task 3 or 8 fails on `PRN` type | PRN must be sent as a string, for example `"2026001"` |

---

## Cleanup

- Delete the Lambda functions
- Delete the DynamoDB table `Students`
- Empty and delete the S3 bucket(s)
- Delete the CloudWatch log groups `/aws/lambda/task*`
- Delete the unused IAM roles created for each function
