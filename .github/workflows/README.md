# GitHub Actions for Ashizw

This repository now includes automated GitHub Actions workflows to build and release the Ashizw module automatically.

## Available Workflows

### 1. Build Workflow (`.github/workflows/build.yml`)

Automatically builds the Ashizw module ZIP file when you push changes to the main/master branch.

**Features:**
- ✅ Automatically extracts version from `module.prop`
- ✅ Creates a properly structured Magisk/KernelSU module
- ✅ Generates a ZIP file ready for flashing
- ✅ Uploads build artifacts (available for 30 days)
- ✅ Creates automatic releases on main branch pushes
- ✅ Supports manual triggers via "Run workflow" button

**Triggers:**
- Push to `main` or `master` branch
- Pull requests to `main` or `master`
- Manual trigger (workflow_dispatch)

## How to Use

### Automatic Builds
Simply push your changes to the main branch:
```bash
git add .
git commit -m "Your changes here"
git push
```

The workflow will automatically:
1. Build the module ZIP
2. Upload it as an artifact
3. Create a pre-release on GitHub

### Manual Build
1. Go to the **Actions** tab in your GitHub repository
2. Click on **"Build Ashizw Module"** workflow
3. Click **"Run workflow"**
4. Select the branch and click **"Run workflow"**
5. Wait for the build to complete
6. Download the ZIP from the artifacts section or release page

### Accessing Built Files

**For commits/PRs (not main branch):**
1. Go to **Actions** tab
2. Click on the workflow run
3. Scroll down to **"Artifacts"** section
4. Click on the artifact to download

**For main branch pushes:**
1. Go to **Releases** section on the right sidebar
2. Find the latest pre-release
3. Download the ZIP file

## Benefits vs Manual Process

| Manual Process | With GitHub Actions |
|---------------|---------------------|
| Edit files in VS Code | Edit files in VS Code |
| Manually zip with 7-zip | ✅ Auto-zip on push |
| Test on phone | Test on phone |
| Manually upload to GitHub | ✅ Auto-upload & create release |
| Repeat for every change | ✅ Just push and let CI handle it |

## Version Management

The workflow automatically reads the version from `module.prop`:
```properties
version=1.4
versionCode=5
```

Update these values before pushing to create a new versioned release.

## Testing Changes Before Release

You can test changes without creating a release:
1. Create a feature branch: `git checkout -b test-feature`
2. Make your changes and push
3. The workflow will build but won't create a release
4. Download the artifact from Actions tab
5. Test on your device
6. If good, merge to main for official release

## Troubleshooting

If the workflow fails:
1. Check the **Actions** tab for error details
2. Ensure all required files exist (action.sh, service.sh, etc.)
3. Verify `module.prop` has correct format
4. Check that you have no syntax errors in shell scripts

## Secrets Required

No additional secrets needed! The workflow uses the default `GITHUB_TOKEN` which is automatically available.

---

**Now you can focus on coding while GitHub Actions handles the building and releasing!** 🚀
