# SQL Who Did What
A SQL Script that shows who deleted / updated the records in the SQL Database.

It is often a problem in the production environment when multiple SQL Users connects to same database and a number of rows either updated or deleted and there is no easy way to figure out who did what so that application using that SQL User can be fixed.

In order to find out, please do as follows:

'''
- Copy the script in SQL Server Management Studio
- In the second line of script, add table name. (comments also points out which line it is)
- Make sure that SQL Query Window is pointing to right database
- Execute.
---

Notes:
This script is absolutely harmless and does NOT create/update/delete/alter any table/row/trigger/login/function/Stored Procedure etc.
