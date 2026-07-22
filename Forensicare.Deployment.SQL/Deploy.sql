-- ============================================================
-- Forensicare SQL Deployment Script
-- Run this file in SQLCMD mode or via sqlcmd.exe:
--
--   sqlcmd -S <ServerInstance> -d HCMDW -i Deploy.sql
--
-- Execution order:
--   1. Tables
--   2. Functions
--   3. Stored Procedures
-- ============================================================

:setvar RootPath "C:\DEV\repo\Forensicare.DataSyncTool.SQL"

USE [HCMDW];
GO


SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

PRINT '========================================';
PRINT ' Forensicare SQL Deployment';
PRINT ' Started: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO

-- ------------------------------------------------------------
-- 1. Tables
-- ------------------------------------------------------------
PRINT '';
PRINT '--- Tables ---';
GO

:r $(RootPath)\Tables\dbo.BulkUploadData.sql
GO
:r $(RootPath)\Tables\dbo.DataSynchEmployees.sql
GO
:r $(RootPath)\Tables\dbo.DataSynchPositions.sql
GO
:r $(RootPath)\Tables\dbo.DayforceEmployeeProcessing.sql
GO
:r $(RootPath)\Tables\dbo.DayforceEmployeeContact.sql
GO
:r $(RootPath)\Tables\dbo.NextOfKin.sql
GO
:r $(RootPath)\Tables\dbo.Superannuation.sql
GO
:r $(RootPath)\Tables\dbo.DirectDeposits.sql
GO
:r $(RootPath)\Tables\dbo.DataSynchBusinessUnits.sql
GO


-- ------------------------------------------------------------
-- 2. Functions
-- ------------------------------------------------------------
PRINT '';
PRINT '--- Functions ---';
GO

:r $(RootPath)\Functions\dbo.fn_GetActiveEmployeesByWAPCode.sql
GO
:r $(RootPath)\Functions\dbo.fn_GetPayClassDescription.sql
GO
:r $(RootPath)\Functions\dbo.fn_GetStateDescription.sql
GO
:r $(RootPath)\Functions\dbo.fn_GetPayGlobalCountryDescription.sql
GO
:r $(RootPath)\Functions\dbo.fn_GetBirthCountryDescription.sql
GO
:r $(RootPath)\Functions\dbo.fn_FormatMobileNumber.sql
GO
:r $(RootPath)\Functions\dbo.fn_NullSafeUpper.sql
GO
:r $(RootPath)\Functions\dbo.fn_IsAboriginalFlagsEquivalent.sql
GO
:r $(RootPath)\Functions\dbo.fn_IsGenderEquivalent.sql
GO

-- ------------------------------------------------------------
-- 3. Stored Procedures
-- ------------------------------------------------------------
PRINT '';
PRINT '--- Stored Procedures ---';
GO

:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetDayforcePositions.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetDayforcePositionsByEmployeeRefCode.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetOrphanedDayforcePositions.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetPayGlobalWAPS.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_ImportDayforceEmployees_json.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_ImportDayforcePositions_json.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spGetEmployeesForBulkUpdate_IT.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_CompleteBulkItem_IT.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetContactsDiffsToProcess_IT.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetDataForBulkUpdate_IT.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetEmployeeDetails.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_InsertBulkUploadData_IT.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spDayforce_Employee_InsertUpdate_IT.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spDayforce_EmployeeContact_InsertUpdate_IT.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetContactsDiffs_IT.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetOrphanedDayforceEmployees.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_ImportDayforcePositions.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_ImportDayforceEmployees.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetEmployeeDifferences_Chunk1.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spNextOfKin_InsertUpdate.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSuperannuation_InsertUpdate.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spDirectDeposit_InsertUpdate.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetEmployeeDifferences_DirectDeposits.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetEmployeeNextOfKinDifferences_V2.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetEmployeeSuperannuationDifferences.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetOrphanedPayGlobalEmployees.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetEmployeeTerminationDateDifferences.sql
GO
:r $(RootPath)\StoredProcedures\dbo.spSyncData_GetOrphanedPyGlobalWAPS.sql
GO

-- ------------------------------------------------------------
PRINT '';
PRINT '========================================';
PRINT ' Deployment complete: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO
