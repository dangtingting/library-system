@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@
@REM    https://www.apache.org/licenses/LICENSE-2.0
@
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM Maven Start Up Batch script
@
@REM Required ENV vars:
@REM   JAVA_HOME - location of a JDK home dir
@
@REM Optional ENV vars
@REM   M2_HOME - location of maven2's installed home dir
@REM   MAVEN_BATCH_ECHO - set to 'on' to enable the echoing of the batch commands
@REM   MAVEN_BATCH_PAUSE - set to 'on' to wait for a keystroke before ending
@REM   MAVEN_OPTS - parameters passed to the Java VM when running Maven
@REM     e.g. to debug Maven itself, use
@REM       set MAVEN_OPTS=-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000
@REM   MAVEN_SKIP_RC - flag to disable loading of mavenrc files
@REM ----------------------------------------------------------------------------

@REM Begin all REM lines with '@' in case MAVEN_BATCH_ECHO is 'on'
@echo off
@REM set title of command window
title %0
@REM enable echoing by setting MAVEN_BATCH_ECHO to 'on'
@if "%MAVEN_BATCH_ECHO%" == "on"  echo %MAVEN_BATCH_ECHO%

@REM set %HOME% to equivalent of $HOME
if "%HOME%" == "" (set "HOME=%HOMEDRIVE%%HOMEPATH%")

@REM Execute a user defined script before this one
if not "%MAVEN_SKIP_RC%" == "" goto skipRcPre
@REM check for pre script, once with legacy .bat ending and once with .cmd ending
if exist "%HOME%\mavenrc_pre.bat" call "%HOME%\mavenrc_pre.bat"
if exist "%HOME%\mavenrc_pre.cmd" call "%HOME%\mavenrc_pre.cmd"
:skipRcPre

@setlocal

set ERROR_CODE=0

@REM To isolate internal variables from possible post scripts, we use another setlocal
@setlocal

@REM ==== START VALIDATION ====
if not "%JAVA_HOME%" == "" goto OkJHome

@REM Try to find JAVA_HOME from the registry
set JAVA_HOME=
for /f "tokens=3" %%g in ('reg query "HKLM\\Software\\JavaSoft\\Java Development Kit" /v CurrentVersion 2^>nul') do (
    @REM Test if the registry value is valid
    for /f "tokens=2" %%d in ('reg query "HKLM\\Software\\JavaSoft\\Java Development Kit\\%%g" /v JavaHome 2^>nul') do (
        set JAVA_HOME=%%d
    )
)

if not exist "%JAVA_HOME%\bin\java.exe" (
    echo Error: JAVA_HOME is not set correctly. 1>&2
    echo We cannot execute %JAVA_HOME%\bin\java.exe. 1>&2
    set ERROR_CODE=1
    goto error
)

:OkJHome
if exist "%JAVA_HOME%\bin\java.exe" goto init

echo Error: JAVA_HOME is set to an invalid directory. 1>&2
echo JAVA_HOME = "%JAVA_HOME%" 1>&2
echo Please set the JAVA_HOME variable in your environment to match the 1>&2
echo location of your Java installation. 1>&2
set ERROR_CODE=1
goto error

@REM ==== END VALIDATION ====

:init

@REM Find the project base dir, i.e. the directory that contains the folder ".mvn".
@REM Fallback to current working directory if not found.

set MAVEN_PROJECTBASEDIR=%MAVEN_BASEDIR%
if "%MAVEN_PROJECTBASEDIR%"=="" (
  for %%d in ("%MAVEN_HOME%" "%~dp0..") do (
    if exist "%%d\.mvn\" set MAVEN_PROJECTBASEDIR=%%d
  )
)

if "%MAVEN_PROJECTBASEDIR%"=="" set MAVEN_PROJECTBASEDIR=%~dp0..

@REM Uncomment the following line if you want the project directory to be printed
@REM echo The project base directory is %MAVEN_PROJECTBASEDIR%

@REM Implementation of maven-wrapper is in .mvn/wrapper/maven-wrapper.properties

set MAVEN_CMD_LINE_ARGS=%*

@REM For backwards compatibility, we use the old method of directly executing the
@REM MAVEN_HOME/bin/mvn.cmd.  If the user wants to use the new maven-wrapper, they
@REM should set the environment variable MAVEN_USE_MAVENWRAPPER=true

if "%MAVEN_USE_MAVENWRAPPER%"=="true" goto usemavenwrapper

@REM If the project base directory is not found, we use the maven-wrapper
if not exist "%MAVEN_PROJECTBASEDIR%\.mvn\" goto usemavenwrapper

@REM Otherwise, we use MAVEN_HOME and execute directly
set MAVEN_HOME=%MAVEN_HOME:~0,-1%
if not exist "%MAVEN_HOME%\bin\mvn.cmd" goto usemavenwrapper

@REM Execute directly
set WRAPPER_JAR=""
set WRAPPER_LAUNCHER=org.apache.maven.cli.MavenCli
%MAVEN_HOME%\bin\mvn.cmd %MAVEN_CMD_LINE_ARGS%
goto end

:usemavenwrapper
@REM If the project base directory is not found, we cannot continue
if not exist "%MAVEN_PROJECTBASEDIR%\" (
  echo The project directory was not found: %MAVEN_PROJECTBASEDIR% 1>&2
  set ERROR_CODE=1
  goto error
)

@REM Implementation of maven-wrapper is in .mvn/wrapper/maven-wrapper.properties

@REM For using the maven-wrapper we need to find the .mvn directory in the project
@REM base directory and execute the Maven Wrapper from there.

@REM If the project base directory is not found, we cannot continue
if not exist "%MAVEN_PROJECTBASEDIR%\.mvn\" (
  echo The project directory was not found: %MAVEN_PROJECTBASEDIR%\.mvn\ 1>&2
  set ERROR_CODE=1
  goto error
)

@REM If the project base directory is not found, we cannot continue
if not exist "%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.jar" (
  echo Maven wrapper jar file not found: %MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.jar 1>&2
  set ERROR_CODE=1
  goto error
)

@REM Execute Maven Wrapper from the project base directory
cd "%MAVEN_PROJECTBASEDIR%"
set WRAPPER_JAR="%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.jar"
set WRAPPER_LAUNCHER=org.apache.maven.wrapper.MavenWrapperMain

@REM If the project base directory is not found, we cannot continue
if not exist "%MAVEN_PROJECTBASEDIR%\" (
  echo The project directory was not found: %MAVEN_PROJECTBASEDIR% 1>&2
  set ERROR_CODE=1
  goto error
)

@REM Execute Maven Wrapper from the project base directory
cd "%MAVEN_PROJECTBASEDIR%"
"%JAVA_HOME%\bin\java.exe" %MAVEN_OPTS% -classpath %WRAPPER_JAR% "-Dmaven.multiModuleProjectDirectory=%MAVEN_PROJECTBASEDIR%" %WRAPPER_LAUNCHER% %MAVEN_CMD_LINE_ARGS%

if ERRORLEVEL 1 goto error
goto end

:error
if "%MAVEN_BATCH_PAUSE%" == "on" pause

@endlocal
@REM set the ERROR_CODE to 1 to indicate an error
set ERROR_CODE=1

@endlocal & goto #_undefined_