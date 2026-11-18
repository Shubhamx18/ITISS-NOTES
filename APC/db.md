---

## 1. The Big Picture: How Data Is Organised

```
 MySQL SERVER
  |
  +-- DATABASE (school_db)          <- a container for related tables
  |     |
  |     +-- TABLE (students)        <- one subject = one table
  |     |     |
  |     |     +-- COLUMN (name)     <- an attribute, has a data type
  |     |     +-- ROW (1, 'Asha')   <- one record
  |     |
  |     +-- TABLE (courses)
  |
  +-- DATABASE (shop_db)
```

| Term | Meaning | Real-life analogy |
|------|---------|-------------------|
| **Database** | Named container of tables | A filing cabinet |
| **Schema** | The blueprint: tables, columns, types, keys. In MySQL, `SCHEMA` and `DATABASE` mean the same thing | The cabinet's layout plan |
| **Table** | Rows and columns about one entity | A folder in the cabinet |
| **Column (field)** | One attribute with a fixed data type | A heading in a form |
| **Row (record)** | One complete entry | One filled-in form |
| **Primary Key** | Column that uniquely identifies each row | Roll number |
| **Foreign Key** | Column that points to another table's primary key | A reference slip |

---

# PART A: FOUNDATIONS

## 2. Creating and Dropping Databases

### Syntax

```sql
CREATE DATABASE school_db;                      -- create
CREATE DATABASE IF NOT EXISTS school_db;        -- create only if missing (safe)
SHOW DATABASES;                                 -- list all
USE school_db;                                  -- select it for work

DROP DATABASE school_db;                        -- delete (PERMANENT)
DROP DATABASE IF EXISTS school_db;              -- delete only if it exists
```

> **Warning:** `DROP` has no undo and no recycle bin. Everything inside is gone.

### Best practices for naming and organising

| Do | Avoid |
|----|-------|
| `lowercase_with_underscores` (`school_db`) | Spaces or special characters (`My DB!`) |
| Meaningful names (`hr_payroll`) | Vague names (`test1`, `db2`) |
| Plural or consistent table names (`students`) | Mixing styles (`Student`, `courses_TBL`) |
| One database per application or project | Dumping unrelated tables in one database |
| Singular, clear column names (`first_name`) | Reserved words as names (`order`, `group`) |
| `IF NOT EXISTS` / `IF EXISTS` in scripts | Running bare `DROP` on shared servers |

**Memory hook:** *lowercase, underscore, meaningful, consistent.*

---

## 3. Tables and Data Types

### Create a table

```sql
CREATE TABLE students (
    student_id  INT            PRIMARY KEY AUTO_INCREMENT,
    first_name  VARCHAR(50)    NOT NULL,
    email       VARCHAR(100)   UNIQUE,
    age         INT            CHECK (age >= 16),
    fees        DECIMAL(8,2)   DEFAULT 0.00,
    joined_on   DATE
);
```

### Common data types

| Group | Types | Use for |
|-------|-------|---------|
| **Whole numbers** | `INT`, `BIGINT`, `SMALLINT`, `TINYINT` | IDs, counts, age |
| **Decimals** | `DECIMAL(p,s)`, `FLOAT`, `DOUBLE` | Money (use `DECIMAL`), measurements |
| **Text** | `CHAR(n)`, `VARCHAR(n)`, `TEXT` | Names, emails, long notes |
| **Date and time** | `DATE`, `TIME`, `DATETIME`, `TIMESTAMP` | Birthdays, logs |
| **Other** | `BOOLEAN`, `ENUM(...)`, `JSON` | Flags, fixed choices, documents |

### Common constraints

| Constraint | Rule it enforces |
|------------|------------------|
| `PRIMARY KEY` | Unique and not null; identifies the row |
| `NOT NULL` | Value is required |
| `UNIQUE` | No duplicates allowed |
| `DEFAULT x` | Use x if no value is given |
| `CHECK (cond)` | Value must satisfy the condition |
| `FOREIGN KEY` | Value must exist in the parent table |
| `AUTO_INCREMENT` | MySQL generates 1, 2, 3 ... automatically |

---

## 4. Inserting, Modifying and Deleting

### Insert data

```sql
INSERT INTO students (first_name, email, age, fees, joined_on)
VALUES ('Asha', 'asha@mail.com', 21, 15000.00, '2026-08-01');

-- many rows at once
INSERT INTO students (first_name, email, age, fees, joined_on) VALUES
  ('Ravi',  'ravi@mail.com',  23, 18000.00, '2026-08-01'),
  ('Meena', 'meena@mail.com', 22, 15000.00, '2026-08-02');
```

### Modify a table (`ALTER`)

```sql
ALTER TABLE students ADD COLUMN city VARCHAR(40);           -- add column
ALTER TABLE students MODIFY COLUMN city VARCHAR(60);        -- change type
ALTER TABLE students RENAME COLUMN city TO home_city;       -- rename column
ALTER TABLE students DROP COLUMN home_city;                 -- remove column
RENAME TABLE students TO learners;                          -- rename table
```

### Modify and delete data

```sql
UPDATE students SET fees = 20000 WHERE student_id = 2;      -- change a row
DELETE FROM students WHERE student_id = 3;                  -- remove a row
```

### Remove tables

| Command | Removes | Structure survives? | Undo? |
|---------|---------|:-------------------:|:-----:|
| `DELETE FROM t WHERE ...` | Selected rows | Yes | Yes inside a transaction |
| `TRUNCATE TABLE t` | All rows, resets AUTO_INCREMENT | Yes | No |
| `DROP TABLE t` | Rows and the table itself | No | No |

> **Golden rule:** `UPDATE` and `DELETE` without `WHERE` hit **every row**.

---

## 5. Lab Flow: Create a User, Build, Fill, Change

```sql
-- STEP 1: create a MySQL user (run as root/admin)
CREATE USER 'student1'@'localhost' IDENTIFIED BY 'Str0ng#Pass';
GRANT ALL PRIVILEGES ON school_db.* TO 'student1'@'localhost';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'student1'@'localhost';

-- STEP 2: create database and tables
CREATE DATABASE school_db;
USE school_db;

CREATE TABLE departments (
    dept_id    INT PRIMARY KEY AUTO_INCREMENT,
    dept_name  VARCHAR(50) NOT NULL
);

CREATE TABLE employees (
    emp_id     INT PRIMARY KEY AUTO_INCREMENT,
    emp_name   VARCHAR(50) NOT NULL,
    salary     DECIMAL(10,2),
    dept_id    INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- STEP 3: add data
INSERT INTO departments (dept_name) VALUES ('IT'), ('HR'), ('Sales'), ('Legal');
INSERT INTO employees (emp_name, salary, dept_id) VALUES
  ('Asha',  60000, 1),
  ('Ravi',  45000, 1),
  ('Meena', 52000, 2),
  ('Karan', 38000, 3),
  ('Sneha', 41000, 3),
  ('Omkar', 70000, 1),
  ('Zoya',  35000, NULL);

-- STEP 4: modify and delete
ALTER TABLE employees ADD COLUMN city VARCHAR(40);
UPDATE employees SET city = 'Pune' WHERE dept_id = 1;
DROP TABLE IF EXISTS temp_table;
DROP DATABASE IF EXISTS old_db;
```

### User management quick reference

| Task | Command |
|------|---------|
| Create user | `CREATE USER 'u'@'localhost' IDENTIFIED BY 'pw';` |
| Give rights | `GRANT SELECT, INSERT ON db.* TO 'u'@'localhost';` |
| Take rights | `REVOKE INSERT ON db.* FROM 'u'@'localhost';` |
| Delete user | `DROP USER 'u'@'localhost';` |

**Recap:** Server contains databases, databases contain tables, tables contain rows and columns. Build with `CREATE`, fill with `INSERT`, reshape with `ALTER`, destroy with `DROP`. Always protect `UPDATE`/`DELETE` with `WHERE`.

---

### Sample data used from here on

**departments**

| dept_id | dept_name |
|:-------:|-----------|
| 1 | IT |
| 2 | HR |
| 3 | Sales |
| 4 | Legal |

**employees**

| emp_id | emp_name | salary | dept_id |
|:------:|----------|-------:|:-------:|
| 1 | Asha | 60000 | 1 |
| 2 | Ravi | 45000 | 1 |
| 3 | Meena | 52000 | 2 |
| 4 | Karan | 38000 | 3 |
| 5 | Sneha | 41000 | 3 |
| 6 | Omkar | 70000 | 1 |
| 7 | Zoya | 35000 | NULL |

---

# PART B: QUERYING

## 6. SELECT: Fetching Data

```sql
SELECT * FROM employees;                         -- all columns, all rows
SELECT emp_name, salary FROM employees;          -- chosen columns
SELECT emp_name AS name, salary * 12 AS yearly   -- aliases and calculations
FROM employees;
SELECT DISTINCT dept_id FROM employees;          -- remove duplicates
SELECT * FROM employees LIMIT 3;                 -- first 3 rows
```

**Reading order of a query in your head:** *SELECT what, FROM where, WHERE which rows, ORDER BY how.*

---

## 7. WHERE: Filtering Rows

```sql
SELECT * FROM employees WHERE salary > 40000;
SELECT * FROM employees WHERE dept_id = 1 AND salary >= 60000;
SELECT * FROM employees WHERE dept_id = 2 OR dept_id = 3;
```

### Operator toolbox

| Type | Operators | Example |
|------|-----------|---------|
| Compare | `=  !=  <>  <  >  <=  >=` | `salary >= 50000` |
| Logic | `AND  OR  NOT` | `dept_id = 1 AND salary > 50000` |
| Range | `BETWEEN a AND b` (inclusive) | `salary BETWEEN 40000 AND 60000` |
| List | `IN (...)` / `NOT IN (...)` | `dept_id IN (1, 3)` |
| Pattern | `LIKE` with `%` (any text) and `_` (one char) | `emp_name LIKE 'A%'` |
| Null test | `IS NULL` / `IS NOT NULL` | `dept_id IS NULL` |

**Pattern cheat**

| Pattern | Matches |
|---------|---------|
| `'A%'` | Starts with A |
| `'%a'` | Ends with a |
| `'%an%'` | Contains "an" |
| `'_s%'` | Second letter is s |

> **Trap:** `dept_id = NULL` never works. NULL is "unknown", so use `IS NULL`.

**Precedence:** `NOT` first, then `AND`, then `OR`. Use brackets when mixing: `WHERE (a OR b) AND c`.

---

## 8. ORDER BY: Sorting Results

```sql
SELECT * FROM employees ORDER BY salary;                    -- ascending (default)
SELECT * FROM employees ORDER BY salary DESC;               -- highest first
SELECT * FROM employees ORDER BY dept_id ASC, salary DESC;  -- sort by two keys
SELECT * FROM employees ORDER BY salary DESC LIMIT 3;       -- top 3 earners
```

| Keyword | Direction | Use case |
|---------|-----------|----------|
| `ASC` | Small to large, A to Z, old to new | Default |
| `DESC` | Large to small, Z to A, new to old | Top-N, latest first |

**Analytical patterns**

```sql
-- Top 3 highest paid
SELECT emp_name, salary FROM employees ORDER BY salary DESC LIMIT 3;
-- Lowest paid in department 3
SELECT emp_name, salary FROM employees WHERE dept_id = 3 ORDER BY salary LIMIT 1;
```

---

## 9. JOIN: Combining Tables

**Why?** Data is split across tables to avoid repetition. A JOIN stitches it back together using a matching column (the foreign key).

```
 employees                     departments
 +--------+---------+         +---------+-----------+
 | emp_id | dept_id |--match--| dept_id | dept_name |
 +--------+---------+         +---------+-----------+
```

### The four joins

```
 INNER JOIN         LEFT JOIN          RIGHT JOIN         FULL (UNION)
  A ( [x] ) B       A ( [x] ) B         A ( [x] ) B       A ( [x] ) B
  only matches      all of A +          all of B +         everything
  (the overlap)     matches from B      matches from A
```

| Join | Returns | Unmatched rows |
|------|---------|----------------|
| `INNER JOIN` | Only rows with a match in both tables | Dropped |
| `LEFT JOIN` | All rows from the left table | Right side shows `NULL` |
| `RIGHT JOIN` | All rows from the right table | Left side shows `NULL` |
| `CROSS JOIN` | Every row paired with every row (A x B) | Not applicable |

### Examples with our data

```sql
-- INNER: employees that have a department
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
```
Result: 6 rows (Zoya is missing because her `dept_id` is NULL).

```sql
-- LEFT: all employees, department if any
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
```
Result: 7 rows (Zoya appears with `dept_name = NULL`).

```sql
-- RIGHT: all departments, employees if any
SELECT d.dept_name, e.emp_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
```
Result: includes **Legal** with `emp_name = NULL`.

```sql
-- Find departments with NO employees (LEFT + IS NULL trick)
SELECT d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;
```

### Join checklist

1. Pick the tables.
2. Give them short aliases (`e`, `d`).
3. State the match with `ON`.
4. Choose the join type by asking: "Do I want unmatched rows?"

**Recap:** `SELECT` picks columns, `WHERE` picks rows, `ORDER BY` arranges them, `JOIN` merges tables. Unmatched rows are what separates INNER from LEFT and RIGHT.

---

# PART C: AGGREGATION

## 10. Aggregate Functions: Many Rows In, One Value Out

| Function | Does | Example | Result on our data |
|----------|------|---------|-------------------:|
| `COUNT(*)` | Counts all rows | `SELECT COUNT(*) FROM employees;` | 7 |
| `COUNT(col)` | Counts non-NULL values | `COUNT(dept_id)` | 6 |
| `SUM(col)` | Total | `SUM(salary)` | 341000 |
| `AVG(col)` | Average | `AVG(salary)` | 48714.29 |
| `MIN(col)` | Smallest | `MIN(salary)` | 35000 |
| `MAX(col)` | Largest | `MAX(salary)` | 70000 |

```sql
SELECT COUNT(*) AS total_staff,
       SUM(salary) AS payroll,
       AVG(salary) AS avg_pay,
       MAX(salary) AS top_pay
FROM employees;
```

> Aggregates **ignore NULL** (except `COUNT(*)`).

---

## 11. GROUP BY: One Result per Group

```
 Raw rows                     GROUP BY dept_id            Aggregate each group
 --------------------         ---------------------       ---------------------
 Asha   IT   60000            [IT]    60000               IT     -> SUM = 175000
 Ravi   IT   45000    ---->           45000     ---->     HR     -> SUM =  52000
 Omkar  IT   70000                    70000               Sales  -> SUM =  79000
 Meena  HR   52000            [HR]    52000
 Karan  Sales 38000           [Sales] 38000
 Sneha  Sales 41000                   41000
```

```sql
SELECT dept_id, COUNT(*) AS headcount, AVG(salary) AS avg_pay
FROM employees
GROUP BY dept_id;
```

| dept_id | headcount | avg_pay |
|:-------:|:---------:|--------:|
| 1 | 3 | 58333.33 |
| 2 | 1 | 52000.00 |
| 3 | 2 | 39500.00 |
| NULL | 1 | 35000.00 |

**With a join, to show department names**

```sql
SELECT d.dept_name, COUNT(e.emp_id) AS headcount, SUM(e.salary) AS payroll
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
```

> **Rule:** every column in `SELECT` must be either inside an aggregate function or listed in `GROUP BY`.

---

## 12. HAVING: Filtering Groups

```sql
-- Departments whose average salary is above 40000
SELECT dept_id, AVG(salary) AS avg_pay
FROM employees
GROUP BY dept_id
HAVING AVG(salary) > 40000;
```

### WHERE vs HAVING

| | `WHERE` | `HAVING` |
|---|---------|----------|
| Filters | Individual **rows** | Whole **groups** |
| Runs | **Before** grouping | **After** grouping |
| Can use aggregates? | No | Yes |
| Example | `WHERE salary > 40000` | `HAVING COUNT(*) > 2` |

**Using both together**

```sql
-- Ignore people earning under 40000, then keep only groups with 2+ people
SELECT dept_id, COUNT(*) AS headcount
FROM employees
WHERE salary >= 40000      -- row filter first
GROUP BY dept_id
HAVING COUNT(*) >= 2;      -- group filter after
```

**Memory hook:** *WHERE filters people; HAVING filters teams.*

---

## 13. Subqueries: A Query Inside a Query

A subquery runs first, and its result feeds the outer query.

```
 SELECT ...  FROM employees
 WHERE salary > ( SELECT AVG(salary) FROM employees );
                  \_______ inner query runs first ______/
```

### Where subqueries can live

| Position | Example | Purpose |
|----------|---------|---------|
| In `WHERE` (single value) | `salary > (SELECT AVG(salary) FROM employees)` | Compare to a computed value |
| In `WHERE` with `IN` (list) | `dept_id IN (SELECT dept_id FROM departments WHERE dept_name = 'IT')` | Match against a set |
| In `FROM` (derived table) | `FROM (SELECT dept_id, AVG(salary) a FROM employees GROUP BY dept_id) t` | Query a summary |
| In `SELECT` | `(SELECT COUNT(*) FROM employees)` as a column | Show a computed value per row |
| With `EXISTS` | `WHERE EXISTS (SELECT 1 FROM employees e WHERE e.dept_id = d.dept_id)` | Check that related rows exist |

### Examples

```sql
-- Employees earning above company average
SELECT emp_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Employees who work in IT
SELECT emp_name
FROM employees
WHERE dept_id IN (SELECT dept_id FROM departments WHERE dept_name = 'IT');

-- Second highest salary (nested)
SELECT MAX(salary)
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- Departments that have no employees
SELECT dept_name
FROM departments
WHERE dept_id NOT IN (SELECT dept_id FROM employees WHERE dept_id IS NOT NULL);
```

> **Trap:** `NOT IN` returns nothing if the subquery contains a NULL. Filter NULLs out, as shown above.

### Subquery types in one line each

| Type | Returns |
|------|---------|
| Scalar | One value (one row, one column) |
| Row / column | A list of values, used with `IN`, `ANY`, `ALL` |
| Table | A full result used like a table in `FROM` |
| Correlated | Depends on the outer row, so it re-runs for each row |

**Recap:** Aggregates collapse rows, `GROUP BY` makes one collapse per group, `HAVING` filters those groups, and subqueries let one query feed another.

---

# PART D: THE MASTER VIEW

## 14. The Full Query Anatomy

How you **write** it:

```sql
SELECT   columns / aggregates        -- 5
FROM     table                       -- 1
JOIN     other_table ON condition    -- 2
WHERE    row_condition               -- 3
GROUP BY grouping_columns            -- 4
HAVING   group_condition             -- 6
ORDER BY sort_columns                -- 7
LIMIT    n;                          -- 8
```

How MySQL **executes** it (numbers above):

```
 FROM/JOIN --> WHERE --> GROUP BY --> SELECT --> HAVING --> ORDER BY --> LIMIT
   pick &      filter     make        compute    filter     sort        cut
   merge       rows       groups      columns    groups
```

**Memory hook:** *"From Jane's Wonderful Garden, Selecting Healthy Orchids Lovingly"*
(**F**rom, **J**oin, **W**here, **G**roup by, **S**elect, **H**aving, **O**rder by, **L**imit)

---

## 15. One-Page Cheat Sheet

| I want to... | Use |
|--------------|-----|
| Make / remove a database | `CREATE DATABASE x;` / `DROP DATABASE x;` |
| Switch database | `USE x;` |
| Make a table | `CREATE TABLE t (col type constraint, ...);` |
| Add rows | `INSERT INTO t (cols) VALUES (...);` |
| Change a row | `UPDATE t SET c = v WHERE ...;` |
| Delete rows | `DELETE FROM t WHERE ...;` |
| Change structure | `ALTER TABLE t ADD / MODIFY / DROP COLUMN ...;` |
| Get data | `SELECT cols FROM t;` |
| Filter rows | `WHERE`, `AND`, `OR`, `IN`, `BETWEEN`, `LIKE`, `IS NULL` |
| Sort | `ORDER BY col ASC/DESC` |
| Top N | `ORDER BY col DESC LIMIT n` |
| Combine tables | `INNER / LEFT / RIGHT JOIN ... ON ...` |
| Calculate | `COUNT, SUM, AVG, MIN, MAX` |
| Group | `GROUP BY col` |
| Filter groups | `HAVING aggregate_condition` |
| Query in a query | `WHERE col > (SELECT ...)` |

---

## 16. Top Mistakes and Fixes

| Mistake | Fix |
|---------|-----|
| `UPDATE` / `DELETE` without `WHERE` | Always write `WHERE` first, test with `SELECT` |
| `= NULL` | Use `IS NULL` |
| Aggregate in `WHERE` | Move it to `HAVING` |
| Selecting a column not in `GROUP BY` | Add it to `GROUP BY` or wrap it in an aggregate |
| `INNER JOIN` loses unmatched rows | Use `LEFT JOIN` if you need them |
| `NOT IN` with NULLs in subquery | Add `WHERE col IS NOT NULL` inside the subquery |
| Forgetting `ON` in a join | Creates a huge cross product |
| `DROP` on the wrong database | Use `SHOW DATABASES;` and `USE` to confirm first |

---

## 17. Practice Drills (Try Without Looking)

**Build**
1. Create a database `company_db` and select it.
2. Create `departments` and `employees` tables with a primary key and a foreign key.
3. Insert at least 5 employees across 3 departments.
4. Add a `city` column, then drop it again.

**Query**
5. List all employees earning more than 45000, highest first.
6. List employees whose name starts with `S` or ends with `a`.
7. Show every employee with their department name (INNER JOIN).
8. Show every department, even those with no employees (LEFT JOIN).

**Summarise**
9. Total payroll and average salary of the company.
10. Headcount per department.
11. Departments with more than 1 employee (HAVING).
12. Employees earning more than the average of their own department (correlated subquery).

<details>
<summary>Answers</summary>

```sql
-- 5
SELECT * FROM employees WHERE salary > 45000 ORDER BY salary DESC;
-- 6
SELECT * FROM employees WHERE emp_name LIKE 'S%' OR emp_name LIKE '%a';
-- 7
SELECT e.emp_name, d.dept_name FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- 8
SELECT d.dept_name, e.emp_name FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;
-- 9
SELECT SUM(salary), AVG(salary) FROM employees;
-- 10
SELECT dept_id, COUNT(*) FROM employees GROUP BY dept_id;
-- 11
SELECT dept_id, COUNT(*) FROM employees GROUP BY dept_id HAVING COUNT(*) > 1;
-- 12
SELECT emp_name, salary FROM employees e
WHERE salary > (SELECT AVG(salary) FROM employees WHERE dept_id = e.dept_id);
```
</details>

---

## 18. Final Mental Model

```
        +------------------------------------------------+
        |  BUILD  ->  CREATE, INSERT, ALTER, DROP        |
        |  ASK    ->  SELECT, WHERE, ORDER BY, JOIN      |
        |  SUMMARISE -> COUNT/SUM/AVG, GROUP BY, HAVING  |
        |  NEST   ->  (SELECT ... ) inside SELECT        |
        +------------------------------------------------+
         Rows are filtered by WHERE. Groups are filtered by HAVING.
         INNER keeps matches. LEFT keeps everything on the left.
```
