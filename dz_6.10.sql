CREATE TABLE #Words (
    Word NVARCHAR(255),
    Count INT
)

DECLARE @Message NVARCHAR(MAX)
DECLARE @Word NVARCHAR(255)

DECLARE messageCursor CURSOR FOR
SELECT mess
FROM dbo.messages

OPEN messageCursor

DECLARE @WordCount INT
SET @WordCount = 0

CREATE TABLE #WordsInMessage (
    Word NVARCHAR(255)
)

FETCH NEXT FROM messageCursor INTO @Message
WHILE @@FETCH_STATUS = 0
BEGIN
    DELETE FROM #WordsInMessage
    INSERT INTO #WordsInMessage (Word)
    SELECT value
    FROM STRING_SPLIT(@Message, ' ')
    DECLARE wordCursor CURSOR FOR
    SELECT Word
    FROM #WordsInMessage
    OPEN wordCursor
    FETCH NEXT FROM wordCursor INTO @Word
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @WordCount = @WordCount + 1
        IF EXISTS (SELECT * FROM #Words WHERE Word = @Word)
        BEGIN
            UPDATE #Words
            SET Count = Count + 1
            WHERE Word = @Word
        END
        ELSE
        BEGIN
            INSERT INTO #Words (Word, Count)
            VALUES (@Word, 1)
        END
        FETCH NEXT FROM wordCursor INTO @Word
    END

    CLOSE wordCursor
    DEALLOCATE wordCursor
    FETCH NEXT FROM messageCursor INTO @Message
END

CLOSE messageCursor
DEALLOCATE messageCursor
SELECT TOP 10 Word, Count
FROM #Words
ORDER BY Count DESC

DROP TABLE #Words
DROP TABLE #WordsInMessage