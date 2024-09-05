I always wanted a quick and easy way to count line of code in a project, so i wrote this small Racket script to refresh my Racket.

---

### Setup

Install racket: https://download.racket-lang.org/


Execute in cmd:
```
git clone https://github.com/Irrgh/rloc.git

cd rloc

(echo @echo off & echo racket %cd%\loc.rkt %*) > rloc.bat
```

Add the `cd` to the `PATH` environment variable.

---

### Usage

Execute `rloc` in whatever project you need to count lines in.
Filtering by type can be done with `rloc [file-extension]`.


If your project has a `.gitignore` it will automatically also ignore all **folders** listed.
Other `.gitignore` matching features not supported for now.
The `.git` directory is also ignored by default.
