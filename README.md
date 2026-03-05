|              |                                                     |
| ------------ | --------------------------------------------------- |
| Copyright    | © 2026 VEXIT , Tomorrow is today... , www.vexit.com |
| Author       | Vex Tatarevic                                       |
| Date Created | 2026-03-04                                          |
| Date Updated |                                                     |

# Vexit.Scripts


Vexit.Scripts contains helpful Bash scripts:

- `create-dotnet-unittests-project.sh` - Automated test project creation with all dependencies and a dummy test

You can clone Vexit.Scripts repository to your workspace and use these utilities.

Example usage:

```bash
# Create a test project for any project by passing a path to project directory
./Vexit.Scripts/create-dotnet-unittests-project.sh Vexit.Logging/src

# Or run it interactively
./Vexit.Scripts/create-dotnet-unittests-project.sh

# Print help
./Vexit.Scripts/create-dotnet-unittests-project.sh --help
```
