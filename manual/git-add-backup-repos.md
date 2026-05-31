|              |                                                     |
| ------------ | --------------------------------------------------- |
| Copyright    | © 2026 VEXIT , Tomorrow is today... , www.vexit.com |
| Author       | Vex Tatarevic                                       |
| Date Created | 2026-03-26                                          |
| Date Updated |                                                     |


## 1. Clone or Create Local Repos

**1.1 CLONE REMOTE - Multiple repos** - clone multiple repos from one server:

```bash
mkdir -p /path/to/local/repos
cd /path/to/local/repos
for r in my-repo1 my-repo2 my-repo3; do git clone my-origin-server:/home/repos/$r "$r"; done
```

OR

**1.2 CREATE, INIT, PUSH LOCAL - Multiple folders** - Create and init bare repos on server and then init git in existing local folders and push them to the server:

```bash
# 1) Create matching bare repos on the server
ssh my-origin-server 'for r in my-repo1 my-repo2 my-repo3; do mkdir -p "/home/repos/$r" && git init --bare "/home/repos/$r"; done'

# 2) Init local folders and push first commit
for r in my-repo1 my-repo2 my-repo3; do (
  cd "/path/to/local/repos/$r" || exit 1
  git init
  git branch -M main
  git remote add origin "my-origin-server:/home/repos/$r"
  git add -A
  git commit -m "Initial import"
  git push -u origin main
); done
```


## 2. Create Remote Backup Repos

Create repo/s on the remote server/s like this:

**2.1 Single repo** - create and init:

```bash
# Supposing that my-backup-server1 is server host alias inside your local ~/.ssh/config file

# Connect to your private server
ssh my-backup-server1

# Create a new repository
mkdir -p /home/repos/my-backup-repo1

# Initialize the repository
cd /home/repos/my-backup-repo1
git init --bare
# Now your backup repo url would be like this: ssh://my-backup-server1/home/repos/my-backup-repo1
```

OR

**2.2 Multiple repos** - bulk create and init:

```bash
# Bulk create and init repos
ssh my-backup-server1 'for r in my-backup-repo1 my-backup-repo2 my-backup-repo3; do mkdir -p "/home/repos/$r" && git init --bare "/home/repos/$r"; done'
```

Verify

```bash
ssh my-backup-server1 'for r in my-backup-repo1 my-backup-repo2 my-backup-repo3; do test -d "/home/repos/$r/objects" && echo "OK $r"; done'
```




## 3. Add Backup Repos Urls to Config


**3.1 Single repo** - add single backup repo url on multiple backup servers, manually

On your local machine, inside your main git repo directory, add backup repo urls to your main git repo's .git/config file as push repositories like this:

NOTE: you need to replace placehoplders in the commands below like <current-remote-origin-url>, <my-backup-repo1-url>, <my-backup-repo2-url>, <my-backup-repo3-url> with the actual urls of your backup repositories.

```bash
# Get the url of the current remote origin
git remote get-url origin 

# Add the current remote origin as a push repository, replace <current-remote-origin-url> with the output of the previous command
git remote set-url --add --push origin <current-remote-origin-url> 

# Add backup repositories as push repositories
git remote set-url --add --push origin <my-backup-server1-repo1-url>
git remote set-url --add --push origin <my-backup-server2-repo1-url>
git remote set-url --add --push origin <my-backup-server3-repo1-url>

#Verify the changes - list all remote repositories (fetch and push)
git remote -v
# Optionally check just push repositories
git remote get-url --push --all origin
```

OR

**3.2 Multiple repos** - add multiple backup repo urls on multiple backup servers, by running  one command:

```bash
for r in my-backup-repo1 my-backup-repo2 my-backup-repo3; do (
  cd "/path/to/local/repos/$r" || exit 1
  current="$(git remote get-url origin)" || exit 1
  git remote set-url --push origin "$current"
  git remote set-url --add --push origin "my-backup-server1:/home/repos/$r"
  git remote set-url --add --push origin "my-backup-server2:/home/repos/$r"
  git remote set-url --add --push origin "my-backup-server3:/home/repos/$r"
  git remote get-url --push --all origin
); done
```



## 4. Push your changes


After you have made and committed them with `git add` and `git commit` commands, you can push your changes to all configured origin.pushurl destinations like this:

```bash
git push origin main
git push origin --tags
```

That single git push origin will push to all configured origin.pushurl destinations.

Two practical notes:

- If one push target fails, Git may still have pushed to earlier targets; treat partial success carefully.
- Keep backup repos as --bare repos on servers for clean mirror targets.

> **Note:** From here on every time you do normal `git push` command, it will push to all configured origin.pushurl destinations.

## 5. Bulk Update Repos

**Use case example** - add root `.gitignore` with `*.ini` to multiple repos:

```bash
for r in my-repo1 my-repo2 my-repo3; do (
  cd "/path/to/local/repos/$r" || exit 1
  if [ -f .gitignore ]; then
    rg -q "^\*\.ini$" .gitignore || printf "\n*.ini\n" >> .gitignore
  else
    printf "*.ini\n" > .gitignore
  fi
  git add .gitignore
); done
```

Then bulk commit and push:

```bash
for r in my-repo1 my-repo2 my-repo3; do (
  cd "/path/to/local/repos/$r" || exit 1
  git diff --cached --quiet || { git commit -m "chore: ignore ini files" && git push origin main; }
); done
```
