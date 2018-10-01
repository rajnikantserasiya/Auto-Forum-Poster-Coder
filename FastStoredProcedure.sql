
ALTER PROCEDURE [dbo].[ListLanguages]
(
	@SearchValue NVARCHAR(50) = NULL,
	@PageNo INT = 1,
	@PageSize INT = 10,
	@SortColumn NVARCHAR(20) = 'Name',
	@SortOrder NVARCHAR(20) = 'ASC'
)
 AS BEGIN
 SET NOCOUNT ON;

 SET @SearchValue = LTRIM(RTRIM(@SearchValue))

 ; WITH CTE_Results AS 
(
    SELECT LanguageId, Name, Code from Language 
	WHERE (@SearchValue IS NULL OR Name LIKE '%' + @SearchValue + '%') 
	    ORDER BY
   	 CASE WHEN (@SortColumn = 'Name' AND @SortOrder='ASC')
                    THEN Name
        END ASC,
        CASE WHEN (@SortColumn = 'Name' AND @SortOrder='DESC')
                   THEN Name
		END DESC,
	 CASE WHEN (@SortColumn = 'Code' AND @SortOrder='ASC')
                    THEN Code
        END ASC,
        CASE WHEN (@SortColumn = 'Code' AND @SortOrder='DESC')
                   THEN Code
		END DESC
      OFFSET @PageSize * (@PageNo - 1) ROWS
      FETCH NEXT @PageSize ROWS ONLY
	),
CTE_TotalRows AS 
(
 select count(LanguageID) as MaxRows from Language WHERE (@SearchValue IS NULL OR Name LIKE '%' + @SearchValue + '%')
)
   Select MaxRows, t.LanguageId, t.Name, t.Code from dbo.Language as t, CTE_TotalRows 
   WHERE EXISTS (SELECT 1 FROM CTE_Results WHERE CTE_Results.LanguageID = t.LanguageID)
   OPTION (RECOMPILE)

	END

GO