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

**Run order:** 1, 2, 3, 4, 5, 8, 7, 6, then 9 and 10. Task 6 deletes data, so run it after the other DynamoDB tasks.

---

## Basic Setup (Same for Every Function)

1. Set the region to **Asia Pacific (Mumbai) ap-south-1** (top right). Use this region for everything.
2. Lambda → **Create function** → **Author from scratch**
3. Runtime: **Python 3.12**
4. Leave the file name `lambda_function.py` and handler `lambda_function.lambda_handler` as default
5. After creating: **Configuration** → **General configuration** → **Edit** → Timeout `15 sec` → **Save**
6. Paste the code → click **Deploy** (always deploy before every test)
7. **Test** tab → paste the test event exactly → **Test**

Each task below has a **Configuration for this task** box. Do only what that box says.

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

**Configuration for this task (do this once; Tasks 4 to 8 reuse it):**

| Item | Setting |
|------|---------|
| DynamoDB table | Create it now (steps below) |
| IAM role | Create `lambda-dynamodb-role` now (steps below) |

**A. Create the table**
1. DynamoDB → **Tables** → **Create table**
2. Table name: `Students` (exact spelling)
3. Partition key: `PRN`, type **String**
4. Leave defaults → **Create table** → wait until status is **Active**

**B. Create the role**
1. IAM → **Roles** → **Create role**
2. Trusted entity: **AWS service** → Use case: **Lambda** → **Next**
3. Attach: `AWSLambdaBasicExecutionRole` and `AmazonDynamoDBFullAccess`
4. Role name: `lambda-dynamodb-role` → **Create role**

**C. Use the role in the function**
- Open AWS Console → Lambda → Functions.
- Click your function’s name.
- Open Configuration → **Permissions.**
- Under Execution role, click **Edit**.
- Choose Use an existing role.
- Select **lambda-dynamodb-role** from the dropdown.
- Click Save.
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

**Configuration for this task:**
- IAM role: **Use an existing role** → `lambda-dynamodb-role`
- Record `2026001` must exist (run Task 3 first)

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

**Configuration for this task:**
- IAM role: **Use an existing role** → `lambda-dynamodb-role`
- Record `2026001` must exist (run Task 3 first)

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

**Configuration for this task:**
- IAM role: **Use an existing role** → `lambda-dynamodb-role`
- Record `2026001` must exist (run after Tasks 4, 5, and 7)

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

**Configuration for this task:**
- IAM role: **Use an existing role** → `lambda-dynamodb-role`
- At least one record must exist (run Tasks 3 and 8 first)

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

**Configuration for this task:**
- IAM role: **Use an existing role** → `lambda-dynamodb-role`

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

**Configuration for this task:**
- Create S3 bucket `lambda-trigger-bucket-001` in `ap-south-1` (S3 → **Create bucket**)
- Add the S3 trigger (below)

### Add the S3 trigger

1. Lambda function → **Add trigger**
2. Source: **S3**
3. Bucket: `lambda-trigger-bucket-001`
4. Event type: **All object create events**
5. Leave Prefix and Suffix empty
6. Tick the **recursive invocation** acknowledgement → **Add**

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

**Test:** Upload any file (no spaces in the file name) to `lambda-trigger-bucket-001`.

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

**Configuration for this task:**
- Create a **separate** S3 bucket `lambda-trigger-bucket-002` in `ap-south-1` (a second trigger on the Task 9 bucket causes an overlap error)
- Add the S3 trigger (below)

### Add the S3 trigger

1. Lambda function → **Add trigger**
2. Source: **S3**
3. Bucket: `lambda-trigger-bucket-002` (a different bucket from Task 9)
4. Event type: **All object create events**
5. Leave Prefix and Suffix empty
6. Tick the **recursive invocation** acknowledgement → **Add**

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

**Test:** Upload a file (no spaces in the file name) to `lambda-trigger-bucket-002`.

**Verify:** CloudWatch → **Log groups** → `/aws/lambda/task10-s3-file-size`

**Expected log:**

```
File name : index.html
Bucket : lambda-trigger-bucket-002
File size : 2048 bytes
File size : 2.0 KB
```

---

## Cleanup

- Delete the Lambda functions
- Delete the DynamoDB table `Students`
- Empty and delete the S3 bucket(s)
- Delete the CloudWatch log groups `/aws/lambda/task*`
- Delete the IAM role `lambda-dynamodb-role` and the default roles created for Tasks 1, 2, 9, and 10
