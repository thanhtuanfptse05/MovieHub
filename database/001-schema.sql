-- MovieHub schema v1, SQL Server. Run against MovieHub (never master).
-- Additive bootstrap for a new database or the existing Users-only baseline.
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;

IF DB_NAME()<>N'MovieHub' THROW 51100, 'Run this schema only against MovieHub.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Users (
            id bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
            full_name nvarchar(100) NOT NULL,
            email varchar(255) NOT NULL,
            password_hash varchar(255) NOT NULL,
            role varchar(10) NOT NULL CONSTRAINT DF_Users_Role DEFAULT 'USER',
            status varchar(10) NOT NULL CONSTRAINT DF_Users_Status DEFAULT 'ACTIVE',
            avatar_url varchar(500) NULL,
            created_at datetime2(7) NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(),
            updated_at datetime2(7) NOT NULL CONSTRAINT DF_Users_UpdatedAt DEFAULT SYSUTCDATETIME(),
            version int NOT NULL CONSTRAINT DF_Users_Version DEFAULT 1,
            credentials_version int NOT NULL CONSTRAINT DF_Users_CredentialsVersion DEFAULT 1
        );
    END;

    -- Refuse incompatible legacy tables rather than rebuilding or guessing conversions.
    IF EXISTS (
        SELECT 1 FROM (VALUES
            (N'id',N'bigint',8),(N'full_name',N'nvarchar',200),
            (N'email',N'varchar',255),(N'password_hash',N'varchar',255),
            (N'role',N'varchar',10),(N'status',N'varchar',10),
            (N'created_at',N'datetime2',8),(N'updated_at',N'datetime2',8),
            (N'version',N'int',4),(N'credentials_version',N'int',4)
        ) expected(name,type_name,max_length)
        LEFT JOIN sys.columns c ON c.object_id=OBJECT_ID(N'dbo.Users') AND c.name=expected.name
        WHERE c.column_id IS NULL OR TYPE_NAME(c.user_type_id)<>expected.type_name
            OR c.max_length<>expected.max_length OR c.is_nullable=1
    ) OR COLUMNPROPERTY(OBJECT_ID(N'dbo.Users'),N'id','IsIdentity')<>1
        THROW 51101, 'Existing Users schema is incompatible; no data was changed.', 1;
    IF COL_LENGTH(N'dbo.Users',N'avatar_url') IS NULL
        THROW 51102, 'Existing Users is missing avatar_url; no data was changed.', 1;

    IF COL_LENGTH(N'dbo.Users',N'email_key') IS NULL
        ALTER TABLE dbo.Users ADD email_key AS
            (LOWER(LTRIM(RTRIM(email))) COLLATE Latin1_General_100_CI_AS_SC) PERSISTED;
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Users') AND name=N'UX_Users_EmailKey')
        CREATE UNIQUE INDEX UX_Users_EmailKey ON dbo.Users(email_key);
    IF OBJECT_ID(N'dbo.CK_Users_Role',N'C') IS NULL
        ALTER TABLE dbo.Users WITH CHECK ADD CONSTRAINT CK_Users_Role
            CHECK (role COLLATE Latin1_General_100_BIN2 IN ('USER','ADMIN'));
    IF OBJECT_ID(N'dbo.CK_Users_Status',N'C') IS NULL
        ALTER TABLE dbo.Users WITH CHECK ADD CONSTRAINT CK_Users_Status
            CHECK (status COLLATE Latin1_General_100_BIN2 IN ('ACTIVE','INACTIVE'));
    IF OBJECT_ID(N'dbo.CK_Users_Content',N'C') IS NULL
        ALTER TABLE dbo.Users WITH CHECK ADD CONSTRAINT CK_Users_Content
            CHECK (LEN(LTRIM(RTRIM(full_name)))>=1 AND LEN(LTRIM(RTRIM(email)))>=3 AND LEN(password_hash)>=1);
    IF OBJECT_ID(N'dbo.CK_Users_Versions',N'C') IS NULL
        ALTER TABLE dbo.Users WITH CHECK ADD CONSTRAINT CK_Users_Versions
            CHECK (version>=0 AND credentials_version>=1);
    IF OBJECT_ID(N'dbo.CK_Users_EnumPadding',N'C') IS NULL
        ALTER TABLE dbo.Users WITH CHECK ADD CONSTRAINT CK_Users_EnumPadding
            CHECK (DATALENGTH(role)=LEN(role) AND DATALENGTH(status)=LEN(status));

    IF OBJECT_ID(N'dbo.Movies',N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Movies (
            id bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_Movies PRIMARY KEY,
            title nvarchar(200) NOT NULL,
            slug varchar(250) COLLATE Latin1_General_100_BIN2 NOT NULL,
            description nvarchar(max) NOT NULL,
            release_year smallint NOT NULL,
            duration_minutes smallint NOT NULL,
            poster_url varchar(1000) NULL,
            video_url varchar(1000) NULL,
            trailer_url varchar(1000) NULL,
            status varchar(10) COLLATE Latin1_General_100_BIN2 NOT NULL CONSTRAINT DF_Movies_Status DEFAULT 'DRAFT',
            featured bit NOT NULL CONSTRAINT DF_Movies_Featured DEFAULT 0,
            view_count bigint NOT NULL CONSTRAINT DF_Movies_ViewCount DEFAULT 0,
            created_at datetime2(7) NOT NULL CONSTRAINT DF_Movies_CreatedAt DEFAULT SYSUTCDATETIME(),
            updated_at datetime2(7) NOT NULL CONSTRAINT DF_Movies_UpdatedAt DEFAULT SYSUTCDATETIME(),
            version int NOT NULL CONSTRAINT DF_Movies_Version DEFAULT 1,
            CONSTRAINT UQ_Movies_Slug UNIQUE(slug),
            CONSTRAINT CK_Movies_Title CHECK (LEN(LTRIM(RTRIM(title)))>=1),
            CONSTRAINT CK_Movies_Description CHECK (LEN(LTRIM(RTRIM(description))) BETWEEN 1 AND 10000),
            CONSTRAINT CK_Movies_Year CHECK (release_year BETWEEN 1888 AND 9999),
            CONSTRAINT CK_Movies_Duration CHECK (duration_minutes BETWEEN 1 AND 600),
            CONSTRAINT CK_Movies_Status CHECK (status IN ('DRAFT','PUBLISHED','HIDDEN')),
            CONSTRAINT CK_Movies_ViewCount CHECK (view_count>=0),
            CONSTRAINT CK_Movies_Version CHECK (version>=0),
            CONSTRAINT CK_Movies_Slug CHECK (LEN(slug)>0 AND DATALENGTH(slug)=LEN(slug)
                AND slug NOT LIKE '%[^a-z0-9-]%' AND slug NOT LIKE '-%'
                AND slug NOT LIKE '%-' AND slug NOT LIKE '%--%')
        );
    END;

    IF OBJECT_ID(N'dbo.Categories',N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Categories (
            id bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_Categories PRIMARY KEY,
            name nvarchar(100) NOT NULL,
            -- Service supplies NFC(name).trim().toLowerCase(Locale.ROOT).
            -- Binary comparison avoids linguistic expansion (e.g. sharp-s = ss).
            name_key nvarchar(300) COLLATE Latin1_General_100_BIN2 NOT NULL,
            slug varchar(120) COLLATE Latin1_General_100_BIN2 NOT NULL,
            created_at datetime2(7) NOT NULL CONSTRAINT DF_Categories_CreatedAt DEFAULT SYSUTCDATETIME(),
            deleted_at datetime2(7) NULL,
            version int NOT NULL CONSTRAINT DF_Categories_Version DEFAULT 1,
            CONSTRAINT UQ_Categories_NameKey UNIQUE(name_key),
            CONSTRAINT UQ_Categories_Slug UNIQUE(slug),
            CONSTRAINT CK_Categories_Name CHECK (LEN(LTRIM(RTRIM(name)))>=1),
            CONSTRAINT CK_Categories_NameKey CHECK (DATALENGTH(name_key)>0
                AND DATALENGTH(name_key)=DATALENGTH(LTRIM(RTRIM(name_key)))),
            CONSTRAINT CK_Categories_Version CHECK (version>=0),
            CONSTRAINT CK_Categories_Slug CHECK (LEN(slug)>0 AND DATALENGTH(slug)=LEN(slug)
                AND slug NOT LIKE '%[^a-z0-9-]%' AND slug NOT LIKE '-%'
                AND slug NOT LIKE '%-' AND slug NOT LIKE '%--%')
        );
    END;

    IF OBJECT_ID(N'dbo.MovieCategories',N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.MovieCategories (
            movie_id bigint NOT NULL,
            category_id bigint NOT NULL,
            CONSTRAINT PK_MovieCategories PRIMARY KEY(movie_id,category_id),
            CONSTRAINT FK_MovieCategories_Movie FOREIGN KEY(movie_id) REFERENCES dbo.Movies(id),
            CONSTRAINT FK_MovieCategories_Category FOREIGN KEY(category_id) REFERENCES dbo.Categories(id)
        );
    END;

    IF OBJECT_ID(N'dbo.Favorites',N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Favorites (
            id bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_Favorites PRIMARY KEY,
            user_id bigint NOT NULL,
            movie_id bigint NOT NULL,
            created_at datetime2(7) NOT NULL CONSTRAINT DF_Favorites_CreatedAt DEFAULT SYSUTCDATETIME(),
            deleted_at datetime2(7) NULL,
            CONSTRAINT UQ_Favorites_UserMovie UNIQUE(user_id,movie_id),
            CONSTRAINT FK_Favorites_User FOREIGN KEY(user_id) REFERENCES dbo.Users(id),
            CONSTRAINT FK_Favorites_Movie FOREIGN KEY(movie_id) REFERENCES dbo.Movies(id)
        );
    END;

    IF OBJECT_ID(N'dbo.Reviews',N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Reviews (
            id bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_Reviews PRIMARY KEY,
            user_id bigint NOT NULL,
            movie_id bigint NOT NULL,
            rating tinyint NOT NULL,
            content nvarchar(1000) NOT NULL,
            status varchar(10) COLLATE Latin1_General_100_BIN2 NOT NULL CONSTRAINT DF_Reviews_Status DEFAULT 'PENDING',
            moderated_by bigint NULL,
            moderated_at datetime2(7) NULL,
            created_at datetime2(7) NOT NULL CONSTRAINT DF_Reviews_CreatedAt DEFAULT SYSUTCDATETIME(),
            updated_at datetime2(7) NOT NULL CONSTRAINT DF_Reviews_UpdatedAt DEFAULT SYSUTCDATETIME(),
            deleted_at datetime2(7) NULL,
            version int NOT NULL CONSTRAINT DF_Reviews_Version DEFAULT 1,
            content_revision int NOT NULL CONSTRAINT DF_Reviews_ContentRevision DEFAULT 1,
            CONSTRAINT UQ_Reviews_UserMovie UNIQUE(user_id,movie_id),
            CONSTRAINT FK_Reviews_User FOREIGN KEY(user_id) REFERENCES dbo.Users(id),
            CONSTRAINT FK_Reviews_Movie FOREIGN KEY(movie_id) REFERENCES dbo.Movies(id),
            CONSTRAINT FK_Reviews_Moderator FOREIGN KEY(moderated_by) REFERENCES dbo.Users(id),
            CONSTRAINT CK_Reviews_Rating CHECK (rating BETWEEN 1 AND 5),
            CONSTRAINT CK_Reviews_Content CHECK (LEN(LTRIM(RTRIM(content)))>=1),
            CONSTRAINT CK_Reviews_Status CHECK (status IN ('PENDING','APPROVED','REJECTED')),
            CONSTRAINT CK_Reviews_Versions CHECK (version>=0 AND content_revision>=1),
            CONSTRAINT CK_Reviews_Audit CHECK (
                (status='PENDING' AND moderated_by IS NULL AND moderated_at IS NULL)
                OR (status IN ('APPROVED','REJECTED') AND moderated_by IS NOT NULL AND moderated_at IS NOT NULL))
        );
    END;

    IF OBJECT_ID(N'dbo.Questions',N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Questions (
            id bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_Questions PRIMARY KEY,
            movie_id bigint NOT NULL,
            user_id bigint NOT NULL,
            content nvarchar(500) NOT NULL,
            status varchar(10) COLLATE Latin1_General_100_BIN2 NOT NULL CONSTRAINT DF_Questions_Status DEFAULT 'PENDING',
            moderated_by bigint NULL,
            moderated_at datetime2(7) NULL,
            created_at datetime2(7) NOT NULL CONSTRAINT DF_Questions_CreatedAt DEFAULT SYSUTCDATETIME(),
            version int NOT NULL CONSTRAINT DF_Questions_Version DEFAULT 1,
            CONSTRAINT FK_Questions_Movie FOREIGN KEY(movie_id) REFERENCES dbo.Movies(id),
            CONSTRAINT FK_Questions_User FOREIGN KEY(user_id) REFERENCES dbo.Users(id),
            CONSTRAINT FK_Questions_Moderator FOREIGN KEY(moderated_by) REFERENCES dbo.Users(id),
            CONSTRAINT CK_Questions_Content CHECK (LEN(LTRIM(RTRIM(content))) BETWEEN 10 AND 500),
            CONSTRAINT CK_Questions_Status CHECK (status IN ('PENDING','APPROVED','REJECTED')),
            CONSTRAINT CK_Questions_Version CHECK (version>=0),
            CONSTRAINT CK_Questions_Audit CHECK (
                (status='PENDING' AND moderated_by IS NULL AND moderated_at IS NULL)
                OR (status IN ('APPROVED','REJECTED') AND moderated_by IS NOT NULL AND moderated_at IS NOT NULL))
        );
    END;

    IF OBJECT_ID(N'dbo.Answers',N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Answers (
            id bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_Answers PRIMARY KEY,
            question_id bigint NOT NULL,
            user_id bigint NOT NULL,
            content nvarchar(1000) NOT NULL,
            status varchar(10) COLLATE Latin1_General_100_BIN2 NOT NULL CONSTRAINT DF_Answers_Status DEFAULT 'PENDING',
            moderated_by bigint NULL,
            moderated_at datetime2(7) NULL,
            created_at datetime2(7) NOT NULL CONSTRAINT DF_Answers_CreatedAt DEFAULT SYSUTCDATETIME(),
            version int NOT NULL CONSTRAINT DF_Answers_Version DEFAULT 1,
            CONSTRAINT FK_Answers_Question FOREIGN KEY(question_id) REFERENCES dbo.Questions(id),
            CONSTRAINT FK_Answers_User FOREIGN KEY(user_id) REFERENCES dbo.Users(id),
            CONSTRAINT FK_Answers_Moderator FOREIGN KEY(moderated_by) REFERENCES dbo.Users(id),
            CONSTRAINT CK_Answers_Content CHECK (LEN(LTRIM(RTRIM(content)))>=1),
            CONSTRAINT CK_Answers_Status CHECK (status IN ('PENDING','APPROVED','REJECTED')),
            CONSTRAINT CK_Answers_Version CHECK (version>=0),
            CONSTRAINT CK_Answers_Audit CHECK (
                (status='PENDING' AND moderated_by IS NULL AND moderated_at IS NULL)
                OR (status IN ('APPROVED','REJECTED') AND moderated_by IS NOT NULL AND moderated_at IS NOT NULL))
        );
    END;

    -- SQL equality pads strings even under BIN2; reject padded enum values explicitly.
    IF OBJECT_ID(N'dbo.CK_Movies_EnumPadding',N'C') IS NULL
        ALTER TABLE dbo.Movies WITH CHECK ADD CONSTRAINT CK_Movies_EnumPadding CHECK (DATALENGTH(status)=LEN(status));
    IF OBJECT_ID(N'dbo.CK_Reviews_EnumPadding',N'C') IS NULL
        ALTER TABLE dbo.Reviews WITH CHECK ADD CONSTRAINT CK_Reviews_EnumPadding CHECK (DATALENGTH(status)=LEN(status));
    IF OBJECT_ID(N'dbo.CK_Questions_EnumPadding',N'C') IS NULL
        ALTER TABLE dbo.Questions WITH CHECK ADD CONSTRAINT CK_Questions_EnumPadding CHECK (DATALENGTH(status)=LEN(status));
    IF OBJECT_ID(N'dbo.CK_Answers_EnumPadding',N'C') IS NULL
        ALTER TABLE dbo.Answers WITH CHECK ADD CONSTRAINT CK_Answers_EnumPadding CHECK (DATALENGTH(status)=LEN(status));

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Movies') AND name=N'IX_Movies_Catalog')
        CREATE INDEX IX_Movies_Catalog ON dbo.Movies(status,updated_at DESC,id DESC)
            INCLUDE(title,slug,release_year,duration_minutes,poster_url,view_count,featured);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Movies') AND name=N'IX_Movies_Views')
        CREATE INDEX IX_Movies_Views ON dbo.Movies(status,view_count DESC,id DESC) INCLUDE(title,slug,poster_url);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.MovieCategories') AND name=N'IX_MovieCategories_Category')
        CREATE INDEX IX_MovieCategories_Category ON dbo.MovieCategories(category_id,movie_id);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Favorites') AND name=N'IX_Favorites_Active')
        CREATE INDEX IX_Favorites_Active ON dbo.Favorites(user_id,created_at DESC,id DESC)
            INCLUDE(movie_id) WHERE deleted_at IS NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Reviews') AND name=N'IX_Reviews_Movie')
        CREATE INDEX IX_Reviews_Movie ON dbo.Reviews(movie_id,status,created_at DESC,id DESC)
            INCLUDE(rating,user_id) WHERE deleted_at IS NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Reviews') AND name=N'IX_Reviews_Moderation')
        CREATE INDEX IX_Reviews_Moderation ON dbo.Reviews(status,created_at,id)
            INCLUDE(movie_id,user_id,version,content_revision) WHERE deleted_at IS NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Questions') AND name=N'IX_Questions_Movie')
        CREATE INDEX IX_Questions_Movie ON dbo.Questions(movie_id,status,created_at DESC,id DESC);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Questions') AND name=N'IX_Questions_Moderation')
        CREATE INDEX IX_Questions_Moderation ON dbo.Questions(status,created_at,id);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Answers') AND name=N'IX_Answers_Question')
        CREATE INDEX IX_Answers_Question ON dbo.Answers(question_id,status,created_at DESC,id DESC);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Answers') AND name=N'IX_Answers_Moderation')
        CREATE INDEX IX_Answers_Moderation ON dbo.Answers(status,created_at,id);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT t.name AS table_name, SUM(p.rows) AS row_count
FROM sys.tables t JOIN sys.partitions p ON p.object_id=t.object_id AND p.index_id IN (0,1)
WHERE t.schema_id=SCHEMA_ID(N'dbo')
    AND t.name IN (N'Users',N'Movies',N'Categories',N'MovieCategories',N'Favorites',N'Reviews',N'Questions',N'Answers')
GROUP BY t.name ORDER BY t.name;
