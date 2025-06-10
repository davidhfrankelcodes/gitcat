# gitcat

`gitcat` is a shell script for dumping the contents of a git repository's files, with smart handling for ignored files, deleted files, and binaries. It's designed to help you create code dumps for review or sharing.

## Features

- **Respects `.gitignore` and `.gitcatignore`**: Files ignored by either are skipped.
- **Handles deleted files**: Marks deleted-but-not-staged files with an emoji instead of erroring.
- **Binary file detection**: By default, binary files are not dumped; instead, a consistent emoji is shown for each type.
- **Custom ignore patterns**: Add a `.gitcatignore` file to further filter files for dumping.
- **Output**: Use `gitcat > my_dumped_code.txt` to create a code dump.

## Usage

```sh
chmod +x gitcat.sh
gitcat.sh > my_dumped_code.txt
```

## Options

*More options coming soon!*

## Example Output

```
===== src/main.py =====
print("Hello, world!")

📦 Binary file: logo.png
❌ Deleted: old_script.sh
```

## License

MIT
