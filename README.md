# dbt Fundamentals with PostgreSQL
This guide describes how to follow [dbt Fundamentals](https://learn.getdbt.com/courses/dbt-fundamentals) using a local dbt Core install and a local PostgreSQL database. The original course requires you to register for trial accounts for dbt and a data platform (Snowflake, BigQuery or Databricks). If you're like me and don't want accounts for everything, follow this guide side-by-side the official dbt Fundamentals course.

The steps below **do not** represent a complete copy of the course. Only the steps where you should do something _different_ than the official course are written.

## Chapter 01. Welcome to dbt Fundamentals
No changes for this chapter. Just follow the course.

## Chapter 02. Analytics Development Lifecycle
No changes for this chapter. Just follow the course.

## Chapter 03. Set Up dbt
In the chapter you are asked to register for a dbt trial account (to use dbt Studio online) and to register for a data platform. We are **not** going to do that. Instead, we install dbt Core using Python and use Docker to run a PostgreSQL container on localhost. You can watch the course videos for info but you don't have to perform any of the steps. Instead, perform the steps listed below.

### Install dbt in a Python virtual environment
The commands shown in the guide assume you are using either bash on Linux or [Git Bash](https://gitforwindows.org/) on Windows and you have [Python](https://www.python.org/) installed.
1. Create a new folder named `dbt-fundamentals-postgresql` somewhere on your hard drive: `mkdir dbt-fundamentals-postgresql`. This is going to be our project folder.
1. Create a [Python virtual environment](https://docs.python.org/3/library/venv.html): `python -m venv venv`
1. Activate that virtual environment
    * Linux: `source venv/bin/activate`
    * Windows (Git Bash): `source venv/Scripts/activate`
1. Test with `which pip` that pip points to the executable in your venv folder
1. Install dbt-core and dbt-postgres: `pip install dbt-core dbt-postgres`
1. Test with `dbt --version` that dbt-core and the dbt-postgres plugin is installed correctly

### Initialize the dbt project folder
1. Make sure you are in your `dbt-fundamentals-postgresql` project folder and your venv is activated
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
Docker get be installed in multiple ways. Below is, what I think, the easiest way. Refer to [the documentation](https://docs.docker.com/get-started/) for more info.
1. On Linux, install `docker.io` from your package manager. E.g. on Debian/Ubuntu use `sudo apt install docker.io`.
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

Now we can test our dbt configuration:
1. Change directory into our dbt project folder: `cd jaffle_shop`
    * All `dbt` commands should be run in the `jaffle_shop` folder
1. Run `dbt debug`
1. This should give a green message saying All checks passed!

### Load the raw data into PostgreSQL
There are 3 csv files we need to load into our database:
* raw_customers.csv
* raw_orders.csv
* raw_payments.csv

You could do that using a database tool like DBeaver or write your own CREATE and INSERT statements to load the csv files. Or you could take advantage of the seed functionality of dbt:
1. Download the 3 csv files from the [this dbt Labs git repository](https://github.com/dbt-labs/jaffle_shop_duckdb) (folder seeds)
1. Save them in your project folder `dbt-fundamentals-postgresql/jaffle_shop/seeds`
1. Remove the `raw_` prefix of each filename
1. Open **dbt_project.yml** in your favorite editor and put the following code at the bottom of the file:
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

If all went well you should be greeted by a green message saying Completed successfully. Pay special attention that the schema.table names of each seed matches these:
* dbt_user_raw_jaffle_shop.customers
* dbt_user_raw_jaffle_shop.orders
* dbt_user_raw_stripe.payments

Seeds are not covered in the dbt Fundamentals course, but you can read about them in the [documentation](https://docs.getdbt.com/docs/build/seeds).
 
_Note:_ dbt Fundamentals puts these 3 raw data tables in a separate database called `raw`. But PostgreSQL doesn't work out-of-the-box with cross-database references. To make it easier for ourselves, we will only use 1 database called `analytics` and distinguish between raw data and transformed data using the schema name.

## Chapter 04. Models
Most of the videos in this chapter you can just follow along. For the videos which are listed below, you need to make some exceptions.

### Changes for video: Build Your First Model
In the **customers.sql** file replace the database.schema name `raw.jaffle_shop` with `analytics.dbt_user_raw_jaffle_shop` on line 8 and line 20.

_Note:_ In the course they use dbt Studio. But you can use any code editor or database tool. There are plenty of options here. I'm using DBeaver, but VS Code  (with PostgreSQL extention) is also a good choice.

_Note:_ In the course they show the option to Preview CTE and to show the lineage. This is a capability of the dbt Fusion Engine. We installed dbt Core, so unfortunately we don't have these options.

### Changes for Practice and Exemplar
Also here, replace the database.schema name `raw.jaffle_shop` with `analytics.dbt_user_raw_jaffle_shop`. And do the same for Stripe.

## Chapter 05. Sources
### Changes for video: Configure Sources
When adding **_src_jaffle_shop.yml**, fill in the database `analytics` and the schema `dbt_user_raw_jaffle_shop`.

### Changes for video: References Sources in Staging Models
In the video they show the SQL code which is compiled by dbt and send to the database server. You can use `dbt compile --select stg_jaffle_shop__customers`. Check that database, schema and table in the compiled SQL code is `"analytics"."dbt_user_raw_jaffle_shop"."customers"`.

### Changes for video: Source Freshness
To check for source freshness we need an extra column in the raw orders and raw payments tables. In the dbt Fundamentals course these columns are created while setting up the trial accounts for Snowflake, BigQuery or Databricks. We will do that manually now.

1. Open your database tool, such as DBeaver
1. Connect to your local PostgreSQL database (using the same credentials you used when you ran `dbt init`) if you haven't done that already
1. Execute the following 2 SQL statements:
    ```
    ALTER TABLE dbt_user_raw_jaffle_shop.orders ADD COLUMN _etl_loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    ALTER TABLE dbt_user_raw_stripe.payments ADD COLUMN _batched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    ```

It's also possible to execute the SQL statements by running the `psql` command directly inside the Docker container: `docker exec -it postgres-db psql -U user -d analytics`. You should see an `analytics=#` prompt. Execute the SQL statements one by one. And then exit with `exit`.

You can follow the steps in the video now.

## Chapter 06. Data Tests
No changes for this chapter. Just follow the course.

_Note:_ Throughout the dbt Fundamentals course, you see git commits are made once in a while. This is optional. Git is not covered in this guide.

## Chapter 07. Documentation
No changes for this chapter. Just follow the course.

_Tip:_ You can [preview Markdown](https://code.visualstudio.com/Docs/languages/markdown#_markdown-preview) in VS Code.

_Extra:_ Generate the documentation with `dbt docs generate`. And serve it with `dbt docs serve`.
