#!/bin/bash

#-------------------------------------------------------------
# Copyright:	© 2026 VEXIT ®, www.vexit.com
# Author:      	Vex Tatarevic
# Date Created: 2025-11-12
# Date Updated:	2026-03-04 | Vex | Added interactive prompt for project path and standard help arguments and usage message
#
#-------------------------------------------------------------

# Script to create a .NET test project for a given project with all dependencies and a dummy test
# Usage: ./create-dotnet-unittests-project.sh [options]
#
# OPTIONS:
#   -h, --help          Show this help message and exit
#
# EXAMPLES:
#   ./create-dotnet-unittests-project.sh
#   ./create-dotnet-unittests-project.sh --help
#   ./create-dotnet-unittests-project.sh -h

set -e  # Exit on error

# Function to display usage information
show_help() {
    cat << EOF
VEXIT .NET Test Project Creator

Create a complete .NET test project with all necessary dependencies, project references,
and a dummy test file.

USAGE:
    $0 [OPTIONS] [PROJECT_PATH]

OPTIONS:
    -h, --help          Show this help message and exit

ARGUMENTS:
    PROJECT_PATH        Path to the .NET project directory (optional)
                       If not provided, you will be prompted interactively

DESCRIPTION:
    This script creates a complete .NET test project with all necessary dependencies,
    project references, and a dummy test file. If no project path is provided,
    it will prompt you interactively.

FEATURES:
    - xUnit testing framework with Visual Studio runner
    - Moq for mocking and FluentAssertions for readable assertions
    - Automatic project reference to the source project
    - Dummy test file to verify setup
    - Full build and test execution

EXAMPLES:
    $0                  # Run interactively
    $0 MyProject        # Direct path to project
    $0 ../MyProject     # Relative path
    $0 /c/dev/MyProject # Absolute path
    $0 --help           # Show this help

EOF
}

# Parse command line arguments
PROJECT_PATH=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Error: Unknown option '$1'"
            echo "Use '$0 --help' for usage information."
            exit 1
            ;;
        *)
            # If it's not an option, treat it as the project path
            if [ -z "$PROJECT_PATH" ]; then
                PROJECT_PATH="$1"
            else
                echo "Error: Multiple project paths provided. Only one path is allowed."
                echo "Use '$0 --help' for usage information."
                exit 1
            fi
            ;;
    esac
    shift
done

# If no project path provided via arguments, prompt interactively
if [ -z "$PROJECT_PATH" ]; then
    echo ""
    echo "VEXIT .NET Test Project Creator"
    echo "================================"
    echo ""
    read -p "Enter the path to your .NET project: " PROJECT_PATH
    echo ""

    # Validate interactive input
    if [ -z "$PROJECT_PATH" ]; then
        echo "Error: No project path provided. Please provide a valid path to your .NET project."
        echo "Use '$0 --help' for usage information."
        exit 1
    fi
fi

# Get absolute path of the project directory
if [ -d "$PROJECT_PATH" ]; then
    ABSOLUTE_PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
else
    echo "Error: Project directory not found: $PROJECT_PATH"
    exit 1
fi

# Find .csproj file in the project directory
echo "Looking for .NET C# project file in: $ABSOLUTE_PROJECT_PATH/"
CSPROJ_FILE=$(find "$ABSOLUTE_PROJECT_PATH" -maxdepth 1 -name "*.csproj" | head -1)

if [ -z "$CSPROJ_FILE" ]; then
    echo "Error: No .NET C# project file (.csproj) found in directory: $ABSOLUTE_PROJECT_PATH/"
    echo "Please ensure you're pointing to a directory containing a .NET C# project file."
    exit 1
fi

echo "Found .NET C# project file: $CSPROJ_FILE"

# Extract project name from .csproj filename (without extension)
PROJECT_NAME="$(basename "$CSPROJ_FILE" .csproj)"
TEST_PROJECT_NAME="${PROJECT_NAME}.Tests"

# Get the directory containing the project (parent directory)
PROJECT_PARENT_DIR="$(dirname "$ABSOLUTE_PROJECT_PATH")"

# Navigate to parent directory
cd "$PROJECT_PARENT_DIR"

echo "Creating ${TEST_PROJECT_NAME} project..."
echo "Source project: $ABSOLUTE_PROJECT_PATH"
echo "Test project will be created in: $(pwd)/${TEST_PROJECT_NAME}"

# Create test project
dotnet new classlib --name "$TEST_PROJECT_NAME"

# Navigate into test project
cd "$TEST_PROJECT_NAME"

# Generate .gitignore file
echo "Generating .gitignore file..."
dotnet new gitignore

# Add all required packages
echo "Adding NuGet packages..."
dotnet add package Microsoft.NET.Test.Sdk
dotnet add package xunit
dotnet add package xunit.runner.visualstudio
dotnet add package Moq
dotnet add package FluentAssertions

echo ""
echo "Adding project reference to ${PROJECT_NAME}..."

# Add project reference using absolute path to the source project file
dotnet add reference "$CSPROJ_FILE"

# Remove default class file
echo ""
echo "Removing default Class1.cs..."
rm -f Class1.cs

# Create dummy test file
echo ""
echo "Creating dummy test file..."
cat > DummyTest.cs << EOF
using Xunit;

namespace ${TEST_PROJECT_NAME};

public class DummyTest
{
    [Fact]
    public void Should_Pass()
    {
        // Arrange
        var expected = true;

        // Act
        var actual = true;

        // Assert
        Assert.Equal(expected, actual);
    }
}
EOF

# Clean, restore, and build
echo ""
echo "Cleaning and building..."
dotnet clean
dotnet restore
dotnet build

# Run tests with detailed output to show individual test names
echo ""
echo "Running tests..."
dotnet test --logger "console;verbosity=normal"

# Display success message
echo ""
echo "✅ Test project created successfully!"
echo "Test project location: $(pwd)"
echo "Source project: $ABSOLUTE_PROJECT_PATH"

