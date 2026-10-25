-- Run against master. Existing databases and instance login settings are untouched.
IF DB_ID(N'MovieHub') IS NULL
    CREATE DATABASE [MovieHub] COLLATE Latin1_General_100_CI_AS_SC;
GO
