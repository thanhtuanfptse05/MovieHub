-- Integration assertions use real SQL Server constraints; fixtures always roll back.
SET NOCOUNT ON;
SET XACT_ABORT OFF;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;

IF (SELECT COUNT(*) FROM sys.tables WHERE schema_id = SCHEMA_ID(N'dbo')
    AND name IN (N'Users',N'Movies',N'Categories',N'MovieCategories',N'Favorites',N'Reviews',N'Questions',N'Answers')) <> 8
    THROW 51000, 'Expected all eight MovieHub business tables.', 1;
GO
SET NOCOUNT ON;
SET XACT_ABORT OFF;
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @suffix varchar(32) = LOWER(REPLACE(CONVERT(varchar(36), NEWID()), '-', ''));
    DECLARE @email varchar(255) = @suffix + '@schema-test.invalid';
    DECLARE @user bigint, @movie bigint, @category bigint, @question bigint;
    DECLARE @caught bit;

    -- Hash-shaped fixture only; never used as a login or committed.
    INSERT dbo.Users(full_name,email,password_hash,created_at,updated_at)
    VALUES (N'Kiểm thử dữ liệu',@email,'$2a$12$.....................................................',SYSUTCDATETIME(),SYSUTCDATETIME());
    SET @user = SCOPE_IDENTITY();

    INSERT dbo.Movies(title,slug,description,release_year,duration_minutes)
    VALUES (N'Phim kiểm thử',@suffix,N'Nội dung kiểm thử',2026,90);
    SET @movie = SCOPE_IDENTITY();
    INSERT dbo.Categories(name,name_key,slug) VALUES (N'Thể loại ' + @suffix,N'thể loại ' + @suffix,@suffix);
    SET @category = SCOPE_IDENTITY();
    INSERT dbo.MovieCategories(movie_id,category_id) VALUES (@movie,@category);
    INSERT dbo.Favorites(user_id,movie_id) VALUES (@user,@movie);
    INSERT dbo.Reviews(user_id,movie_id,rating,content) VALUES (@user,@movie,5,N'Đánh giá kiểm thử');
    INSERT dbo.Questions(user_id,movie_id,content) VALUES (@user,@movie,N'Câu hỏi kiểm thử hợp lệ?');
    SET @question = SCOPE_IDENTITY();
    INSERT dbo.Answers(user_id,question_id,content) VALUES (@user,@question,N'Câu trả lời kiểm thử');

    IF NOT EXISTS (SELECT 1 FROM dbo.Movies WHERE id=@movie AND title=N'Phim kiểm thử'
        AND status='DRAFT' AND view_count=0 AND featured=0 AND version=1)
        THROW 51001, 'Unicode or movie defaults failed.', 1;

    SET @caught=0;
    BEGIN TRY
        INSERT dbo.Users(full_name,email,password_hash)
        VALUES (N'Duplicate', ' ' + UPPER(@email) + ' ', 'fixture-only');
    END TRY BEGIN CATCH
        IF ERROR_NUMBER() NOT IN (2601,2627) THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51002, 'Canonical email duplicate was accepted.', 1;

    SET @caught=0;
    BEGIN TRY
        INSERT dbo.Categories(name,name_key,slug)
        VALUES (N'  THỂ LOẠI ' + UPPER(@suffix) + N'  ',N'thể loại ' + @suffix,@suffix + '-duplicate');
    END TRY BEGIN CATCH
        IF ERROR_NUMBER() NOT IN (2601,2627) THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51003, 'Canonical category duplicate was accepted.', 1;
    INSERT dbo.Categories(name,name_key,slug) VALUES (N'The loai ' + @suffix,N'the loai ' + @suffix,@suffix + '-accent');
    -- Distinct canonical strings must stay distinct despite linguistic expansion.
    INSERT dbo.Categories(name,name_key,slug) VALUES (N'Straße ' + @suffix,N'straße ' + @suffix,@suffix + '-sharp-s');
    INSERT dbo.Categories(name,name_key,slug) VALUES (N'Strasse ' + @suffix,N'strasse ' + @suffix,@suffix + '-double-s');
    -- Locale.ROOT lowercasing of U+0130 expands to i + U+0307, distinct from i.
    INSERT dbo.Categories(name,name_key,slug) VALUES (N'İ ' + @suffix,N'i' + NCHAR(775) + N' ' + @suffix,@suffix + '-dotted-i');
    INSERT dbo.Categories(name,name_key,slug) VALUES (N'I ' + @suffix,N'i ' + @suffix,@suffix + '-plain-i');

    SET @caught=0;
    BEGIN TRY
        UPDATE dbo.Users SET role='ADMIN ' WHERE id=@user;
    END TRY BEGIN CATCH
        IF ERROR_NUMBER()<>547 THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51014, 'Space-padded role was accepted.', 1;

    SET @caught=0;
    BEGIN TRY
        UPDATE dbo.Movies SET status='DRAFT ' WHERE id=@movie;
    END TRY BEGIN CATCH
        IF ERROR_NUMBER()<>547 THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51015, 'Space-padded status was accepted.', 1;

    UPDATE dbo.Favorites SET deleted_at=SYSUTCDATETIME() WHERE user_id=@user AND movie_id=@movie;
    SET @caught=0;
    BEGIN TRY
        INSERT dbo.Favorites(user_id,movie_id) VALUES (@user,@movie);
    END TRY BEGIN CATCH
        IF ERROR_NUMBER() NOT IN (2601,2627) THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51004, 'Soft-deleted favorite allowed a duplicate.', 1;

    UPDATE dbo.Reviews SET deleted_at=SYSUTCDATETIME() WHERE user_id=@user AND movie_id=@movie;
    SET @caught=0;
    BEGIN TRY
        INSERT dbo.Reviews(user_id,movie_id,rating,content) VALUES (@user,@movie,4,N'Duplicate');
    END TRY BEGIN CATCH
        IF ERROR_NUMBER() NOT IN (2601,2627) THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51005, 'Soft-deleted review allowed a duplicate.', 1;

    SET @caught=0;
    BEGIN TRY
        UPDATE dbo.Reviews SET rating=6 WHERE user_id=@user AND movie_id=@movie;
    END TRY BEGIN CATCH
        IF ERROR_NUMBER()<>547 THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51006, 'Out-of-range rating was accepted.', 1;

    SET @caught=0;
    BEGIN TRY
        UPDATE dbo.Movies SET status='UNKNOWN' WHERE id=@movie;
    END TRY BEGIN CATCH
        IF ERROR_NUMBER()<>547 THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51007, 'Unknown movie status was accepted.', 1;

    SET @caught=0;
    BEGIN TRY
        UPDATE dbo.Movies SET view_count=-1 WHERE id=@movie;
    END TRY BEGIN CATCH
        IF ERROR_NUMBER()<>547 THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51008, 'Negative view count was accepted.', 1;

    SET @caught=0;
    BEGIN TRY
        UPDATE dbo.Answers SET status='APPROVED' WHERE question_id=@question;
    END TRY BEGIN CATCH
        IF ERROR_NUMBER()<>547 THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51009, 'Moderation without audit was accepted.', 1;
    UPDATE dbo.Answers SET status='APPROVED',moderated_by=@user,moderated_at=SYSUTCDATETIME()
    WHERE question_id=@question;

    SET @caught=0;
    BEGIN TRY
        INSERT dbo.Answers(user_id,question_id,content) VALUES (@user,-1,N'Orphan');
    END TRY BEGIN CATCH
        IF ERROR_NUMBER()<>547 THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51010, 'Orphan answer was accepted.', 1;

    SET @caught=0;
    BEGIN TRY
        DELETE dbo.Movies WHERE id=@movie;
    END TRY BEGIN CATCH
        IF ERROR_NUMBER()<>547 THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51011, 'Parent deletion cascaded or was accepted.', 1;

    SET @caught=0;
    BEGIN TRY
        UPDATE dbo.Movies SET slug='INVALID-SLUG' WHERE id=@movie;
    END TRY BEGIN CATCH
        IF ERROR_NUMBER()<>547 THROW;
        SET @caught=1;
    END CATCH;
    IF @caught=0 THROW 51012, 'Uppercase slug was accepted.', 1;

    UPDATE dbo.Movies SET view_count=3000000000 WHERE id=@movie;
    IF NOT EXISTS (SELECT 1 FROM dbo.Movies WHERE id=@movie AND view_count=CAST(3000000000 AS bigint))
        THROW 51013, 'BIGINT view count failed.', 1;

    ROLLBACK TRANSACTION;
    SELECT 'PASS: schema constraints verified; all fixtures rolled back' AS result;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
