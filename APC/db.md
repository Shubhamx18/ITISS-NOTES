# MySQL Complete Visual & Conceptual Mastery Guide

A crystal-clear, intuition-first handbook covering the core pillars of MySQL: **Database Architecture & Security**, **Querying, Filtering & Joins**, and **Aggregations, Grouping & Subqueries**.

---

## 1. The Mental Model: How MySQL Thinks

Before memorizing commands, visualize how MySQL stores data and how it processes your queries.

### The Filing Cabinet Architecture

```text
MySQL Server (The RDBMS Software — Controlled via SQL)
 └── Database / Schema: `college_db`  <-- The Filing Cabinet (CREATE / USE / DROP)
      ├── Table: `departments`       <-- Parent Register (Identified by PRIMARY KEY)
      └── Table: `students`          <-- Child Register (Linked via FOREIGN KEY)
           ├── Columns (Attributes)  <-- Vertical Headers: id, name, age, city
           └── Rows (Tuples/Records) <-- Horizontal Entries: (1, 'Asha', 21, 'Pune')
```

### Core Terminology Made Simple

* **SQL vs. MySQL:** **SQL** is the *language* you speak; **MySQL** is the *database engine* that understands SQL, stores data on disk, and enforces rules.
* **DBMS vs. RDBMS:** A **DBMS** manages raw data files; an **RDBMS** organizes data into structured 2D tables linked together by keys. MySQL is an RDBMS.
* **Database vs. Schema:** In **MySQL**, `DATABASE` and `SCHEMA` mean the **exact same thing** (`CREATE SCHEMA x;` is identical to `CREATE DATABASE x;`). *(In systems like PostgreSQL or SQL Server, one database contains multiple schemas.)*
* **Relational Math Terms:**
  * **Table** = **Relation**
  * **Row** = **Record** or **Tuple** (one complete horizontal entry)
  * **Column** = **Field** or **Attribute** (one vertical property)
  * **Degree (Arity)** = Number of **Columns** (**D**egree = **C**olumns)
  * **Cardinality** = Number of **Rows** (**C**ardinality = **R**ows)

### How MySQL Actually Executes a Query (The Secret Behind Every SQL Rule)

You **write** a query starting with `SELECT`, but MySQL **executes** it in a completely different internal order. Memorizing this 8-step pipeline makes almost every SQL error immediately obvious:

```text
[1] FROM & JOIN   ──▶ Gather tables and combine matching rows
[2] WHERE         ──▶ Throw away individual rows that fail conditions (Aliases don't exist yet!)
[3] GROUP BY      ──▶ Collapse surviving rows into summary buckets
[4] HAVING        ──▶ Throw away entire buckets that fail aggregate conditions
[5] SELECT        ──▶ Calculate columns, run SUM/COUNT/AVG, and assign column aliases
[6] DISTINCT      ──▶ Remove duplicate output rows
[7] ORDER BY      ──▶ Sort the final result (Aliases ARE available here!)
[8] LIMIT         ──▶ Slice off the top N rows to return
```

> **Why does `WHERE total > 100` fail when `total` is an alias in `SELECT`?**
> Because Step 2 (`WHERE`) runs *before* Step 5 (`SELECT`) creates the alias! Meanwhile, `ORDER BY total` works because Step 7 runs *after* Step 5.

### SQL Command Families & Undo Rules

| Family | Full Name | Commands | Auto-Saves Immediately? | Can `ROLLBACK` (Undo)? |
| :--- | :--- | :--- | :---: | :---: |
| **DDL** | Data Definition Language | `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME` | **Yes** | **No** |
| **DML** | Data Manipulation Language | `INSERT`, `UPDATE`, `DELETE` | No (inside a transaction) | **Yes** |
| **DQL** | Data Query Language | `SELECT` | N/A (Read-only) | N/A |
| **DCL** | Data Control Language | `GRANT`, `REVOKE` | **Yes** | **No** |

---

## 2. Pillar I: Databases, Tables & User Security

### Creating, Renaming & Navigating Databases

A brand-new database is a completely empty container (**0 tables**) until you build tables inside it.

```sql
-- 1. Standard creation (Throws ERROR 1007 if database already exists)
CREATE DATABASE college_db;

-- 2. Safe creation (Skips creation & emits a warning if it exists; NEVER overwrites data)
CREATE DATABASE IF NOT EXISTS college_db;

-- 3. Production standard (Supports all Unicode/emojis + case-insensitive sorting)
CREATE DATABASE IF NOT EXISTS college_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 4. Navigation & Inspection
SHOW DATABASES;       -- Lists every database your account is allowed to see
USE college_db;       -- Steps inside college_db to make it your active workspace
SELECT DATABASE();    -- Prints active database name (returns NULL if you haven't run USE yet)
```

> **Exam Note on Renaming a Database:** MySQL has **no** `RENAME DATABASE` command. To rename a database, you must create a new database, move each table using `RENAME TABLE old_db.tbl TO new_db.tbl;`, and drop the old database.

### Naming Rules vs. Best Practices

#### Hard Rules (Breaking these causes errors or cross-platform crashes)
1. **64-Character Limit:** Database, table, and column names cannot exceed **64 characters**.
2. **Reserved Keywords:** Naming a table `order`, `select`, or `user` causes a syntax error unless wrapped in **backticks** (`` `order` ``).
3. **Linux vs. Windows Case Sensitivity:**
   * MySQL stores databases as OS folders and tables as files.
   * **Linux** is case-sensitive (`college_db` $\neq$ `College_DB`).
   * **Windows / macOS** are case-insensitive (`college_db` $=$ `College_DB`).
   * **Golden Rule:** Always use **lowercase `snake_case`** everywhere so your SQL never breaks when moved to a Linux server.
4. **Backticks vs. Single Quotes:**
   * **Single quotes (`'Asha'`)** $\rightarrow$ Wrap **text and date values** (data).
   * **Backticks (`` `students` ``)** $\rightarrow$ Wrap **identifiers** (database, table, or column names).

#### Clean Architecture Habits
* Name databases after their domain (`college_db`, `inventory_db`), never vague names (`db1`, `test`).
* Group related tables inside one database (`students`, `courses`, `departments` inside `college_db`).
* Separate environments cleanly (`college_dev`, `college_prod`).

### User Creation & Permission Scoping

A MySQL user is a **server login account**, completely separate from rows inside a `students` or `users` table. MySQL identifies every account by **both username and connection host**: `'username'@'host'`.

* `'lab_student'@'localhost'` $\rightarrow$ Can connect **only** from the same computer running MySQL.
* `'lab_student'@'%'` $\rightarrow$ Can connect from **any remote IP address** (`%` = wildcard).
* MySQL treats `'lab_student'@'localhost'` and `'lab_student'@'%'` as **two completely separate accounts** with their own passwords and permissions.

```sql
-- 1. Create a local user (starts with ZERO database permissions — only login capability)
CREATE USER 'lab_student'@'localhost' IDENTIFIED BY 'StrongPass@123';

-- 2. Grant full control strictly over all tables (*) inside college_db
GRANT ALL PRIVILEGES ON college_db.* TO 'lab_student'@'localhost';

-- 3. Inspect exact permissions assigned to the user
SHOW GRANTS FOR 'lab_student'@'localhost';

-- 4. Revoke specific permissions or drop user when finished
REVOKE INSERT, UPDATE ON college_db.* FROM 'lab_student'@'localhost';
DROP USER 'lab_student'@'localhost';
```

> **Privilege Scope Quick Guide:**
> * `*.*` $\rightarrow$ Every table in every database on the entire server (Admin level)
> * `college_db.*` $\rightarrow$ Every table inside `college_db` only
> * `college_db.students` $\rightarrow$ Only the `students` table inside `college_db`

### Essential Data Types & Constraints

| Category | Common Types | Purpose & Exam Detail |
| :--- | :--- | :--- |
| **Whole Numbers** | `INT`, `TINYINT`, `BIGINT` | `INT` = 4 bytes. Add `UNSIGNED` to block negative values (`INT UNSIGNED`). |
| **Decimals** | `DECIMAL(10,2)`, `DOUBLE` | Use `DECIMAL(p,s)` for exact money values ($p$ total digits, $s$ after decimal). |
| **Text** | `CHAR(n)`, `VARCHAR(n)`, `TEXT` | `CHAR(n)` is fixed-length (padded with spaces); `VARCHAR(n)` is variable-length. |
| **Date & Time** | `DATE`, `DATETIME`, `TIMESTAMP` | `DATE` = `'2026-10-08'`; `DATETIME` = `'2026-10-08 14:30:00'`. |
| **Boolean** | `BOOLEAN` | Stored internally in MySQL as `TINYINT(1)` (`1` = true, `0` = false). |

| Constraint | Rule Enforced | Key Detail |
| :--- | :--- | :--- |
| **`PRIMARY KEY`** | Uniquely identifies every row | Automatically enforces **`UNIQUE` + `NOT NULL`**. Only **1** per table. |
| **`AUTO_INCREMENT`** | Automatically generates sequential IDs | Must be indexed (usually paired with `PRIMARY KEY`). |
| **`NOT NULL`** | Rejects missing (`NULL`) values | Must supply a value on `INSERT` unless `DEFAULT` is defined. |
| **`UNIQUE`** | Prevents duplicate values in a column | Allows multiple `NULL` values in MySQL. |
| **`DEFAULT`** | Supplies a fallback value | Used automatically when no value is provided during `INSERT`. |
| **`CHECK`** | Enforces a logical condition (MySQL 8.0+) | Example: `CHECK (age >= 18)`. |
| **`FOREIGN KEY`** | Links child column to parent `PRIMARY KEY` | Prevents orphan rows; parent row must exist before inserting child row. |

#### Foreign Key `ON DELETE` / `ON UPDATE` Actions
When a parent row is deleted or updated:
* **`RESTRICT` / `NO ACTION` (Default):** Blocks the deletion/update if matching child rows exist.
* **`CASCADE`:** Automatically deletes or updates matching child rows.
* **`SET NULL`:** Sets the foreign key column in child rows to `NULL`.

### Building Tables & Inserting Data

```sql
USE college_db;

-- Parent table must be created BEFORE any child table that references it
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE students (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    age INT CHECK (age >= 16),
    city VARCHAR(30) DEFAULT 'Pune',
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL
);

-- Inspect structure
SHOW TABLES;
DESCRIBE students;          -- Shows 6 columns: Field, Type, Null, Key, Default, Extra
SHOW CREATE TABLE students; -- Shows full CREATE statement and system-generated constraint names

-- Insert Parent records first
INSERT INTO departments (dept_id, dept_name) VALUES
    (10, 'Computer Science'),
    (20, 'Cyber Security'),
    (30, 'Data Science');

-- Insert Child records (multi-row insert)
INSERT INTO students (id, name, age, city, dept_id) VALUES
    (1, 'Asha', 21, 'Pune', 10),
    (2, 'Ravi', 22, 'Nashik', 20),
    (3, 'Neha', 20, 'Mumbai', 10),
    (4, 'Kabir', 23, 'Pune', NULL);
```

### Modifying & Destroying Structures

#### Remodeling Tables (`ALTER TABLE` & `RENAME TABLE`)

```sql
-- Add a new column (can specify FIRST or AFTER another column)
ALTER TABLE students ADD COLUMN email VARCHAR(100) AFTER name;

-- Change column data type, size, or position
ALTER TABLE students MODIFY COLUMN name VARCHAR(100) NOT NULL;

-- Rename a column (MySQL 8.0+ clean syntax)
ALTER TABLE students RENAME COLUMN name TO student_name;

-- Rename AND/OR change data type at once
ALTER TABLE students CHANGE COLUMN student_name full_name VARCHAR(120);

-- Permanently remove a column and its data
ALTER TABLE students DROP COLUMN email;

-- Rename the entire table (Once renamed, the old name 'students' no longer exists!)
RENAME TABLE students TO student_details;
```

#### The Destruction Hierarchy (`DELETE` vs. `TRUNCATE` vs. `DROP`)

| Command | Analogy | Keeps Empty Table? | Resets `AUTO_INCREMENT`? | Allows `WHERE`? | Can `ROLLBACK`? |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **`DELETE FROM tbl`** | Erasing specific lines in a register | Yes | No | **Yes** | **Yes** |
| **`TRUNCATE TABLE tbl`** | Tearing out all pages, keeping the cover | Yes | **Yes** (resets to `1`) | No | **No** |
| **`DROP TABLE tbl`** | Burning the entire register | **No** | N/A | No | **No** |
| **`DROP DATABASE db`** | Demolishing the entire filing cabinet | **No** | N/A | No | **No** |

```sql
-- Safe teardown sequence (Always drop Child tables before Parent tables)
DROP TABLE IF EXISTS student_details;
DROP TABLE IF EXISTS departments;
DROP DATABASE IF EXISTS college_db;
```

---

## 3. Pillar II: Querying, Filtering, Sorting & Joins

### Fetching & Deduplicating Data (`SELECT` & `DISTINCT`)

```sql
-- Fetch specific columns and calculated expressions with readable aliases
SELECT id, name AS student_name, age + 1 AS next_year_age
FROM students;

-- Return unique cities only
SELECT DISTINCT city FROM students;

-- Multi-column DISTINCT: returns unique pairs of (city + dept_id)
SELECT DISTINCT city, dept_id FROM students;
```

> **Key Rule:** `DISTINCT` must immediately follow `SELECT` and applies to the **entire row** of selected columns combined, never just the first column.

### Precision Filtering (`WHERE`)

`WHERE` tests every row and keeps only rows where the condition evaluates to **`TRUE`**.

| Operator | Purpose | Example | Crucial Detail |
| :--- | :--- | :--- | :--- |
| `=`, `<>` (`!=`), `<`, `>`, `<=`, `>=` | Standard comparisons | `WHERE age >= 21` | `<>` is standard SQL; `!=` also works in MySQL |
| `<=>` | `NULL`-safe equal | `WHERE dept_id <=> NULL` | Returns `TRUE` even when comparing `NULL <=> NULL` |
| `AND`, `OR`, `NOT` | Combine conditions | `WHERE city = 'Pune' AND age > 20` | **Precedence:** `NOT` $\rightarrow$ `AND` $\rightarrow$ `OR` (use parentheses!) |
| `BETWEEN a AND b` | Inclusive range | `WHERE age BETWEEN 20 AND 22` | Includes **both** `20` and `22` (`>= 20 AND <= 22`) |
| `IN (v1, v2, ...)` | Match any item in list | `WHERE city IN ('Pune', 'Mumbai')` | Cleaner replacement for chained `OR` statements |
| `LIKE 'pattern'` | Text wildcard search | `WHERE name LIKE '_a%'` | `%` = 0 or more chars; `_` = **exact 1 char** (`_a%` = 2nd letter `'a'`) |
| `IS NULL` / `IS NOT NULL` | Test for missing values | `WHERE dept_id IS NULL` | **Never write `= NULL`** |

#### Understanding `NULL` (Three-Valued Logic)
In SQL, `NULL` does **not** mean zero or blank—it means **"unknown"**. Because an unknown value cannot be proven equal or unequal to anything:
* `NULL = NULL` evaluates to **`UNKNOWN`** (treated as false in `WHERE`), **never `TRUE`**.
* `WHERE city <> 'Pune'` silently **excludes** rows where `city` is `NULL`!
* `WHERE dept_id NOT IN (10, 20, NULL)` returns **0 rows** because `x <> NULL` is `UNKNOWN` for every row.
* **Fallback Helpers:** `IFNULL(col, 'N/A')` or `COALESCE(col1, col2, 'N/A')` replaces `NULL` with the first non-`NULL` value in the output.

### Sorting & Pagination (`ORDER BY` & `LIMIT`)

Without `ORDER BY`, SQL makes **zero guarantees** about the order in which rows appear.

```sql
-- Sort by age highest-to-lowest; break ties alphabetically by name
SELECT name, age
FROM students
ORDER BY age DESC, name ASC;

-- Pagination pattern: Skip the 1st oldest student, return the next 2
SELECT name, age
FROM students
ORDER BY age DESC
LIMIT 2 OFFSET 1;
```

> **How `NULL` Sorts in MySQL:** MySQL treats `NULL` as the **lowest possible value**—so `ORDER BY col ASC` puts `NULL`s **first**, and `ORDER BY col DESC` puts `NULL`s **last**.

### Combining Tables (`JOIN`)

Joins stitch columns from multiple tables together side-by-side using matching key columns.

```text
Left Table: `students`            Right Table: `departments`
+----+-------+---------+          +---------+------------------+
| id | name  | dept_id |          | dept_id | dept_name        |
+----+-------+---------+          +---------+------------------+
| 1  | Asha  | 10      | <======> | 10      | Computer Science |
| 2  | Ravi  | 20      | <======> | 20      | Cyber Security   |
| 4  | Kabir | NULL    |   (no)   | 30      | Data Science     |
+----+-------+---------+          +---------+------------------+
```

| Join Type | What It Keeps | Result on Example Above |
| :--- | :--- | :--- |
| **`INNER JOIN`** (`JOIN`) | Only rows that match in **both** tables | Asha (`10`), Ravi (`20`) — *Kabir & Data Science dropped* |
| **`LEFT JOIN`** | **All Left rows** + matched Right rows (`NULL` if none) | Asha (`10`), Ravi (`20`), **Kabir (`NULL`)** |
| **`RIGHT JOIN`** | **All Right rows** + matched Left rows (`NULL` if none) | Asha (`10`), Ravi (`20`), **`NULL` (Data Science)** |
| **`CROSS JOIN`** | Every Left row paired with every Right row (Cartesian) | $4 \text{ students} \times 3 \text{ depts} = 12 \text{ combinations}$ |
| **`SELF JOIN`** | A table joined to **itself** via two different aliases | Matching employees to their managers in one table |

```sql
-- 1. Standard INNER JOIN (USING(dept_id) can replace ON when column names match)
SELECT s.name, d.dept_name
FROM students s
INNER JOIN departments d ON s.dept_id = d.dept_id;

-- 2. LEFT JOIN to keep unassigned students (Kabir appears with dept_name = NULL)
SELECT s.name, d.dept_name
FROM students s
LEFT JOIN departments d ON s.dept_id = d.dept_id;

-- 3. Anti-Join Pattern: Find students who have NO department assigned
SELECT s.name
FROM students s
LEFT JOIN departments d ON s.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- 4. Multi-Table Join (Chaining 3 tables)
SELECT s.name, d.dept_name, c.course_title
FROM students s
JOIN departments d ON s.dept_id = d.dept_id
JOIN courses c ON d.dept_id = c.dept_id;
```

> **Exam Note on `FULL OUTER JOIN`:** MySQL does **not** have a `FULL OUTER JOIN` keyword. To get all rows from both sides, combine a `LEFT JOIN` and a `RIGHT JOIN` using `UNION`.
>
> **Classic `LEFT JOIN` Trap:** Filtering a Right-table column inside `WHERE` (e.g., `LEFT JOIN departments d ON ... WHERE d.dept_name = 'Computer Science'`) drops all unmatched rows because `NULL = 'Computer Science'` is false—turning your `LEFT JOIN` into an `INNER JOIN`! Put Right-table matching conditions in the `ON` clause instead.

---

## 4. Pillar III: Aggregations, Grouping & Subqueries

### Aggregate Functions (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`)

Aggregate functions compress many rows into a **single summary number**.

| Function | What It Calculates | How It Treats `NULL` Values |
| :--- | :--- | :--- |
| **`COUNT(*)`** | Total count of rows | **Counts `NULL` rows too** |
| **`COUNT(col)`** | Count of non-empty values in `col` | **Ignores `NULL`s** |
| **`COUNT(DISTINCT col)`** | Count of unique non-empty values | **Ignores `NULL`s** and duplicates |
| **`SUM(col)`** | Total sum of numeric values | **Ignores `NULL`s** (returns `NULL` if all rows are `NULL`) |
| **`AVG(col)`** | Arithmetic mean ($\text{SUM} \div \text{COUNT(col)}$) | **Ignores `NULL`s in BOTH sum and row count!** |
| **`MIN(col)` / `MAX(col)`** | Smallest / Largest value | **Ignores `NULL`s** |

#### The `AVG` + `NULL` Calculation Trap
Imagine 4 students have marks: `100`, `80`, `60`, and `NULL`:
* `COUNT(*)` = **`4`**
* `COUNT(marks)` = **`3`**
* `SUM(marks)` = **`240`**
* `AVG(marks)` = $240 \div 3 =$ **`80.00`** *(NOT $240 \div 4 = 60$! `NULL` is excluded from the denominator.)*

### Grouping & Filtering Buckets (`GROUP BY` & `HAVING`)

* **`GROUP BY`** gathers rows sharing the same column value into buckets so aggregates run once per bucket.
* **`HAVING`** filters those buckets *after* aggregates are computed.

#### The Strict `GROUP BY` Rule
Every column in `SELECT` that is **not** inside an aggregate function (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) **must** be listed in `GROUP BY`. Otherwise, MySQL throws `ERROR 1055` (`ONLY_FULL_GROUP_BY`).

#### `WHERE` vs. `HAVING` Side-by-Side

| Dimension | `WHERE` | `HAVING` |
| :--- | :--- | :--- |
| **Execution Timing** | **Before** `GROUP BY` (Step 2) | **After** `GROUP BY` (Step 4) |
| **What It Filters** | Individual raw rows | Grouped summary buckets |
| **Aggregate Functions Allowed?** | **No** (`WHERE COUNT(*) > 1` is an error) | **Yes** (`HAVING COUNT(*) > 1` is valid) |
| **Best Practice** | Filter raw rows in `WHERE` first to reduce workload | Use `HAVING` only for conditions on aggregates |

```sql
-- Complete Analytical Pipeline:
-- 1. Consider only students aged 20+ (WHERE)
-- 2. Group them by city (GROUP BY)
-- 3. Keep only cities with more than 1 student (HAVING)
-- 4. Sort largest cities first (ORDER BY)
SELECT city,
       COUNT(*) AS total_students,
       ROUND(AVG(age), 1) AS average_age
FROM students
WHERE age >= 20
GROUP BY city
HAVING COUNT(*) > 1
ORDER BY total_students DESC;
```

### Subqueries & Nested Queries

A **subquery** is a `SELECT` query wrapped inside parentheses `( ... )` nested within an outer query. The inner query solves an intermediate question and feeds its answer to the outer query.

#### The 5 Subquery Patterns

1. **Scalar Subquery (Returns 1 single value: 1 row $\times$ 1 column)**
   Used with standard comparison operators (`=`, `<`, `>`, `<=`, `>=`).
   ```sql
   -- Find students older than the overall class average
   SELECT name, age
   FROM students
   WHERE age > (SELECT AVG(age) FROM students);
   ```

2. **Multi-Row Subquery (Returns a list of values: N rows $\times$ 1 column)**
   Used with `IN`, `NOT IN`, `ANY`, or `ALL`:
   * `> ANY (...)` $\rightarrow$ Greater than the **minimum** value in the list.
   * `> ALL (...)` $\rightarrow$ Greater than the **maximum** value in the list.
   ```sql
   -- Find students belonging to departments named 'Computer Science' or 'Data Science'
   SELECT name
   FROM students
   WHERE dept_id IN (
       SELECT dept_id
       FROM departments
       WHERE dept_name IN ('Computer Science', 'Data Science')
   );
   ```

3. **Correlated Subquery (Inner query depends on the outer query)**
   The inner query references a column from the outer table and re-runs once per candidate row.
   ```sql
   -- Find students older than the average age of THEIR OWN department
   SELECT s1.name, s1.dept_id, s1.age
   FROM students s1
   WHERE s1.age > (
       SELECT AVG(s2.age)
       FROM students s2
       WHERE s2.dept_id = s1.dept_id
   );
   ```

4. **Existence Check (`EXISTS` / `NOT EXISTS`)**
   Returns `TRUE` as soon as the inner query finds at least one matching row (fast and immune to `NULL` traps).
   ```sql
   -- Find departments that have at least one enrolled student
   SELECT d.dept_name
   FROM departments d
   WHERE EXISTS (
       SELECT 1 FROM students s WHERE s.dept_id = d.dept_id
   );
   ```

5. **Derived Table (Subquery inside `FROM`)**
   Treats a query result as a temporary virtual table. **MySQL requires an alias (`AS ...`) on every derived table.**
   ```sql
   -- Find the highest department average age
   SELECT MAX(dept_avg) AS highest_avg_age
   FROM (
       SELECT dept_id, AVG(age) AS dept_avg
       FROM students
       WHERE dept_id IS NOT NULL
       GROUP BY dept_id
   ) AS dept_averages;
   ```

---

## 5. Common MySQL Errors & Trap-Avoidance Checklist

| Error Message / Scenario | Root Cause & Exact Fix |
| :--- | :--- |
| **`No database selected`** | You haven't entered a database yet. Run `USE database_name;`. |
| **`Unknown column '...' in 'where clause'`** | Typo in column name, or trying to use a `SELECT` alias inside `WHERE`. |
| **`Duplicate entry '...' for key 'PRIMARY'`** | Violated a `PRIMARY KEY` or `UNIQUE` constraint with an existing value. |
| **`Cannot add or update a child row`** | Foreign key error: the parent ID doesn't exist yet. Insert into parent table first. |
| **`Cannot delete or update a parent row`** | Foreign key error: child rows still reference this parent. Delete children first or use `ON DELETE CASCADE`. |
| **`Column '...' cannot be null`** | Omitted a value for a `NOT NULL` column that has no `DEFAULT`. |
| **`You have an error in your SQL syntax`** | Missing comma/semicolon, mismatched quotes, or an unquoted reserved word (wrap in `` `backticks` ``). |
| **`Access denied for user '...'@'...'`** | Wrong password, wrong host (`localhost` vs `%`), or missing `GRANT` privileges. |

### 10 Golden Rules for Exam Accuracy
1. **Execution Order:** `FROM` $\rightarrow$ `JOIN` $\rightarrow$ `WHERE` $\rightarrow$ `GROUP BY` $\rightarrow$ `HAVING` $\rightarrow$ `SELECT` $\rightarrow$ `DISTINCT` $\rightarrow$ `ORDER BY` $\rightarrow$ `LIMIT`.
2. **MySQL Schema Synonym:** `CREATE SCHEMA` and `CREATE DATABASE` are identical in MySQL.
3. **Unselected Database:** `SELECT DATABASE();` returns `NULL` (not `''`) before `USE` is executed.
4. **Quotes:** Backticks (`` ` ``) wrap column/table names; single quotes (`'`) wrap text/date values.
5. **Undo Rules:** `CREATE`, `ALTER`, `DROP`, and `TRUNCATE` (DDL) auto-commit and **cannot** be rolled back; `DELETE` (DML) **can** be rolled back inside a transaction.
6. **`NULL` Logic:** Always use `IS NULL` / `IS NOT NULL` (or `<=>`)—never `= NULL` or `<> NULL`.
7. **`NULL` in Aggregates:** `COUNT(*)` counts `NULL`s; `COUNT(col)`, `SUM(col)`, `AVG(col)`, `MIN(col)`, and `MAX(col)` all ignore `NULL`s.
8. **`WHERE` vs. `HAVING`:** `WHERE` filters rows before grouping (no aggregates); `HAVING` filters groups after grouping (aggregates allowed).
9. **`GROUP BY` Rule:** Every non-aggregated column in `SELECT` must also appear in `GROUP BY`.
10. **Derived Tables:** Every subquery in a `FROM` clause **must** be given an alias.