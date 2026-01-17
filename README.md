# dbt Fundamentals with PostgreSQL
This guide describes how to follow [dbt Fundamentals](https://learn.getdbt.com/courses/dbt-fundamentals) using a local dbt Core install and a local PostgreSQL database. The original course requires you to register for trial accounts for dbt and a data platform (such as Snowflake or Databricks). If you prefer to follow the course on your machine locally, and learn about the fundaments of dbt and PostgreSQL along the way, follow this guide.

The steps below *do not* represent a complete copy of the course. Only the steps where you should do something different than the official course are written.

## Register for the course
1. Go to [dbt Fundamentals](https://learn.getdbt.com/courses/dbt-fundamentals) to register and start the course.

## Chapter 01. Welcome to dbt Fundamentals
No changes for this chapter. Just follow the course.

## Chapter 02. Analytics Development Lifecycle
No changes for this chapter. Just follow the course.

## Chapter 03. Set Up dbt
In the chapter you are asked to register for a dbt trial account (to use dbt Studio online) and to register for a data platform (Snowflake, BigQuery or Databricks). We are *not* going to do that. Instead, we install dbt Core using Python and use Docker to run a PostgreSQL server on localhost. You can watch all the videos but you don't have to perform any of the steps. Instead, perform the steps listed below.

### Install dbt in a Python virtual environment
The commands shown in the guide assume you are using either bash on Linux or [Git Bash](https://gitforwindows.org/) on Windows.
1. Create a new folder named `dbt-fundamentals` somewhere on your hard drive: `mkdir dbt-fundamentals`. This is going to be our project folder.
1. Create a [Python virtual environment](https://docs.python.org/3/library/venv.html): `python -m venv venv`
1. Activate that virtual environment
    * Linux: `source venv/bin/activate`
    * Windows: `source venv/Scripts/activate`
1. Test with `which pip` that pip points to the executable in your venv folder
1. Install dbt-core and dbt-postgres: `pip install dbt-core dbt-postgres`
1. Test with `dbt --version` that dbt-core and the postgres plugin is installed

### Initialize the dbt project folder
1. Make sure you are in your `dbt-fundamentals` project folder and your venv is activated
1. Run `dbt init`
1. Enter a name of your project: `jaffle_shop`
1. Which database would you like to use? Enter the number corresponding to postgres: (`1` by default)
1. host: `localhost`
1. port: `5432`
1. user: `user`
1. pass: `pass`
    * Note you won't see your typed characters while typing
1. dbname: `analytics`
1. schema: `dbt_user`
1. threads: `1`

dbt now proposes to validate the connection with `dbt debug`. This will not yet work because PostgreSQL is not yet running.

### Set up PostgreSQL with Docker
1. On Linux the easiest way to get started is to install `docker.io` from your package manager. E.g. on Debian/Ubuntu use `sudo apt install docker.io`.
1. On Windows, we have to install Docker Desktop. And we'll do that using WSL.
    * [Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install) by opening a PowerShell as Administration and then run `wsl --install`
    * Download and install [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
    * During the installation make sure to use WSL 2 instead of Hyper-V
1. Test if Docker is installed correctly using `docker --version`
1. Create and start a new PostgreSQL container with the following command:
```
docker run --name postgres-db
  -p 5432:5432
  -e POSTGRES_DB=analytics
  -e POSTGRES_USER=user
  -e POSTGRES_PASSWORD=pass
  -d postgres
```

_Note:_ To stop and start the container use `docker stop postgres-db` and `docker start postgres-db`.

Now we can test our dbt configuration
1. Change directory into the dbt folder: `cd jaffle_shop`
1. Run `dbt debug`
1. This should give a green message saying All checks passed!

### Load the raw data into PostgreSQL
There are 3 tables we need to load into our database:
* raw_customers.csv
* raw_orders.csv
* raw_payments.csv

You could do that using a database tool like DBeaver or write your own CREATE and INSERT statements to load the csv files. Or you could take advantage of the seed functionality of dbt:
1. Download the 3 csv files from the [jaffle_shop_duckdb git repository](https://github.com/dbt-labs/jaffle_shop_duckdb)
1. Save them in `jaffle_shop\seeds`
1. Remove the `raw_` prefix of each filename
1. Now open dbt_project.yml in your favorite editor and put the following code at the bottom of the file:
```
# Configuring seeds
seeds:
  jaffle_shop:
    customers:
      +schema: raw_jaffle_shop
    orders:
      +schema: raw_jaffle_shop
    payments:
      +schema: raw_stripe
```
1. Run `dbt seed`

If all went well you should be greeted by a green message saying Completed successfully. Pay special attention to the names of the schema and table of each seed:
* dbt_user_raw_jaffle_shop.customers
* dbt_user_raw_jaffle_shop.orders
* dbt_user_raw_stripe.payments

The name of each table equals the filename (without .csv). The schema name is defined in the code we just copied into dbt_project.yml. Our dev schema (dbt_user) is prefixed to our custom seed schema. You will learn more about seeds in the dbt Fundamentals course.
 
_Note:_ dbt Fundamentals puts the raw data in a separate database called `raw`. But PostgreSQL doesn't work out-of-the-box with cross-database references. To make it easier for ourselves, we will only use 1 database called `analytics`. We'll distinguish between raw data using the schema name.

## Chapter 04. Models
The videos that need some changes are listed below. The rest of the videos you can follow along.

### Changes for video: Build Your First Model
In the customers.sql file which you will copy and paste, you will see that the code refers to the raw data using the `raw` database. We need to change that to the schema name we gave them during the `dbt seed` command.

* On line 8, replace `raw.jaffle_shop.customers` with `dbt_user_raw_jaffle_shop.customers`
* On line 20, replace `raw.jaffle_shop.order` with `dbt_user_raw_jaffle_shop.order`

_Tip:_ In the course video they use dbt Studio. But you can use any code editor or database tool. There are plenty of options here. I'm using DBeaver, but VS Code is also a good choice.

_Note:_ In the course video they show the option to Preview CTE and to show the lineage. This is a capability of the dbt Fusion Engine. We installed dbt Core, so unfortunately we don't have these options.

### Changes for Practice and Exemplar
To do the practice exercise and to follow the example answer, you need to replace the database notation `raw.` with the correct schema (`dbt_user_raw_jaffle_shop` or `dbt_user_raw_stripe`).

## Chapter 05. Sources
### Changes for video: Configure Sources
When adding `_src_jaffle_shop.yml` fill in the database `analytics` and the schema `dbt_user_raw_jaffle_shop`.

### Changes for video: References Sources in Staging Models
You don't need to change any code here. dbt looks up what how to reference the source. 

In the video they show the SQL code which is compiled by dbt and send to the database server. You can use `dbt compile --select stg_jaffle_shop__customers`. Check that database, schema and table in the compiled SQL code is `"analytics"."dbt_user_raw_jaffle_shop"."customers"`.

### Changes for video: Source Freshness
<TODO> Ik ben hier gebleven!
ALTER TABLE dbt_user_raw_jaffle_shop.orders ADD COLUMN _etl_loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE dbt_user_raw_jaffle_shop.payments ADD COLUMN _batched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
