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
- ✅ Supports manual triggers via "Run workflow" button
- ✅ Each build includes commit SHA for easy identification

**Triggers:**
- Push to `main` or `master` branch
- Pull requests to `main` or `master`
- Manual trigger (workflow_dispatch)

### 2. Release Workflow (`.github/workflows/release.yml`)

Manually triggered workflow to create official releases (stable or pre-release).

**Features:**
- ✅ Create stable or pre-release versions
- ✅ Choose which commit to release
- ✅ Custom version tags and release names
- ✅ Add custom release notes
- ✅ Automatically updates "Latest Stable Release" tag
- ✅ Only releases builds you've tested and approved

**Triggers:**
- Manual trigger only (you control when to release)

## How to Use

### Automatic Builds (For Testing)
Simply push your changes to the main branch:
```bash
git add .
git commit -m "Your changes here"
git push
```

The workflow will automatically:
1. Build the module ZIP
2. Upload it as an artifact with commit SHA
3. **No automatic release** - you decide what to release

### Accessing Test Builds
1. Go to **Actions** tab
2. Click on the workflow run
3. Scroll down to **"Artifacts"** section
4. Click on the artifact to download
5. Test on your device

### Creating an Official Release (When Ready)
Once you've tested a build and found it good for publishing:

1. Go to **Actions** tab
2. Click on **"Release Ashizw Module"** workflow
3. Click **"Run workflow"**
4. Fill in the form:
   - **Commit SHA**: Leave empty for latest, or paste specific commit hash
   - **Version tag**: e.g., `v1.4`
   - **Release name**: e.g., `Ashizw v1.4 Stable`
   - **Is stable**: Check for stable release, uncheck for beta/pre-release
   - **Release notes**: Describe what's new
5. Click **"Run workflow"**
6. The release will be created automatically in the Releases section!

## Benefits vs Manual Process

| Manual Process | With GitHub Actions |
|---------------|---------------------|
| Edit files in VS Code | Edit files in VS Code |
| Manually zip with 7-zip | ✅ Auto-zip on push |
| Test on phone | Test on phone |
| Manually upload to GitHub | ✅ Auto-upload artifacts |
| Repeat for every change | ✅ Just push and let CI handle it |
| No build history | ✅ All builds saved in Actions |
| Manual release process | ✅ One-click releases with custom notes |

## Version Management

The workflow automatically reads the version from `module.prop`:
```properties
version=1.4
versionCode=5
```

Update these values before pushing to create a new versioned build.

## Typical Workflow

1. **Development**: Make changes in VS Code
2. **Push**: Commit and push to GitHub
3. **Auto-build**: GitHub Actions builds automatically
4. **Test**: Download artifact from Actions and test on device
5. **Iterate**: If issues found, fix and repeat steps 1-4
6. **Release**: When satisfied, use Release workflow to publish
7. **Done**: Release appears in Releases section for users!

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
